# A function to simulate data from the estimated density (gene level)
sampleDatSPDens <- function(cpm.data, sel.genes.i, par.sample, DE.ind.ii, null.group, 
                            copulas.batch, LL, group, batch, n.group, g1, log.CPM.transform, const,
                            model.zero.prob, min.val, fracZero.logit.list){
  if(DE.ind.ii==0){ 
    Y.star <- lapply(seq_len(nrow(par.sample)), function(bb){
      Y0 <- cpm.data[sel.genes.i, (batch==bb & group==null.group)] 
      #set.seed(sim.seed)
      u <-  copulas.batch[[bb]][, sel.genes.i]# #runif(n.batch[[bb]]) #
      gg1 <- g1[[bb]]
      #set.seed(sim.seed+1)
      y.star.b <- sapply(u, function(uu){
        yy  <- gg1$s[which.min(abs(gg1$Gy-uu))]
        difs<- diff(gg1$s)
        difs<- difs[!(is.na(difs) | is.infinite(difs) | is.nan(difs))]
        eps <- abs(mean(difs, na.rm=TRUE)) #gg1$s[2]-gg1$s[1]  
        yy  <- suppressWarnings(runif(1, yy-eps/2, yy+eps/2)) 
        yy
      })
      LL.b <- as.numeric(do.call("c", LL[[bb]]))
      if(log.CPM.transform){
        y.star.b <- round(((exp(y.star.b)-const)*LL.b)/1e6)
        y.star.b[y.star.b<0] <- 0
      } 
      
      if(model.zero.prob & mean(Y0==min.val)>0.25){
        lLL_b <- log(LL.b)
        pred.pz  <- try(predict(fracZero.logit.list[[bb]], type="response",
                                newdata=data.frame(x1=mean(Y0), x2=lLL_b)), 
                        silent = TRUE)
        if(!is(pred.pz,"try-error")){
          #set.seed(sim.seed+2)
          drop.mlt <- sapply(pred.pz, function(p){ 
            rbinom(1, 1, p) 
          })
        }
        else{
          drop.mlt <- 0
        } 
        y.star.b <- y.star.b*(1-drop.mlt)
      }
      as.numeric(y.star.b)
    })
    Y.star <- do.call("c", Y.star)
    #if(any(is.na(Y.star))){print(i)}
  }
  else{ 
    Y.star <- lapply(sort(unique(group)), function(g){
      par.sample.g <- par.sample[[g]] #par.sample[[paste0("grp_", g)]]
      g1.g <- g1[[g]] #g1[[paste0("grp_", g)]]
      y.star.g <- lapply(seq_len(nrow(par.sample.g)), function(bb){
        Y0.g <- cpm.data[sel.genes.i, batch==bb & group==g]
        #set.seed(sim.seed+bb)
        u <- copulas.batch[[bb]][seq_len(n.group[g]), sel.genes.i]#runif(config.mat[bb, g])#runif(n.batch[[bb]]/length(n.group))
        gg1 <- g1.g[[bb]]
        #set.seed(sim.seed+bb+1)
        y.star.b <- sapply(u, function(uu){
          yy  <- gg1$s[which.min(abs(gg1$Gy-uu))]
          difs<- diff(gg1$s)
          difs<- difs[!(is.na(difs) | is.infinite(difs) | is.nan(difs))]
          eps <- abs(mean(difs, na.rm=TRUE)) #gg1$s[2]-gg1$s[1]  
          yy  <- suppressWarnings(runif(1, yy-eps/2, yy+eps/2))
          yy
        })
        LL.b.g <- LL[[bb]][[g]]
        
        if(log.CPM.transform){
          y.star.b <- round(((exp(y.star.b)-const)*LL.b.g)/1e6)
          y.star.b[y.star.b<0] <- 0
        }  
        
        if(model.zero.prob & mean(Y0.g==min.val)>0.25){
          lLL.b.g<- log(LL.b.g)
          pred.pz  <- try(predict(fracZero.logit.list[[bb]], type="response",
                                  newdata=data.frame(x1=mean(Y0.g), x2=lLL.b.g)), 
                          silent = TRUE)
          if(!is(pred.pz,"try-error")){
            #set.seed(sim.seed+bb+2)
            drop.mlt <- sapply(pred.pz, function(p){
              ##set.seed(sim.seed+bb+2)
              rbinom(1, 1, p)
            })
          }
          else{
            drop.mlt <- 0
          } 
          y.star.b <- y.star.b*(1-drop.mlt)
        }
        as.numeric(y.star.b)
      })
      y.star.g <- do.call("c", y.star.g)
    })
    Y.star <- do.call("c", Y.star)
    #if(any(is.na(Y.star))){print(i)}
  }
  return(Y.star)
}