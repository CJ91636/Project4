smg

const int N;

player playerO
 partyO, [sendO], [reqO], [begin], [replyO], [endO], [endTurnO]
endplayer

player playerR
 partyR, [sendR], [reqR], [replyR]
endplayer 

module partyO
        sentBitsO : [0..N+1]; //no. bits sent by part 
        recdBitsO : [0..N+1]; //no. bits recieved by party
        turnO : [0..2]; //0 for not parties turn, 1 for parties turn, 2 for exhange end
	contactO : [0..1]; //1 represents contacted TTP
	resultO : [0..2]; //1 represents resolved contract by TTP, 2 represents rejection

        [begin] turnO=0 -> (turnO' = 1);
	// sends providing there are still commitments left, the other party hasn't ignored the previous turn, and the party isn't TTPing
        [sendO] turnO=1 & sentBitsO<(N+1) & !(contactO=1 & resultO=0) -> (sentBitsO'=sentBitsO+1);
	//recieves bit providing there's still commitments needed; if its the last one, end the transaction by going to state 2
        [sendR] turnO=0 & recdBitsO<N+1 & !(contactO=1 & resultO=0) -> (recdBitsO' = recdBitsO+1) & (turnO' = 1);


        [reqO] turnO=1 & !(contactO=1 & resultO=0) & resultO=0 & recdBitsO<=N & recdBitsO>=1 -> (contactO'=1);
        [replyO] sendO=1 ->(resultO'=responseO);
        [replyR] turnO=0 -> (turnO'=1);
	[replyR] turnO=2 -> (turnO'=2);


	[endTurnO] turnO=1 & !(contactO=1 & resultO=0) -> (turnO'=0);
	[endO] turnO=1 & (resultO=1 | recdBitsO=N+1) & !(contactO=1 & resultO=0) -> (turnO'=2);


endmodule

module partyR
        sentBitsR : [0..N+1];
        recdBitsR : [0..N+1]; 
        turnR : [0..2];
	contactR : [0..1];  
	resultR : [0..2];

        [begin] turnR=0 -> (turnR'=0);

        [sendO] turnR=0 & recdBitsR<N+1 -> (recdBitsR' = recdBitsR+1);
        
        [sendR] turnR=1 & sentBitsR<=(N) & recdBitsR=sentBitsR+1 & !(contactR=1 & resultR=0) -> (sentBitsR'=sentBitsR+1) & (turnR'=0);


	[reqR] turnR=1 & !(contactR=1) & recdBitsR<=N & (recdBitsR>=1) -> (contactR'=1);
        [replyR] sendR=1 ->(resultR'=responseR) & (turnR'=0);


	[endTurnO] turnR=0 & recdBitsR<N+1 -> (turnR'=1);
	[endTurnO] turnR=0 & recdBitsR=N+1 -> (turnR'=2);
	[endTurnO] turnR=2 -> (turnR'=2);

	[endO] turnR=0 -> (turnR'=1);
	[endO] turnR=2 -> (turnR'=2);



endmodule

module tTP

        responseO : [0..2]; //1 for resolved, 2 for rejected
        iO : [0..N+1]; //stores number of commitments for party's first contact
        sendO : [0..1]; //trigger for sending back result
        responseR : [0..2];
        iR : [0..N+1];
        sendR :[0..1];
        
        //if no one has contacted, follow logic for rule 1
        [reqO] (sendO=0 & sendR=0) & responseO=0 & responseR=0 & recdBitsO<=N -> recdBitsO/N : (responseO'=1) & (iO'=recdBitsO) & (sendO'=1)  + (N-recdBitsO)/N : (responseO'=2) & (iO'=recdBitsO) & (sendO'=1) ;
        [reqR] (sendO=0 & sendR=0) & responseR=0 & responseO=0 & recdBitsR<=N -> recdBitsR/N : (responseR'=1) & (iR'=recdBitsR) & (sendR'=1)  + (N-recdBitsR)/N : (responseR'=2) & (iR'=recdBitsR) & (sendR'=1) ;
        //if the party has contacted previously, ignore following rule 2 - may not be needed due to logic in models
        [reqO] (sendO=0 & sendR=0) & responseO>0 -> true ;
        [reqR] (sendO=0 & sendR=0) & responseR>0 -> true ;
        //if other party contaced and was resolved, resolve request as rule 3a
        [reqO] (sendO=0 & sendR=0) & responseO=0 & responseR=1 -> (responseO'=1) & (sendO'=1) ;
        [reqR] (sendO=0 & sendR=0) & responseR=0 & responseO=1 -> (responseR'=1) & (sendR'=1) ;
	//if other party contacted and was rejected and other party had fewer commitment, follow rule 3b
        [reqO] (sendO=0 & sendR=0) & responseO=0 & responseR=2 & iR<recdBitsO & recdBitsO<=N -> recdBitsO/N : (responseO'=1) & (sendO'=1) + (N-recdBitsO)/N : (responseO'=2) & (sendO'=1) ;
        [reqR] (sendO=0 & sendR=0) & responseR=0 & responseO=2 & iO+1<recdBitsR & recdBitsR<=N -> recdBitsR/N : (responseR'=1) & (sendR'=1) + (N-recdBitsR)/N : (responseR'=2) & (sendR'=1) ;
        //if other party contacted, was rejected and had more commitments, reject following rule 3c
	[reqO] (sendO=0 & sendR=0) & responseO=0 & responseR=2 & iR>=recdBitsO -> (responseO'=2) & (sendO'=1) ;
        [reqR] (sendO=0 & sendR=0) & responseR=0 & responseO=2 & iO+1>=recdBitsR -> (responseR'=2) & (sendR'=1) ;

        [replyO] sendO=1 -> (sendO'=0) ;
        [replyR] sendR=1 -> (sendR'=0) ; 

endmodule
