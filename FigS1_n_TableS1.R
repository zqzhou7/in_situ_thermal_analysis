# ============================================================
# Fig. S1
# Field bottom-temperature time series with aligned month axis
# ============================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
})

input_file <- "data_site_2975_2021_05_20_2026_03_30.csv"

ambient_temp  <- 27
heatwave_temp <- 31

min_warm_run <- 2
min_cool_gap <- 2

warm_windows <- tribble(
  ~period,             ~start_date,   ~end_date,
  "2021 warm season",  "2021-06-01",  "2021-10-31",
  "2023 warm season",  "2023-06-01",  "2023-10-31"
) %>%
  mutate(
    start_date = as.Date(start_date),
    end_date   = as.Date(end_date),
    year       = year(start_date)
  )

fig_png <- "Fig_S1_field_bottom_temperature_aligned.png"
fig_pdf <- "Fig_S1_field_bottom_temperature_aligned.pdf"
table_csv <- "Table_S1_field_temperature_summary.csv"
warm_period_csv <- "field_warm_periods_by_year.csv"

# ------------------------------------------------------------
# Load and clean data
# ------------------------------------------------------------

raw <- read_csv(input_file, show_col_types = FALSE)

temp_dat <- raw %>%
  mutate(
    datetime_utc = as.POSIXct(timestamp, tz = "UTC"),
    datetime_hkt = with_tz(datetime_utc, tzone = "Asia/Hong_Kong"),
    date = as.Date(datetime_hkt)
  ) %>%
  arrange(datetime_hkt) %>%
  filter(!is.na(bottom_temperature_spotter)) %>%
  filter(
    bottom_temperature_spotter >= 10,
    bottom_temperature_spotter <= 35
  )

# ------------------------------------------------------------
# Daily mean bottom temperature
# ------------------------------------------------------------

daily_temp <- map_dfr(seq_len(nrow(warm_windows)), function(i) {
  
  w <- warm_windows[i, ]
  
  temp_dat %>%
    filter(
      date >= w$start_date,
      date <= w$end_date
    ) %>%
    group_by(date) %>%
    summarise(
      temp_mean = mean(bottom_temperature_spotter, na.rm = TRUE),
      temp_min  = min(bottom_temperature_spotter, na.rm = TRUE),
      temp_max  = max(bottom_temperature_spotter, na.rm = TRUE),
      n_obs     = n(),
      .groups   = "drop"
    ) %>%
    mutate(
      period = w$period,
      year = w$year,
      temp_state = if_else(
        temp_mean >= ambient_temp,
        "Above ambient summer reference",
        "Below ambient summer reference"
      ),
      plot_date = as.Date(paste0("2000-", format(date, "%m-%d")))
    )
  
}) %>%
  arrange(period, date) %>%
  group_by(period) %>%
  mutate(
    gap_days = as.numeric(date - lag(date)),
    segment_id = cumsum(is.na(gap_days) | gap_days > 1)
  ) %>%
  ungroup()

# ------------------------------------------------------------
# Identify warm periods
# ------------------------------------------------------------

