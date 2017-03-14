require(ggplot2)

# Function to read the files with the Tajma D's calculations
read.scores <- function(filename){
    
    # Read the tsv as it is
    data <- read.table( filename ,
                        header=F ,
                        sep="\t" ,
                        dec="."  ,
                        na.string="na") # Read all data
    
    #Add names to the columns
    colnames(data)  <- c("chromosome", "position", "score")        # Add names to the columns
    # Add color and convert the chromosome into a factor
    data$color <- factor( as.numeric(data$chromosome) %% 2 )
    data$chromosome <- factor(data$chromosome)
    
    # Return the dataset
    data

}

#Function to do all the plotting
plot.score <- function(data, fileout, hlines=NULL){
    
    labels <- levels( data$chromosome )
    
    ticks <- data.frame( labels , pos=0 )
    
    for(i in 1:nrow(ticks)){
        chromosome <- ticks$labels[i]
        position <- mean(which(data$chromosome == chromosome))
        ticks$pos[i] <- position
    }
    
    # Generate the plot: x is the number of elements, y: tajima's D, as color use data$color
    Score_plot <-  ggplot( data=data, aes(x=1:nrow(data), y=score),colour=color) +
        # X axis: title, use breaks and as labels the chromosome names
        scale_x_continuous( "Genomic position" , breaks = ticks$pos , labels = labels ) +
        # Y axis: title
        scale_y_continuous( "Score" ) +
        # Plot points with size 1.5, alpha 0.5 and coloured
        geom_point( aes( alpha = 0.5 , colour = color ) , size = 1.5 ) +
        # Use colors darkblue and orange
        scale_color_manual( values = c( "darkblue", "orange" ) ) +
        # Use gray background
        theme_gray() +
        # Main title
        theme( legend.position = "none" )
    # If supplied constants (horizontal lines) plot them
    if( length( hlines ) > 0 ){
        Score_plot <- Dplot + geom_hline( yintercept = hlines   ,
                                          colour     = "black"  ,
                                          linetype   = "dashed" )
    }
    Score_plot
    ggsave(fileout)
    # ggsave call for Marta's poster
    #ggsave(fileout, width=34, height=8, units="cm")
}




args <- commandArgs(trailingOnly = TRUE)

action  <- args[1]
filein  <- args[2]
fileout <- args[3]
    
if(length(args) != 3){
    stop("Incorrect number of files. Maybe missing action")
}
    
data <- read.scores(filein)

if( action == "z"){
    m          <- mean( data$score, na.rm = T )
    stdev      <- sd(   data$score, na.rm = T ) 
    data$score <- ( data$score - m ) / stdev
    plot.score( data , fileout )
}else if(action == "none"){
    plot.score( data , fileout )
}else{
    stop("Incorrect action")
}
