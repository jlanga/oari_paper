require(ggplot2)


# Function to read the files with the Tajma D's calculations
read.D <- function(filename){
    
    # Read the tsv as it is
    data <- read.csv(filename , header=F ,
                     sep="\t" ,
                     dec="."  ,
                     na.string="na") # Read all data
    
    #Add names to the columns
    colnames(data)  <- c("chromosome", "window", "nsnps", "fraction", "D")        # Add names to the columns
    
    # Add color and convert the chromosome into a factor
    data$color <- factor(as.numeric(data$chromosome) %% 2)
    data$chromosome <- factor(data$chromosome)
    
    # Return the dataset
    data

}

#Function to do all the plotting
plot.D <- function(data, fileout, hlines=NULL){
    
    labels <- levels(data$chromosome)
    
    ticks <- data.frame(labels,pos=0)
    
    for(i in 1:nrow(ticks)){
        chromosome <- ticks$labels[i]
        position <- mean(which(data$chromosome == chromosome))
        ticks$pos[i] <- position
    }
    
    # Generate the plot: x is the number of elements, y: tajima's D, as color use data$color
    Dplot <-  ggplot( data=data, aes(x=1:nrow(data), y=D),colour=color) +
        # X axis: title, use breaks and as labels the chromosome names
        scale_x_continuous("Genomic position", breaks=ticks$pos, labels=labels) +
        # Y axis: title
        scale_y_continuous("Tajima's D") +
        # Plot points with size 1.5, alpha 0.5 and coloured
        geom_point(aes(alpha=0.5,colour=color), size=1.5) +
        # Use colors darkblue and orange
        scale_color_manual(values = c("darkblue", "orange")) +
        # Use gray background
        theme_gray() +
        # Main title
        theme(legend.position="none")
    # If supplied constants (horizontal lines) plot them
    if(length(hlines) > 0){
        Dplot <- Dplot + geom_hline(yintercept=hlines,
                                    colour="black",
                                    linetype="dashed")
    }
    Dplot
    ggsave(fileout)
    # ggsave call for Marta's poster
    #ggsave(fileout, width=34, height=8, units="cm")
}



folders <- c( "data/tajimaD_NOSS_c5_C20_W200K_S50K" ,
              "data/tajimaD_SS10_c8_C11_W200K_S50K" )

populations   <- c( "1_1" , "2_1" , "3_1" )

for(folder in folders){
    
    for(population in populations){
        
        fileD         <- paste( folder , "/" , population , ".D"          , sep = "" )
        filePng       <- paste( folder , "/" , population , ".png"        , sep = "" )
        fileDFiltered <- paste( folder , "/" , population , ".filtered.D" , sep = "" )
          
        data    <- read.D(fileD)
        dataNegative <- data[data$D <= 0 , ]
        
        ll1 <- sort( dataNegative$D )[ nrow(dataNegative) * 0.02 ] ; print(ll1)
        
        dataFiltered <- dataNegative[dataNegative$D <= ll1 , 1:5 ] # The sixth column is the color
        dataFiltered <- na.exclude(dataFiltered)
        
        
        write.table( x        = dataFiltered  ,
                    file      = fileDFiltered , 
                    quote     = F             , 
                    sep       = "\t"          , 
                    row.names = F             , 
                    col.names = F             )
        
        # Plots
        plot.D( data , filePng , ll1 )
    }
    
}