identify_warm_periods <- function(df,
                                  threshold_value = 27,
                                  min_warm_run_value = 2,
                                  min_cool_gap_value = 2) {
  
  df <- df %>%
    arrange(date) %>%
    mutate(warm_day = temp_mean >= threshold_value)
  
  r <- rle(df$warm_day)
  values <- r$values
  lengths <- r$lengths
  
  if (length(values) >= 3) {
    i <- 2
    
    while (i < length(values)) {
      if (
        values[i] == FALSE &&
        lengths[i] < min_cool_gap_value &&
        values[i - 1] == TRUE &&
        values[i + 1] == TRUE
      ) {
        lengths[i - 1] <- lengths[i - 1] + lengths[i] + lengths[i + 1]
        values <- values[-c(i, i + 1)]
        lengths <- lengths[-c(i, i + 1)]
        i <- max(2, i - 1)
      } else {
        i <- i + 1
      }
    }
  }
  
  period_id <- rep(seq_along(values), lengths)
  period_id <- period_id[seq_len(nrow(df))]
  
  df_periods <- df %>%
    mutate(
      period_id = period_id,
      warm_state_merged = values[period_id]
    )
  
  df_periods %>%
    filter(warm_state_merged) %>%
    group_by(period_id) %>%
    summarise(
      start_date = min(date),
      end_date = max(date),
      duration_days = as.integer(end_date - start_date) + 1,
      mean_temp = mean(temp_mean, na.rm = TRUE),
      max_temp = max(temp_mean, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    filter(duration_days >= min_warm_run_value)
}

warm_periods_all <- daily_temp %>%
  group_by(period, year) %>%
  group_modify(~ identify_warm_periods(
    .x,
    threshold_value = ambient_temp,
    min_warm_run_value = min_warm_run,
    min_cool_gap_value = min_cool_gap
  )) %>%
  ungroup() %>%
  mutate(
    start_plot_date = as.Date(paste0("2000-", format(start_date, "%m-%d"))),
    end_plot_date   = as.Date(paste0("2000-", format(end_date, "%m-%d")))
  )

# ------------------------------------------------------------
# Save summary table
# ------------------------------------------------------------

summary_table <- daily_temp %>%
  group_by(period, year) %>%
  summarise(
    `Warm-season period` = paste0(
      format(min(date), "%d %b"), " – ", format(max(date), "%d %b")
    ),
    `Mean bottom temperature (°C)` = round(mean(temp_mean, na.rm = TRUE), 1),
    `Maximum bottom temperature (°C)` = round(max(temp_mean, na.rm = TRUE), 1),
    `Days >=27 °C (warm days)` = sum(temp_mean >= ambient_temp, na.rm = TRUE),
    `Days >=31 °C (simulated MHW days)` = sum(temp_mean >= heatwave_temp, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(
    warm_periods_all %>%
      group_by(period, year) %>%
      summarise(
        `Number of warm periods*` = n(),
        `Longest warm period (days)*` = max(duration_days, na.rm = TRUE),
        `Mean warm period length (days)*` = round(mean(duration_days, na.rm = TRUE), 1),
        .groups = "drop"
      ),
    by = c("period", "year")
  ) %>%
  mutate(
    `Number of warm periods*` = replace_na(`Number of warm periods*`, 0),
    `Longest warm period (days)*` = replace_na(`Longest warm period (days)*`, 0),
    `Mean warm period length (days)*` = replace_na(`Mean warm period length (days)*`, 0)
  ) %>%
  select(
    Year = year,
    Period = period,
    everything(),
    -period
  )

write_csv(summary_table, table_csv)
write_csv(warm_periods_all, warm_period_csv)

# ------------------------------------------------------------
# Plot preparation
# ------------------------------------------------------------

shade_df <- warm_periods_all %>%
  transmute(
    period,
    xmin = start_plot_date,
    xmax = end_plot_date,
    ymin = -Inf,
    ymax = Inf
  )

label_df <- tibble(
  period = unique(daily_temp$period),
  x_pos = as.Date("2000-06-06")
)

x_breaks <- as.Date(c(
  "2000-06-01", "2000-07-01", "2000-08-01",
  "2000-09-01", "2000-10-01", "2000-11-01"
))

x_limits <- as.Date(c("2000-06-01", "2000-11-01"))

# Dark outlines

state_cols <- c(
  "Below ambient summer reference" = "#2166AC",
  "Above ambient summer reference" = "#B2182B"
)

# Lighter fills
state_fills <- c(
  "Below ambient summer reference" = "#A6C8E1",
  "Above ambient summer reference" = "#E8A3A3"
)

# ------------------------------------------------------------
# Fig. S1
# ------------------------------------------------------------

Fig_S1 <- ggplot() +
  
  geom_rect(
    data = shade_df,
    aes(
      xmin = xmin,
      xmax = xmax,
      ymin = ymin,
      ymax = ymax
    ),
    fill = "grey80",
    alpha = 0.35,
    inherit.aes = FALSE
  ) +
  
  geom_line(
    data = daily_temp,
    aes(
      x = plot_date,
      y = temp_mean,
      group = interaction(period, segment_id)
    ),
    color = "grey45",
    linewidth = 0.55,
    alpha = 0.85
  ) +
  
  geom_point(
    data = daily_temp,
    aes(
      x = plot_date,
      y = temp_mean,
      color = temp_state,
      fill = temp_state
    ),
    shape = 21,
    size = 1.65,
    stroke = 0.65,
    alpha = 0.95
  ) +
  
  geom_hline(
    yintercept = ambient_temp,
    linewidth = 0.75,
    color = "#E66101"
  ) +
  
  geom_hline(
    yintercept = heatwave_temp,
    linewidth = 0.8,
    linetype = "dashed",
    color = "#B2182B"
  ) +
  
  geom_text(
    data = label_df,
    aes(
      x = x_pos + 60,
      y = heatwave_temp - 0.45,
      label = "31 °C simulated MHW\n(OISST V2.1 / NOAA)"
    ),
    hjust = 0,
    vjust = 1,
    size = 3.0,
    color = "#B2182B",
    inherit.aes = FALSE
  ) +
  
  geom_text(
    data = label_df,
    aes(
      x = x_pos,
      y = ambient_temp - 2.0,
      label = "27 °C ambient summer reference\n(in situ bottom observations)"
    ),
    hjust = 0,
    vjust = 1,
    size = 3.0,
    color = "#E66101",
    inherit.aes = FALSE
  ) + 
  
  facet_grid(
    rows = vars(period),
    switch = "y"
  ) +
  
  scale_color_manual(
    values = state_cols,
    name = NULL
  ) +
  
  scale_fill_manual(
    values = state_fills,
    name = NULL
  ) +
  
  scale_x_date(
    breaks = x_breaks,
    labels = c("Jun", "Jul", "Aug", "Sep", "Oct", "Nov"),
    limits = x_limits,
    expand = expansion(mult = c(0.01, 0.01))
  ) +
  
  scale_y_continuous(
    limits = c(23, 31.6),
    breaks = c(23, 25, 27, 29, 31),
    expand = expansion(mult = c(0, 0.02))
  ) +
  
  labs(
    x = "Month",
    y = "Bottom temperature (°C)"
  ) +
  
  theme_classic(base_size = 14) +
  theme(
    legend.position = "bottom",
    legend.text = element_text(face = "bold",size = 12),
    legend.justification = c(0.5, 0.5),
    legend.box.margin = margin(t = -4, r = 0, b = -2, l = -35),
    legend.margin = margin(t = -2, b = 0),
    legend.spacing.x = unit(0.45, "cm"),
    legend.key.width = unit(0.65, "cm"),
    
    strip.text = element_text(
      face = "bold",
      size = 12,
      color = "black"
    ),
    strip.background = element_rect(
      fill = "white",
      color = "black",
      linewidth = 0.6
    ),
    
    axis.title = element_text(
      face = "bold",
      size = 15,
      color = "black"
    ),
    axis.text = element_text(
      face = "bold",
      size = 12,
      color = "black"
    ),
    axis.line = element_line(
      linewidth = 0.55,
      color = "black"
    ),
    axis.ticks = element_line(
      linewidth = 0.55,
      color = "black"
    ),
    panel.border = element_rect(
      color = "black",
      fill = NA,
      linewidth = 0.5
    ),
  
    panel.spacing = unit(0.6, "lines")
  )

print(Fig_S1)

ggsave(
  fig_png,
  Fig_S1,
  width = 180,
  height = 120,
  units = "mm",
  dpi = 600
)

ggsave(
  fig_pdf,
  Fig_S1,
  width = 180,
  height = 120,
  units = "mm"
)
