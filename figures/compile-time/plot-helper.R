library(ggplot2)
library(stringr)
library(Cairo)

d <- read.csv('./absolute-compile-times2022-10-22_16h57m47s.csv',
              header=FALSE,
              stringsAsFactors=FALSE)
colnames(d) <- c('date', 'target', 'branch', 'config', 'time_us')
d$date <- gsub(" UTC", "", d$date)
d$date <- as.POSIXct(d$date, format="%a %b %d %H:%M:%S %Y")
d$time_s = d$time_us / 1e6

limits <- c('au', 'nholthaus', 'no-units')
labels <- str_wrap(
    c(
        'Au',
        'nholthaus',
        'No units'
    ),
    width=15,
)
################################################################################

cumulative_plot <- function(configs)
{
  my_data <- subset(d, config %in% configs)
  config_labels <- c('Default', 'No I/O', 'Trim Units')[1:length(configs)]
  line_widths <- ifelse(configs == tail(configs, n=1), 2, 1)
  line_types <- length(configs):1
  print(line_widths)
  (ggplot(my_data, aes(x=time_s, colour=branch, linetype=config, linewidth=config))
    + theme(text=element_text(size=25))
    + stat_ecdf()
    + stat_ecdf(data=subset(my_data, config == 'base' & branch == 'no-units'), linewidth=2, linetype=1)
    + geom_vline(xintercept=0)
    + scale_x_continuous(name='Compilation time (s)')
    + scale_y_continuous(name='Quantile')
    + scale_discrete_manual(aesthetic="linewidth", values=line_widths, labels=config_labels)
    + scale_discrete_manual(aesthetic="linetype", values=line_types, labels=config_labels)
    + scale_colour_brewer(limits=limits, labels=labels, palette="Set2")
    + facet_wrap(. ~ target, scales='fixed')
    + ggtitle('Cumulative compile time distributions')
    + theme(legend.position=c(0.87, 0.75))
    + coord_flip()
  )
}

output <- function(plot, filename)
{
    CairoPNG(filename=filename, width=1600, height=1000)
    print(plot)
    dev.off()
}

output_filename <- function(configs)
{
  sprintf("cumulative_compile_times_%d_%s.png",
          length(configs),
          paste(configs, collapse="-"))
}

configs <- c('base', 'noio', 'split')
for (len in 1:length(configs))
{
  current_configs = configs[1:len]
  output(cumulative_plot(current_configs), filename=output_filename(current_configs))
}

