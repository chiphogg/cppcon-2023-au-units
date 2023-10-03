library(ggplot2)

d <- read.csv('./types.csv', header=TRUE, stringsAsFactors=FALSE)

d_aug <- rbind(d, read.csv('./extra_points.csv', header=TRUE, stringsAsFactors=FALSE))

plot <- (ggplot(d, aes(x=bits, y=threshold))
         + theme(text=element_text(size=30), plot.title=element_text(hjust=0.5))
         + geom_point()
         + scale_y_log10(breaks=c(1, 1e3, 1e6, 1e9, 1e12, 1e15),
                         labels=c('1', '1,000', '1,000,000', '1e9', '1e12', '1e15'),
                         limits=c(1e-2, 1e17),
                         expand=c(0, 0),
                         name="Largest Threshold Allowed")
         + scale_x_continuous(limits=c(5, 66),
                              expand=c(0, 0))
         + ggtitle("The Overflow Safety Surface")
         )

plot_line <- (plot
              + geom_ribbon(data=d_aug, ymin=2e-5, aes(ymax=threshold))
              + geom_ribbon(data=data.frame(bits=c(5, 66), threshold=c(1e-2, 1e-2)),
                            aes(ymin=threshold),
                            ymax=2e-5)
              )

output_index <- 0
output_filename <- function(label)
{
  output_index <- output_index + 1
  sprintf("safety-surface_%02d_%s.svg", output_index, label)
}

output <- function(plot, filename)
{
  ggsave(file=filename, plot=plot, width=10, height=6)
}

output(plot, output_filename('points'))
output(plot_line, output_filename('surface'))
