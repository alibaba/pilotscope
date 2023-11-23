/*-------------------------------------------------------------------------
 *
 * send_and_receive.c
 *	  Routines to send PilotTransData to python side.
 * 
 * We send data back to python side here. Note that we are able to reinit and 
 * resend the data if we don't receive response. However, the times we redo the above
 * operation is limited, which could tune MAX_SEND_TIMES in "utils/pilotscope_config.h".
 * In addtion, we could tune WAITE_TIME to decide how much time we should wait to receive
 * data.
 * 
 * The following is an example of json needed to sent: 
 * {
 * "tid": "1234",
 * "parser_time": "0.000051",
 * "http_time": "1234567809.123456",
 * "subquery":
 * [
 *   "select count(*) from comments c;",
 *   "select count(*) from posts p where p.answercount <= 5 and p.favoritecount >= 0 and p.posttypeid = 2;",
 *   "select count(*) from comments c, posts p where c.postid = p.id and p.answercount <= 5 and p.favoritecount >= 0 and p.posttypeid = 2;"
 * ],
 * "card":
 * [
 *   "174305.000",
 *   "3157.472",
 *   "5982.875"
 * ],
 * "anchor_names":
 * [
 *   "SUBQUERY_CARD_PULL_ANCHOR"
 * ],
 * "anchor_times":
 * [
 *   "0.000129"
 * ]
 *}
 *
 * Attributes:
 *      tid:the process ID used by python side
 * 		parser_time:the time of parsing json
 * 		http_time:the moment sending data to python side
 * 		subquery:relative subqueries needed by subquery_card_pull_anchor
 * 		card:cards needed by subquery_card_pull_anchor
 * 		anchor_names:the anchor names needed to record time 
 * 		anchor_times:the time of dealing anchors, which are aligned with anchor_names
 * 
 * Copyright (c) 2023, Damo Academy of Alibaba Group
 * -------------------------------------------------------------------------
 */

#include "pilotscope/send_and_receive.h"
static void init_and_reinit_http();
static int send_and_resend(char* string_of_pilottransdata);

/*
 * Send PilotTransData back to python side and resend it if necessary. We design the resending policy to 
 * deal with the case when the python side start up slowly. Moreover, some relative parameters in "utils/pilotscope_config.h"
 * could be tuned to adapt to more circumstances.
 */
int send_and_receive(char* string_of_pilottransdata)
{
	init_and_reinit_http();
	int send_flag = send_and_resend(string_of_pilottransdata);
	return send_flag;
}

// init and reinit
static void init_and_reinit_http()
{
   /*
	* Create http connection here. We will recreate it if failed as if 
	* the time is no more than MAX_SEND_TIMES. Otherwise, we will just report
	* the failure information and return.
	*/
	int init_times = 1;
	while(init_http_conn() == -1)
	{			
		if(++init_times>MAX_SEND_TIMES)
		{
			elog(INFO,"Reach the maximum number of initing times!");
			return 0;
		}
		else
		{
			elog(INFO,"Init the http error!! Reiniting...");
			sleep(WAITE_TIME);			
		}
	}
}

// send and receive
static int send_and_resend(char* string_of_pilottransdata)
{
	// send
	int send_times = 1;
	send_data(&t_client, string_of_pilottransdata);

	// receive、resend
	int sockfd = t_client.socket;
	int n;

   /*
	* rset:the set of file description,which will be listened
	* timeout:the struct of timeval,which are used to set wait time
	*/
	fd_set rset;
	struct timeval timeout;

	while (1)
	{	
		// reach the maximum number of sending times
		if(send_times == MAX_SEND_TIMES)
		{
			elog(INFO,"Reach the maximum number of sending times!");
			return 0;
		}

		// add socket which needs to be listened to rset
		FD_ZERO(&rset);
		FD_SET(sockfd, &rset);

		// set wait time
		timeout.tv_sec = WAITE_TIME; 
		timeout.tv_usec = 0;

	   /*
		* Select is used to listen muti file description.Here is used to listen socket.
		* Listen whether there is data in socket or not, break if select error（-1）
		* Note that return value will be more than 0 if there is data and will be equal to 0 if it is
		* time out.If there is data in socket,the file description socket in file description set will be set to 1.
		*/
		if (select(sockfd + 1, &rset, NULL, NULL, &timeout) == -1) 
		{
			elog(INFO, "Error in select: %s", "out of memory!");
			break;
		}

		// there is data in socket if file description socket in file description set is set to 1
		if (FD_ISSET(sockfd, &rset)) 
		{				
			char* response;
			// try to receive data
			n = recv_data(&t_client,string_of_pilottransdata,&response);

			// failed to receive if n<0 otherwise succeed
			if (n < 0) 
			{
				elog(INFO,"HTTP status code is not 200. Error may occur in the python side.\n");
				break;
			}

		   /*
			* Succeed to receive "ok" and then try to close socket
			*
			* the second parameter:
			* 0 Stop receiving data for this socket. If further data arrives, reject it.
			* 1 Stop trying to transmit data from this socket. Discard any data waiting to be sent. 
			* Stop looking for acknowledgement of data already sent; don’t retransmit it if it is lost.
			* 2 Stop both reception and transmission.
			*/
			int close_flag = shutdown(t_client.socket,2);

			// judge if successfully close socket
			if(close_flag == 0)
			{
				elog(INFO,"Close socket succeed!");
			}
			else
			{
				elog(INFO,"Close socket failed!");
			}
			
			// send and receive done! break "while" and ready to return
			elog(INFO,"Send and receive succeed!");
			break;
		}
		// no data
		else
		{
			// timeout and resend
			elog(INFO,"Timeout!! Resending data...");
			send_data(&t_client, string_of_pilottransdata);
			send_times++;
		}
	}
	
	// close fd
	close(sockfd);
	return 1;
}