library(ggplot2)

annual <- read.csv("annual.csv")
annual_chart <- ggplot(annual, aes(year, mean_temp_f)) +
  geom_hline(yintercept = mean(annual$mean_temp_f),
             color = "#64748b", linetype = "dashed") +
  geom_line(color = "#046b78", linewidth = 0.85) +
  labs(x = "Year", y = "Mean temperature (°F)",
       title = "Annual mean across available station-day readings",
       subtitle = "NOAA GSOD, 1929–2022. Dashed line is the mean of annual means.") +
  theme_minimal(base_size = 12)
ggsave("images/annual-temperature.png", annual_chart, width = 8.0, height = 3.8,
       dpi = 150, bg = "white")

country <- read.csv("country-decade.csv")
country$country <- factor(country$country, levels = c("IN", "UK", "US"),
                          labels = c("India", "United Kingdom", "United States"))
country_chart <- ggplot(country, aes(decade, mean_temp_f, fill = country)) +
  geom_col(position = position_dodge(width = 0.85, preserve = "single"), width = 0.8) +
  scale_fill_manual(values = c("#046b78", "#b85b27", "#60539d")) +
  labs(x = "Decade", y = "Mean temperature (°F)", fill = NULL,
       title = "Mean station-day temperature by country and decade",
       subtitle = "1920s covers 1929 only. Gaps indicate no returned group.") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")
ggsave("images/country-decade-temperature.png", country_chart, width = 8.0,
       height = 4.2, dpi = 150, bg = "white")
