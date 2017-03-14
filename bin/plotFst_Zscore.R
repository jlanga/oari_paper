require(ggplot2)


#Read fst file and the corresponding number for comparison
readFst<- function(filename, popNumber){

    # Read data "as is"
    rawData <- read.csv( filename , sep=c("\t") , header=F , na.string="na" , as.is=T)[,c( 1:5 , 5 + popNumber )]
    colnames(rawData) <- c( "chromosome" , "window" , "nsnps" , "covFrac" , "avgMinCov" , "fst" )

    
    # Convert the fst columns to a proper number
    tmp <- unlist( strsplit( rawData$fst , split = "=" ) ) # Split and convert to vector
    tmp <- matrix( tmp , ncol = 2 , nrow = length(tmp)/2 , byrow = T)
    tmp[tmp[,2]=="na",2] <- NA
    tmp <- tmp[,2]
    rawData$fst <- as.numeric(tmp)
        
    # Generate color pattern (0 or 1, and as a factor)
    rawData$color <- factor( rawData$chromosome %% 2 )
    
    # Convert chromosome to factor
    rawData$chromosome <- factor(rawData$chromosome)
    
    rawData

}

plotFst <- function(data, fileout, hlines=NULL){
    
    labels <- levels(data$chromosome)
    
    ticks <- data.frame(labels,pos=0)
    
    for(i in 1:nrow(ticks)){
        chromosome <- ticks$labels[i]
        position <- mean(which(data$chromosome == chromosome))
        ticks$pos[i] <- position
    }
    
    Dplot <-  ggplot(data=  data, 
                     aes(   x= 1:nrow(data) ,
                            y= fst          ) )   +
        
        scale_x_continuous( "Genomic position"  ,
                            breaks= ticks$pos   ,
                            labels= labels      ) +
        
        scale_y_continuous( expression( F[ST] ) ) +
        
        geom_point( aes( alpha= 0.5, colour= color ) ,
                    size= 1.5 ) +
        
        scale_color_manual(values = c( "orange" , "darkblue" ) ) +
        
        theme_gray() +
        
        theme( legend.position = "none" )
    
    if(length(hlines) > 0){
    
        Dplot <- Dplot + geom_hline(yintercept= hlines   ,
                                    colour=     "black"  ,
                                    linetype=   "dashed" )
        
    }
    
    Dplot
    
    ggsave( fileout )

}


folders <- c( "data/fst_SS10_c8_C11_W200K_S50K/Zscore" )

popNumbers <- 1:3

for( folder in folders ){
    
    for( popNumber in popNumbers ){
    
        fileFst         <- paste( folder , "/ALL_Z.tsv" ,                      sep = "" )
        filePng         <- paste( folder , "/ALL."    , popNumber , ".png" , sep = "" )
                
        
        data <- readFst( filename = fileFst , popNumber = popNumber )
        
                
        plotFst( data = data , fileout = filePng )
        
    }

}
