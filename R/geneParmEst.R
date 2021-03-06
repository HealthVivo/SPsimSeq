# Gene level param estimates for density estimation
gene.parm.est <- function(cpm.data.i, batch, group, null.group,
                          sub.batchs, de.ind, model.zero.prob,
                          min.val, w,...){
  batch.est <- lapply(sub.batchs, function(b){ 
    if(de.ind==0){
      Y0 <- cpm.data.i[(batch==b & group==null.group)] 
      Y = if(model.zero.prob & mean(Y0==min.val)>0.25){
        Y0[Y0>min.val]
        } else Y0
      
    if(sum(Y>min.val)>3){
        countY   <- obtCount(Y=Y, w=w)
        parm.est <- fitLLmodel(yy=countY)
        # if(!is.null(parm.est$betas) & length(countY$S)>=3){
        #   parm.est
        # } 
        # else{NULL}  
        parm.est
      } 
      else{
        list(S=0, lls=0, uls=0, Ny=0, Y=Y, mu.hat=mean(Y), sig.hat=sd(Y), 
                w=w, betas=parmEstOut(llm = NULL)$beta.hat.vec, 
                v = parmEstOut(llm = NULL)$V.hat.mat)
        }
    }
    else{
      Y0 <- split(cpm.data.i[batch==b], group[batch==b])
      Y <- lapply(Y0, function(y0){
        if(model.zero.prob & mean(y0==min.val)>0.25) {y0[y0>min.val]}
        else {y0}
      }) 
      lapply(Y, function(y){
        if(sum(y>min.val)>3){
          countY   <- obtCount(Y=y, w=w)
          parm.est <- fitLLmodel(yy=countY)
          # if(!is.null(parm.est$betas) & length(countY$S)>=3){
          #   parm.est
          # } 
          # else{NULL}  
          parm.est
        } 
        else{
          list(S=0, lls=0, uls=0, Ny=0, Y=y, mu.hat=mean(y), sig.hat=sd(y), 
               w=w, betas=parmEstOut(llm = NULL)$beta.hat.vec, 
               v = parmEstOut(llm = NULL)$V.hat.mat)
        }
      }) 
    }
  }) 
  return(batch.est)
  # if(de.ind==0){
  #   batch.parms.lst <- lapply(batch.est, function(b){ 
  #     if(!is.null(b)){
  #       c(b$betas,  mu.hat=b$mu.hat,  sig.hat=b$sig.hat)
  #       #b$betas
  #     }
  #     else{as.matrix(NA)}
  #   })
  #   batch.parms <- rbind.fill(lapply(batch.parms.lst, 
  #                                     function(x) as.data.frame(as.list(x)))) 
  #   if(any(dim(batch.parms)>1)){
  #     Mu.batch <- colMeans(batch.parms, na.rm = TRUE)
  #     V.batch  <- var(batch.parms, na.rm = TRUE) 
  #   }
  #   else{
  #     Mu.batch <- NULL
  #     V.batch  <- NULL
  #   }
  # }
  # else{
  #   batch.parms.lst <- lapply(sort(unique(group)), function(g){
  #     b <- lapply(batch.est, function(x) x[[g]])
  #     b <- lapply(b, function(bb){
  #       if(!is.null(bb)){
  #         c(bb$betas, mu.hat=bb$mu.hat, sig.hat=bb$sig.hat)
  #         #bb$betas
  #       }
  #       else{NULL}
  #     }) })
  #   
  #   batch.parms <- lapply(batch.parms.lst, function(g){
  #     rbind.fill(lapply(g, function(x) as.data.frame(as.list(x))))
  #   })
  #   
  #   if(!any(sapply(batch.parms, function(x) is.null(unlist(x))))){
  #     Mu.batch <- lapply(batch.parms, colMeans, na.rm = TRUE)
  #     V.batch  <- lapply(batch.parms, var, na.rm = TRUE)
  #   }
  #   else{
  #     Mu.batch <- NULL
  #     V.batch  <- NULL
  #   }
  # }
  # 
  # if(!is.null(Mu.batch)){
  #   list(Mu.batch=Mu.batch, V.batch=V.batch,  batch.est=batch.est)
  # }
  # else{
  #   NULL
  # }
}