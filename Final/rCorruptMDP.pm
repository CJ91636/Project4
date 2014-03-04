mdp

const int N;

module partyO
        sentBitsO : [0..N+1];
        recdBitsO : [0..N+1];
        turnO : [0..2];
	contactO : [0..1];
	resultO : [0..2];
        
        [begin] turnO=0 -> (turnO' = 1);
    
        [sendO] turnO=1 & sentBitsO<N+1 & sentBitsO=recdBitsO  & !(contactO=1 & resultO=0) -> (sentBitsO'=sentBitsO+1) & (turnO' = 0);

        [sendR] turnO=0 & recdBitsO<N -> (recdBitsO' = recdBitsO+1) & (turnO' = 1);

        [sendR] turnO=0 & recdBitsO=N ->  (recdBitsO' = recdBitsO+1) & (turnO' = 2);

        [] turnO=2 -> (turnO'=2);

        [reqO] turnO=1 & !(contactO=1) & recdBitsO<=N & recdBitsO>=1 -> (contactO'=1);
        [replyO] sendO=1 ->(resultO'=responseO) & (turnO'=0);

        [replyR] true -> (turnO'=1);

	[ignoreO] false & turnO=1 & !(contactO=1 & resultO=0) -> (turnO'=0);
	[ignoreR] true -> (turnO'=1);

endmodule

module partyR
        sentBitsR : [0..N+1];
        recdBitsR : [0..N+1];
        turnR : [0..1];
	contactR : [0..1];  
	resultR : [0..2];

        [begin] turnR=0 -> (turnR'=0);

        [sendO] turnR=0 & recdBitsR<N+1 -> (recdBitsR' = recdBitsR+1) & (turnR'=1);
        
        [sendR] turnR=1 & sentBitsR<(N+1) & recdBitsR=sentBitsR+1  & !(contactR=1 & resultR=0) -> (sentBitsR'=sentBitsR+1) & (turnR'=0);

	[reqR] turnR=1  & !(contactR=1) & recdBitsR<=N & recdBitsR>=1  -> (contactR'=1); //CMT
        [replyR] sendR=1 ->(resultR'=responseR) & (turnR'=0);

        [replyO] true -> (turnR'=1);

	[ignoreR] turnR=1 & !(contactR=1 & resultR=0) -> (turnR'=0);
	[ignoreO] true -> (turnR'=1);

endmodule

module tTP

        responseO : [0..2];
        iO : [0..N+1];
        sendO : [0..1];
        responseR : [0..2];
        iR : [0..N+1];
        sendR :[0..1];


        //COMMENTS
        
         //swap counts with responses - lose count
        [reqO] (sendO=0 & sendR=0) & responseO=0 & responseR=0 & recdBitsO<=N -> recdBitsO/N : (responseO'=1) & (iO'=recdBitsO) & (sendO'=1)  + (N-recdBitsO)/N : (responseO'=2) & (iO'=recdBitsO) & (sendO'=1) ;
        [reqR] (sendO=0 & sendR=0) & responseR=0 & responseO=0 & recdBitsR<=N -> recdBitsR/N : (responseR'=1) & (iR'=recdBitsR) & (sendR'=1)  + (N-recdBitsR)/N : (responseR'=2) & (iR'=recdBitsR) & (sendR'=1) ;
        //only giver response to first party
        [reqO] (sendO=0 & sendR=0) & responseO>0 -> true ;//do nothing
        [reqR] (sendO=0 & sendR=0) & responseR>0 -> true ;
        //3a
        [reqO] (sendO=0 & sendR=0) & responseO=0 & responseR=1 -> (responseO'=1) & (sendO'=1) ;
        [reqR] (sendO=0 & sendR=0) & responseR=0 & responseO=1 -> (responseR'=1) & (sendR'=1) ;
        [reqO] (sendO=0 & sendR=0) & responseO=0 & responseR=2 & iR<recdBitsO & recdBitsO<=N -> recdBitsO/N : (responseO'=1) & (sendO'=1) + (N-recdBitsO)/N : (responseO'=2) & (sendO'=1) ;
        [reqR] (sendO=0 & sendR=0) & responseR=0 & responseO=2 & iO+1<recdBitsR & recdBitsR<=N -> recdBitsR/N : (responseR'=1) & (sendR'=1) + (N-recdBitsR)/N : (responseR'=2) & (sendR'=1) ;
        [reqO] (sendO=0 & sendR=0) & responseO=0 & responseR=2 & iR>=recdBitsO -> (responseO'=2) & (sendO'=1) ;
        [reqR] (sendO=0 & sendR=0) & responseR=0 & responseO=2 & iO+1>=recdBitsR -> (responseR'=2) & (sendR'=1) ;

        [replyO] sendO=1 -> (sendO'=0) ;
        [replyR] sendR=1 -> (sendR'=0) ;

endmodule
