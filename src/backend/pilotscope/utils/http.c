/*-------------------------------------------------------------------------
 *
 * http.c
 *	  Routines to provide http service for sending and receiving data.
 *
 *  -------------------------------------------------------------------------
 */

#include "pilotscope/http.h"

static int http_tcpclient_create(http_tcpclient *pclient,const char *host, int port);
static int http_tcpclient_conn(http_tcpclient *pclient);
static int http_tcpclient_recv(http_tcpclient *pclient,char **lpbuff,int size);
static int http_tcpclient_send(http_tcpclient *pclient,char *buff,int size);

http_tcpclient t_client;

// create(tcp)
static int http_tcpclient_create(http_tcpclient *pclient, const char *host, int port)
{
    struct addrinfo hints, *result, *p;
    int status;

    // init
    memset(pclient, 0, sizeof(http_tcpclient));
    memset(&hints, 0, sizeof(hints));

    hints.ai_family = AF_UNSPEC;    
    hints.ai_socktype = SOCK_STREAM;

    if ((status = getaddrinfo(host, NULL, &hints, &result)) != 0) {
        fprintf(stderr, "getaddrinfo error: %s\n", gai_strerror(status));
        return -1;
    }

    for (p = result; p != NULL; p = p->ai_next) 
	{
            struct sockaddr_in *addr_in = (struct sockaddr_in *)(p->ai_addr);
            pclient->_addr.sin_family = AF_INET;
            pclient->_addr.sin_port = htons(port);
            pclient->_addr.sin_addr = addr_in->sin_addr;
            strncpy(pclient->remote_ip, inet_ntoa(addr_in->sin_addr), INET_ADDRSTRLEN);
            break;
    }

    freeaddrinfo(result);

    if (p == NULL) 
	{
        fprintf(stderr, "No suitable address found.\n");
        return -1;
    }

    if ((pclient->socket = socket(AF_INET, SOCK_STREAM, 0)) == -1) 
	{
		if (errno == EACCES) 
		{
            elog(INFO,"Insufficient privileges to create socket");
        }
        return -1;
    }

    return 0;
}

// connect(tcp)
static int http_tcpclient_conn(http_tcpclient *pclient)
{

	if(connect(pclient->socket, (struct sockaddr *)&pclient->_addr,sizeof(struct sockaddr))==-1)
	{
		return -1;
	}

	pclient->connected = 1;

	return 0;
}

// receive(tcp)
static int http_tcpclient_recv(http_tcpclient *pclient,char **lpbuff,int size)
{
	int recvnum=0,tmpres=0;
	char buff[HTTP_RECEIVE_BUFFER_SIZE];
	*lpbuff = NULL;

	while(recvnum < size || size==0)
	{
		tmpres = recv(pclient->socket, buff,HTTP_RECEIVE_BUFFER_SIZE,0);
		if(tmpres <= 0)
			break;

		recvnum += tmpres;

		if(*lpbuff == NULL)
		{
			*lpbuff = (char*)malloc(recvnum);

		}
		else
		{
			*lpbuff = (char*)realloc(*lpbuff,recvnum);

		}

		memcpy(*lpbuff+recvnum-tmpres,buff,tmpres);
	}

	return recvnum;
}

// send(tcp)
static int http_tcpclient_send(http_tcpclient *pclient,char *buff,int size)
{
	int sent=0,tmpres=0;

	while(sent < size)
	{
		tmpres = send(pclient->socket,buff+sent,size-sent,0);
		if(tmpres == -1)
		{
			return -1;
		}
		sent += tmpres;
	}
	return sent;
}

// connect(http)
int init_http_conn()
{ 
    // create
	int stt;
    elog(INFO, "Ready to creating socket...");
    if ((stt = http_tcpclient_create(&t_client, host, port)) == -1) 
    {
        elog(INFO, "Create socket error.");
        return stt;
    }
	else
	{
		elog(INFO, "Create socket successfully.");
	}

	// connect
	elog(INFO, "Ready to connect socket...");
    if ((stt = http_tcpclient_conn(&t_client)) == -1) 
    {
		elog(INFO, "Connect srv error.");
    }
    else
    {
        elog(INFO, "Connect success.");
    }

    return stt;
}

// send(http)
int send_data(http_tcpclient *pclient,char *string_of_pilottransdata)
{
	char *lpbuf;
	int	len;
	char	h_post[HTTP_HEADER_LENGTH], h_host[HTTP_HEADER_LENGTH], h_content_len[HTTP_HEADER_LENGTH], h_content_type[HTTP_HEADER_LENGTH];
	const char *h_header="User-Agent: Mozilla/4.0\r\nCache-Control: no-cache\r\nAccept: */*\r\nConnection: Keep-Alive\r\n";

	memset(h_post, 0, sizeof(h_post));
	sprintf(h_post, "POST %s HTTP/1.1\r\n", "flag");
	sprintf(h_host, "HOST: %s:%d\r\n",pclient->remote_ip, pclient->remote_port);
	memset(h_content_type, 0, sizeof(h_content_type));
	sprintf(h_content_type, "Content-Type: application/x-www-form-urlencoded\r\n");
	memset(h_content_len, 0, sizeof(h_content_len));
	sprintf(h_content_len,"Content-Length: %d\r\n", strlen(string_of_pilottransdata));
	len = strlen(h_post)+strlen(h_host)+strlen(h_header)+strlen(h_content_len)+strlen(h_content_type)+strlen(string_of_pilottransdata)+10;
	lpbuf = (char*)palloc(len);
	if(lpbuf==NULL)
	{
		elog(INFO,"palloc error.\n");
		return -1;
	}

	strcpy(lpbuf,h_post);
	strcat(lpbuf,h_host);
	strcat(lpbuf,h_header);
	strcat(lpbuf,h_content_len);
	strcat(lpbuf,h_content_type);
	strcat(lpbuf,"\r\n");
	strcat(lpbuf,string_of_pilottransdata);
	strcat(lpbuf,"\r\n");

	if(http_tcpclient_send(pclient,lpbuf,len)<0)
	{
		return -1;
	}
	
	return 0;
}

// receive(http)
int recv_data(http_tcpclient* pclient,char* string_of_pilottransdata,char** response)
{
	char *lpbuf;
	int	len;
	char status_code[HTTP_HEADER_LENGTH];

	// reveive
	http_tcpclient_recv(pclient,&lpbuf,0);

	// get http status code
	memset(status_code,0,sizeof(status_code));
	strncpy(status_code,lpbuf+9,3);
	if(atoi(status_code)!=200)
	{
		return -1;
	}

	return 0;
}