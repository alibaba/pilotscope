--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1
-- Dumped by pg_dump version 13.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: aka_name; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aka_name (
    id integer NOT NULL,
    person_id integer NOT NULL,
    name character varying,
    imdb_tiny_index character varying(3),
    name_pcode_cf character varying(11),
    name_pcode_nf character varying(11),
    surname_pcode character varying(11),
    md5sum character varying(65)
);


-- ALTER TABLE public.aka_name OWNER TO postgres;

--
-- Name: aka_title; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aka_title (
    id integer NOT NULL,
    movie_id integer NOT NULL,
    title character varying,
    imdb_tiny_index character varying(4),
    kind_id integer NOT NULL,
    production_year integer,
    phonetic_code character varying(5),
    episode_of_id integer,
    season_nr integer,
    episode_nr integer,
    note character varying(72),
    md5sum character varying(32)
);


-- ALTER TABLE public.aka_title OWNER TO postgres;

--
-- Name: cast_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cast_info (
    id integer NOT NULL,
    person_id integer NOT NULL,
    movie_id integer NOT NULL,
    person_role_id integer,
    note character varying,
    nr_order integer,
    role_id integer NOT NULL
);


-- ALTER TABLE public.cast_info OWNER TO postgres;

--
-- Name: char_name; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.char_name (
    id integer NOT NULL,
    name character varying NOT NULL,
    imdb_tiny_index character varying(2),
    imdb_tiny_id integer,
    name_pcode_nf character varying(5),
    surname_pcode character varying(5),
    md5sum character varying(32)
);


-- ALTER TABLE public.char_name OWNER TO postgres;

--
-- Name: comp_cast_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comp_cast_type (
    id integer NOT NULL,
    kind character varying(32) NOT NULL
);


-- ALTER TABLE public.comp_cast_type OWNER TO postgres;

--
-- Name: company_name; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company_name (
    id integer NOT NULL,
    name character varying NOT NULL,
    country_code character varying(6),
    imdb_tiny_id integer,
    name_pcode_nf character varying(5),
    name_pcode_sf character varying(5),
    md5sum character varying(32)
);


-- ALTER TABLE public.company_name OWNER TO postgres;

--
-- Name: company_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company_type (
    id integer NOT NULL,
    kind character varying(32)
);


-- ALTER TABLE public.company_type OWNER TO postgres;

--
-- Name: complete_cast; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.complete_cast (
    id integer NOT NULL,
    movie_id integer,
    subject_id integer NOT NULL,
    status_id integer NOT NULL
);


-- ALTER TABLE public.complete_cast OWNER TO postgres;

--
-- Name: info_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.info_type (
    id integer NOT NULL,
    info character varying(32) NOT NULL
);


-- ALTER TABLE public.info_type OWNER TO postgres;

--
-- Name: keyword; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.keyword (
    id integer NOT NULL,
    keyword character varying NOT NULL,
    phonetic_code character varying(5)
);


-- ALTER TABLE public.keyword OWNER TO postgres;

--
-- Name: kind_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kind_type (
    id integer NOT NULL,
    kind character varying(15)
);


-- ALTER TABLE public.kind_type OWNER TO postgres;

--
-- Name: link_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.link_type (
    id integer NOT NULL,
    link character varying(32) NOT NULL
);


-- ALTER TABLE public.link_type OWNER TO postgres;

--
-- Name: movie_companies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.movie_companies (
    id integer NOT NULL,
    movie_id integer NOT NULL,
    company_id integer NOT NULL,
    company_type_id integer NOT NULL,
    note character varying
);


-- ALTER TABLE public.movie_companies OWNER TO postgres;

--
-- Name: movie_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.movie_info (
    id integer NOT NULL,
    movie_id integer NOT NULL,
    info_type_id integer NOT NULL,
    info character varying NOT NULL,
    note character varying
);


-- ALTER TABLE public.movie_info OWNER TO postgres;

--
-- Name: movie_info_idx; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.movie_info_idx (
    id integer NOT NULL,
    movie_id integer NOT NULL,
    info_type_id integer NOT NULL,
    info character varying NOT NULL,
    note character varying(1)
);


-- ALTER TABLE public.movie_info_idx OWNER TO postgres;

--
-- Name: movie_keyword; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.movie_keyword (
    id integer NOT NULL,
    movie_id integer NOT NULL,
    keyword_id integer NOT NULL
);


-- ALTER TABLE public.movie_keyword OWNER TO postgres;

--
-- Name: movie_link; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.movie_link (
    id integer NOT NULL,
    movie_id integer NOT NULL,
    linked_movie_id integer NOT NULL,
    link_type_id integer NOT NULL
);


-- ALTER TABLE public.movie_link OWNER TO postgres;

--
-- Name: name; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.name (
    id integer NOT NULL,
    name character varying NOT NULL,
    imdb_tiny_index character varying(9),
    imdb_tiny_id integer,
    gender character varying(1),
    name_pcode_cf character varying(5),
    name_pcode_nf character varying(5),
    surname_pcode character varying(5),
    md5sum character varying(32)
);


-- ALTER TABLE public.name OWNER TO postgres;

--
-- Name: person_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person_info (
    id integer NOT NULL,
    person_id integer NOT NULL,
    info_type_id integer NOT NULL,
    info character varying NOT NULL,
    note character varying
);


-- ALTER TABLE public.person_info OWNER TO postgres;

--
-- Name: role_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_type (
    id integer NOT NULL,
    role character varying(32) NOT NULL
);


-- ALTER TABLE public.role_type OWNER TO postgres;

--
-- Name: title; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.title (
    id integer NOT NULL,
    title character varying NOT NULL,
    imdb_tiny_index character varying(5),
    kind_id integer NOT NULL,
    production_year integer,
    imdb_tiny_id integer,
    phonetic_code character varying(5),
    episode_of_id integer,
    season_nr integer,
    episode_nr integer,
    series_years character varying(49),
    md5sum character varying(32)
);


-- ALTER TABLE public.title OWNER TO postgres;

--
-- Data for Name: aka_name; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.aka_name (id, person_id, name, imdb_tiny_index, name_pcode_cf, name_pcode_nf, surname_pcode, md5sum) FROM stdin;
1	4061927	Smith, Jessica Noel	\N	S5325	J2542	S53	25c9d464e3ff2957533546aa92b397ed
2	4	Short, Too	\N	S63	T263	\N	4e26116e5f9800cef90c8f8c38de2584
3	2701136	Abdul-Hamid, Jaffar	\N	A1345	J1613	\N	fb5126fe9992e13156c636d726cec257
4	2701136	Al-Hamid, Jaffar Abd	\N	A4532	J1613	A453	179ad5f75c84c4bddd6733c66b6b0bb7
5	15	Viera, Michael 'Power'	\N	V6524	M2416	V6	354cea2b99f8b1f745ea6092eefa2bd7
6	19	Buguelo	\N	B24	\N	\N	58514bbd66ce4d1da4e18bf8d348a15f
7	3564316	Seigal, Jason	\N	S2425	J2524	S24	580ac2a3356b6186bbe876cb0e4087a7
8	59	Starks, Johnny	\N	S3625	J5236	S362	f05bc5fab74cc0106f8942f51c9ad39d
9	68	Monkey	\N	M52	\N	\N	4126964b770eb1e2f3ac01ff7f4fd942
10	69	'Morità'	\N	M63	\N	\N	3df36469bd82f19b816b36bc4d863eaa
11	72	Mark'Oh	\N	M62	\N	\N	391da8cc4741c9e7b7d9265fcad7f680
12	3564319	Friedberg, Shaun	\N	F6316	S5163	\N	6b4a7c8f95e0fad958b369b5e261fa21
13	3564319	friedberg, shaun	\N	F6316	S5163	\N	46ec203e1dfe14be65af33100d79cb1b
14	85	Troupe, the 'Stretch' Cox	\N	T6132	T2363	T61	0f9eabbe9fd507a7476a44d9300595a4
15	86	Hart, Maarten	\N	H6356	M6356	H63	c91e32e61bbe03bb728d0fbcf0fcd5d1
16	92	Hooft, Drs. Dick 't	\N	H1362	D6232	H13	b655ab359f02edf5bbd6a741fd77ab02
17	93	Hooft, Prof. Ir. 't	\N	H1316	P6163	H13	f6ea3ad66d1269548b8ae76f6fc67cc9
18	94	t'Hooft, Maarten	\N	T1356	M6353	T13	930462751ccc755fc58d51bd294d8dd2
19	95	t'Hooft, Quinten	\N	T1325	Q5353	T13	004596df82087946b75f70088a9e7b93
20	113	N'Sync	\N	N252	\N	\N	9530df869ee451ff8e9dd1367e8fca15
21	157	Special, 38	\N	S124	\N	\N	0dcbefda68bec8d910187aea1aed7d21
22	161	Todd-1	\N	T3	\N	\N	b1a94016b727b1c2084f390da4a8cd36
23	163	AG, 1. Wiener Pawlatschen	\N	A2561	W5614	A2	2014e153625797af3efa5c33712b7ec6
24	182	Jones, Nick	\N	J5252	N252	J52	c13daf86dfa053285e0944eedf299383
25	192	Lovat, Lord	\N	L1346	L6341	L13	5d57e1539618f565614c9f809541fa0c
26	207	Posse, Insane Clown	\N	P2525	I5252	P2	80522a5e0c697c2a0e170d5822bd203c
27	207	Posse, Shaggy 2 Dope of Insane Clown	\N	P2315	S2315	P2	fea9dacdd681869f4331fd22e0d26b46
28	216	2-ply	\N	P4	\N	\N	f75c89146404a22d582ea6194da9d1de
29	216	2Ply	\N	P4	\N	\N	d6d38052ead64bb8a5423997904dbd1a
30	216	Ply, 2	\N	P4	\N	\N	2e05dd511f4d0d34d0d0669fe48be5bf
31	216	Ply, Two	\N	P43	T14	P4	b2e344169a6c26d25d147552d17a6de3
32	2701154	T-2000	\N	T	\N	\N	40d67e1b09b68eec78c451e0b8fbb54c
33	228	22, CPM	\N	C15	\N	\N	9388a03e0cab7fded6fa343197f15a9e
34	230	Pistepirkko, 22	\N	P2316	\N	\N	13b7d47eeef7af8005e7501e877f169c
35	233	Jackson, Marquise	\N	J2562	M625	J25	7da31e3e9db23ec00f877ef511283bc9
36	248	Karim, Iman Benjamin	\N	K6515	I5152	K65	e68f10e14f2e4c05778972383d3cb70d
37	1739620	3LW	\N	L	\N	\N	02160726ae9e415a8acabdc10d9665bd
38	260	Z'widern, Die 3	\N	Z3653	D2365	Z365	f368dc74d93cab9ea9048f3c58b98b79
39	266	Mars, Thirty Seconds to	\N	M6236	T6325	M62	19aa67a919f884e2f011a7034f23da8a
40	3564339	s.b.j., Inspector 34	\N	S1252	I5212	S12	fe3892e327a63f9ce541a88e2767649c
41	3564339	sbj, Inspector 34	\N	S1252	I5212	S12	feabb0876546690146283a999277dd93
42	1739623	4Ever, Diamond	\N	E1635	D5316	E16	ca138a718ed849f7f83368bd56a82b74
43	1739623	Diamond	\N	D53	\N	\N	8f7671185d590914ac21c7511767b699
44	1739623	Forever, Diamond	\N	F6163	D5316	F616	7417709fb81dc2e4d93b6b3c4edb1c83
45	284	Mayrhofner, 4 Holterbuam & Die	\N	M6156	H4361	\N	84a38bcc6091ee5b55dd7291d466b69d
46	3316880	4-EVER	\N	E16	\N	\N	1bf72bb7f4e8d0b294f9396fd481a39d
47	1739625	'42', Charla Miss	\N	C6452	\N	\N	6170f0bdac73de61033a5236ea6bd272
48	1739626	Candy, Cotton	\N	C5323	C3525	C53	e619ec67b1f050ab66d28049009a82a7
49	1739626	Mountains, Misty	\N	M5352	M2353	\N	80ee9298fbedfaedd6e1f4d1bfa7f1ed
50	306	Band, 48th Highlanders Pipe	\N	B5324	T2453	B53	6baefa6df19672ae34a770281ab21661
51	318	5angels	\N	A5242	\N	\N	493e6bff7f80a876832655140e3a15ca
52	333	Five, Johnny	\N	F125	J51	F1	2e427e64dc5ac79c72e2660997e2b2de
53	333	J5	\N	J	\N	\N	5707c951188f82074eb8ca32a5ae8328
54	339	G-Unit	\N	G53	\N	\N	eed9fac900d9755419448144775de9e0
55	339	Jackson, Curtis '50 Cent'	\N	J2526	C6325	J25	3f6d11ab81023e84dbb57ba5ffb310fe
56	339	Jackson, Curtis '50 cent'	\N	J2526	C6325	J25	d1df6299e55721c84a4fa9fcd2f0e579
57	339	Jackson, Curtis	\N	J2526	C6325	J25	5aa9816ffe324350b788c4fc9f59676d
58	346	Family, 5sta	\N	F5423	S3154	F54	aca4cb396ed9fd13558c4a9f4f496bd5
59	348	Fifth Dimension, The	\N	F1352	T1352	\N	421708576254f3ecf71de6499bf5fa09
60	349	Carnarvon, Lord	\N	C6561	L6326	\N	1a9469e6a9fbbd115ae8694f99e39aaf
61	356	Tefry, Rich	\N	T162	R2316	T16	266befebfbea19985addf17b117b583e
62	356	Terfry, Richard	\N	T6162	R2636	T616	0356c2316cc8459b26e6ab6cdcc826c8
63	356	Terfry, Rich	\N	T6162	R2361	T616	8a47155b16fe8ec053a9ec698c9c9a16
64	358	Malice	\N	M42	\N	\N	d22aa92e1e9482e79e8a58fb42b5b7b4
65	362	Vuori, Jussi	\N	V62	J216	V6	046561e1871b18a5b282609b9dc1e15e
66	363	Linnankivi, Jyrki	\N	L5212	J6245	L521	b0754667e505823e266ae31728ee784b
67	367	Kawesch, Michael	\N	K2524	M242	K2	479f802eb8116e9c17536ae3a5ababa3
68	371	5, Jurassic	\N	J62	\N	\N	b4e557ec5bb3c144fb993e71942022ed
69	371	7even, Marc	\N	E1562	M6215	E15	4da828960f166b48945de61567feae69
70	373	78plus	\N	P42	\N	\N	548c176307786fa8e36cd8a57c850319
71	374	Carnarvon, Lord	\N	C6561	L6326	\N	1a9469e6a9fbbd115ae8694f99e39aaf
72	3493774	8francis	\N	F652	\N	\N	4cfec20b5661ab87587f5de6c547f539
73	387	Carnarvon, 8th Earl of	\N	C6561	T6412	\N	acf5ef15474c141b802bfad9439d281e
74	2701156	ATCQ	\N	A32	\N	\N	a584891f349cd4c236d35f68eb577f1d
75	2701156	Quest, Tribe Called	\N	Q2361	T6124	Q23	6e4ad407e35b2d2778634bf4de699714
76	410	Ahern, Brett	\N	A6516	B6365	A65	d782f2e485cdaec9fee31024a98c1e47
77	1739648	Adam, Isabelle	\N	A3521	I2143	A35	69c227a18212d7ee8918cda9647eb38a
78	1739649	Sola, Ella Baila	\N	S414	E4142	S4	dd8ff0910e439aa5aeb76f0b4c550b38
79	2701161	Solla, Ricardo Álvarez	\N	S4626	R2634	S4	a283484a9224189e32e388b9c088fa76
80	2701161	Álvarez, Ricardo	\N	L1626	R2634	L162	2d9fa17d03585d3597af148dee3a4f4e
81	3228430	Wahib, Mohd Shaufe Bin A.	\N	W1532	M3215	W1	a84597eac4bc7e35384aff4ed82b2908
82	3228431	Aguilar, Javier	\N	A2462	J1624	A246	85373a963c354085f646ee9a0702fbe7
83	443	A, Bobby	\N	A1	B1	A	52bea1a7ff49cf3a1f44d7c3ac740c6f
84	1739653	Jenifer	\N	J516	\N	\N	e7a553fc98cb4d5e01b9a5445e51121b
85	1739653	Jennifer	\N	J516	\N	\N	e1f6a14cd07069692017b53a8ae881f6
86	447	Ané, Dominique	\N	A5352	D525	A5	df8a2f584bcbc5c6da4376e13921ebad
87	3316905	Akhi, Haji	\N	A2	H2	\N	30d7daff153d9a7298abe0baa6f4f9c5
88	3316905	Akhigbad, Haji	\N	A2132	H213	A213	9cb7e6e306a1e07c9c3ea0752a8f4adc
89	2701164	J.M.A.	\N	J5	\N	\N	d95e03b7c8387a22a747daa0f421208b
90	1739657	Asadolahzadeh, Jacqueline	\N	A2342	J2452	\N	2af4151509029b6f5ba7950d13b16747
91	2701165	A, James	\N	A252	J52	A	c7463eaa779f8f6c67661c0f7129d5dc
92	454	Joe	\N	J	\N	\N	3a368818b7341d48660e8dd6c5a77dbe
93	457	Reddy, A. Kondandarami	\N	R3253	A2535	R3	fd8bd81428f32a5dd840db6138b28627
94	460	A, Love	\N	A41	L1	A	ed7327d86053efa43b62eb85bcda061c
95	2701166	Susheela, A. Naga	\N	S2452	A524	S24	4ba44b202f6ac1b3a7b2186b47b56e33
96	3441946	Rao, A. Nageswara	\N	R526	A526	R	181dd6e6cfe6e9b5d082bec1411ab843
97	2701167	Ramesh, A.	\N	R52	A652	\N	cb52381ea3c0f65db87c95f9153298b0
98	4061928	Satyanarayana	\N	S3565	\N	\N	ff246140f4e53a896ad2182302530cb6
99	1739668	Aryatyny, Tyfany	\N	A6353	T1563	A635	d359e0ccd912b2042f226590063fa216
100	1739669	Julia	\N	J4	\N	\N	2344521e389d6897ae7af9abf16e7ccc
101	1739669	Laura	\N	L6	\N	\N	37905b9b4fdb8fa311b30448254d51fe
102	1739669	Lela	\N	L4	\N	\N	1c430c0d7c4f73b26be27f3b185ed565
103	1739669	Lucia	\N	L2	\N	\N	8a2efc47e17952c1ea90c9cee4ba38ec
104	1739669	S., Laura	\N	S46	L62	S	f57d5ac1b24e24f9421575d232a272d3
105	1739669	Vanda	\N	V53	\N	\N	96b208a1275d4c90d71227febe95e60a
106	1739671	A, Venomous	\N	A152	V52	A	609baf739ec9aa046c74e9e52c102218
107	1739671	A., Venemous	\N	A152	V52	A	7e55a30c3cdf950314f2820754fc6c86
108	498	ADG	\N	A32	\N	\N	eacd35c6698fce660af30a38a75242d3
109	504	Chloe, AJ &	\N	C42	A24	C4	5b0849fa5546f4a41dbf2ea9e60cad2e
110	505	Calloway, Albert	\N	C4163	A4163	C4	d553a971d69a4084b0d83971711887a6
111	508	AJ, DJ	\N	A232	D2	A2	6d90dd848bddde4732d0cc2c1872ddb2
112	516	Defelice, Al	\N	D1424	A4314	D142	955d0c07052791e96e48b60efdaa44a5
113	516	Defino, A.J.	\N	D152	A2315	D15	9edebccaefaef99eca0369f4d90dcde3
114	516	Eight, A.J.	\N	E232	A23	E23	3d727d5edfd05773c9dfeb1e53c675e4
115	2701170	Scott, Eric M.	\N	S2362	E6252	S23	1504ac973548b28e0cfbbf43d699a006
116	4061929	Pereira, Marcelo M.	\N	P6562	M6245	P6	8c90ba4da922e4bd60e12beaa54f75e5
117	532	Dancers, ASF	\N	D5262	A2135	\N	543d22e4cb742bf390a601d007d3731c
118	536	AXL	\N	A24	\N	\N	0d2e5fdc1cfe93acb1c31ff0346e5cc8
119	4061930	Genius, Savage	\N	G5212	S1252	G52	7c6abf2ad88fc1046aeb40f8ab460b8d
120	3564360	Aabach, Mohamed	\N	A1253	M5312	A12	f8a484fff8cd77233dc4cf1e498dd34f
121	3564360	Abach, Mohamed	\N	A1253	M5312	A12	290a4df40b1b762a84b1db32e9bbe693
122	3228437	Aabeck, Bjørk	\N	A1212	B2621	A12	5db563af48786e5bf61bf28f92ce6edb
123	544	Aabel, Hauk Erlendsson	\N	A1426	H2645	A14	e18a0a19feb9b88fc3247ac8e9988f36
124	545	Aabel, Per Pavels	\N	A1416	P6142	A14	3856fb1f6078094aa0792368dcfe6279
125	4061931	Aabrandt, Jonas	\N	A1653	J5216	\N	5c04a766c675769435a1161c494de6a3
126	556	Rune	\N	R5	\N	\N	201011842cd44b96c4ed73dcff80ac1f
127	4061932	Aabye, Emilie Grossos	\N	A1542	E5426	A1	839d60243d04909ece7a19e476e42936
128	4061932	Aabye, Emilie	\N	A154	E541	A1	90e6965bf7411c21f9f201fcd2b5686a
129	562	Aadahl, Eric	\N	A3462	E6234	A34	6c94296d7c180931ff954b41ab23fe7e
130	564	Pradeep	\N	P631	\N	\N	7c55534f2e840f2a38c1077bcbb2f645
131	1739690	Adland, Beverly	\N	A3453	B1643	\N	373b394ab62ec0dddcc4389e2520ee02
132	4036924	Aes, Éric	\N	A262	R2	A2	7e519f0953ad2467164e104c911738ef
133	594	Nielsen, Lasse Aagaard	\N	N4254	L2635	N425	efeafb5ce40af6e8c226aad4017da27e
134	597	Aagaard, Sebastian	\N	A2632	S1235	A263	9ded7d1dd828333e531180c4d644b4ff
135	597	B-Boys	\N	B12	\N	\N	f00a839e1fe9a3784f0abf1887f36c40
136	597	Sebastian	\N	S1235	\N	\N	b69eb4ca4b4ae19e8e4f2e3129da7fd3
137	4061933	Aagaard, Dan	\N	A2635	D5263	A263	35cc037a57a6f5fdbb772a31beb51dc8
138	600	Ph.D., Earl Aagard	\N	P3642	E6426	P3	b653542315cf9f2e6e80af5da670f189
139	4061934	Aagedal, Thor-Ole	\N	A2343	T6423	A234	28b825eac5b971b774746c5d8a1230f2
140	605	Aagesen, Kristoffer	\N	A2526	K6231	A25	0924c2b89839a2ad2349a095b6a701b4
141	4061935	Aagaard, Eirik Holst	\N	A2636	E6242	A263	5449580c4ab983e12006ae25cfbfabb4
142	2701189	Safdar, Dr.	\N	S1363	D6213	S136	ba1e17088a434c95fe02c197e6638091
143	4061936	Ajgaonkar, Satish	\N	A2526	S3252	\N	2a01e3a145a505559681745916740a67
144	4061936	Satish	\N	S32	\N	\N	46aef51e6a8aa34dbd0482d9d01fcef7
145	616	Aakash, Master	\N	A2523	M2362	A2	90c7c310fbba8d4f8783003518519924
146	616	Jagannadh, Aakash	\N	J2532	A253	J253	87d674620ea8946ce5776efb91c302e4
147	616	Jagannath, Aakash	\N	J2532	A253	J253	6c1808677e544afd1528613e19dbe51d
148	616	Petla, Aakash	\N	P342	A2134	P34	2338f8427c33f6220e7d4a4c36935099
149	616	Puri, Aakash	\N	P62	A216	P6	9c58be818ad1321ab7a3409c477b405f
150	618	Akash, Ved	\N	A213	V32	A2	5af8e58af01569e62fc400d4edc0295d
151	624	Aaker, Lee William	\N	A2645	L4526	A26	768c802f5cf03c88bf4587f6957c52c6
152	626	Fupz, Kim	\N	F125	K512	F12	6eeca5d409c75bb023a09eb4e25e0b5f
153	3441953	Akkoo	\N	A2	\N	\N	54ccc7fe02d882b6be34a6e4b7acd941
154	2701191	Akkoo	\N	A2	\N	\N	54ccc7fe02d882b6be34a6e4b7acd941
155	1739727	Akruti	\N	A263	\N	\N	ccce606581de1ff8970981f9e5134279
156	4061937	Al, Amir	\N	A456	A564	A4	ffbc896748216dec0e86c9de1823892f
157	636	Aalam, Abou-Bakre	\N	A4512	A1264	A45	ae8cd2213a0c7a952466114261a22db7
158	636	Aalam, Steve Abou-Bakre	\N	A4523	S3126	A45	ba7d88ca5a63bc7daac78b943b776142
159	636	Aalam, Steve Aries	\N	A4523	S3162	A45	8e29d58c3eb029019c6ca328c2cfb7ab
160	4061938	Aaborg, Jonas	\N	A1625	J5216	A162	c120810e7a1beb84309d23b180b6d6ac
161	1739739	Sisters, Aalbu	\N	S2362	A4123	\N	8d325c4f225867686a7e406f94a1329d
162	1739741	Sisters, Aalbu	\N	S2362	A4123	\N	8d325c4f225867686a7e406f94a1329d
163	1739742	Sisters, Aalbu	\N	S2362	A4123	\N	8d325c4f225867686a7e406f94a1329d
164	1739743	Sisters, Aalbu	\N	S2362	A4123	\N	8d325c4f225867686a7e406f94a1329d
165	648	Aalbæk, Niels	\N	A4125	N4241	A412	a6b94a83dce42e5e332c39a0943c3ded
166	1739747	Stikkelorum, Mairen	\N	S3246	M6523	\N	7579dfd2be8d1c8ace13812ca697ee28
167	1739752	Aliya	\N	A4	\N	\N	bf4621e979026615e76cd80138e15b57
168	1739753	Haughton, Aaliyah Dana	\N	H2354	A4352	H235	1ac1224b4a4a62863e1eacb80bb19481
169	1739753	Haughton, Aaliyah	\N	H2354	A4235	H235	3a195dff94e51c9f9e807ef577390daf
170	1739753	Houghton, Aaliyah	\N	H2354	A4235	H235	c99084630bc1a40727fb6bacb4598da9
171	667	Aalto, Pääjoht. Erkki	\N	A4312	P2362	A43	d4d8372a9d86c8d5b970c7a372e1d35e
172	1739765	Tuunanen, Inkeri	\N	T526	I5263	T5	054fe85ce033c0b0178d6dd995bac2e3
173	671	Aalto, Jussi	\N	A432	J243	A43	73def89ac92e62f875c175790beaa275
174	682	Aalto, Rotislav	\N	A4363	R3241	A43	b5e9da945a7883f622b26477e6282108
175	1739790	Aaltonen, Minna-Ella	\N	A4354	M5435	A435	c3c8b249dab0af508af2a5922e9d3303
176	725	Aaltonen, Henry Olavi	\N	A4356	H5641	A435	9d0280b03f0094cae76d3d066d5a5578
177	725	Hurriganes, Remu &	\N	H6252	R5625	\N	6815f1cdeee9b497df41638982af0610
178	725	Hurriganes	\N	H6252	\N	\N	2eaace4a3e1f649ac13f3bf5170731cb
179	3063844	Aaltonen-Autio, Toini	\N	A4353	T5435	\N	8cab4dd83d2a7ea00b73288c7a75c299
180	3063844	Autio, Toini	\N	A35	T53	A3	7888d605aae3d74d12365dfc04fe75d6
181	1739794	Aaltonen, Ulla-Maija	\N	A4354	U4524	A435	e55f774185ac79713a6c1abb9e6721fd
182	746	Aames, Dr. Bruce	\N	A5236	D6162	A52	3bd0c83563f6d49aafa64c5e06096de7
183	750	Ames, Willie	\N	A524	W452	A52	6957d970364a159a6817ac8010d91980
184	756	Aamodt, Thor M.	\N	A5365	T653	A53	eab8f0b7a9ba61777f948decad4d7d14
185	756	Aamodt, Thor	\N	A536	T653	A53	9f100d7be1f96e43abc2735d3ba7ccee
186	756	Aamodt, Tore	\N	A536	T653	A53	0c9963fcdfcb847d9db623d1391f4be2
187	756	Aamot, Thor	\N	A536	T653	A53	d1ffab7aea26fa41c6f199fe2a0b1bcf
188	1739807	Aamold, Kathleen	\N	A5432	K3454	A543	e8caceca83211211627e11487eab2ac8
189	1739807	Arnold, Kathleen	\N	A6543	K3456	\N	036473492659f62e3ba948a9b5fb13c6
190	1739807	Asmold, Kathleen	\N	A2543	K3452	\N	f344308673a0e0a3a7a00fde167c5e8b
191	1739808	C-Kat	\N	C23	\N	\N	d74a1a113f27092bc6b0b45a3944d429
192	771	Aanesen, Peter	\N	A5251	P3652	A525	d2187ceb1920511f936f4675283817c3
193	771	Annensen, Peter	\N	A5251	P3652	A525	179eee8b67a915d94fe8d986c7dca4fe
194	4061939	Aananson, Jason	\N	A5252	J2525	A525	7ee3c8fee08e94fe9d00e90e6857d9a4
195	4061940	Aanonsen, Erik	\N	A5256	E6252	A525	67a02778e7a78e31972427688993ee2c
196	781	Puupponen, Simo	\N	P1525	S515	P15	305ce985984711a9285fad7c915d212e
197	787	MD, Bizhan Aarabi	\N	M3125	B2561	M3	d17fc829942eea48876ad101a6c7b1ab
198	789	Aaron, Steve	\N	A6523	S3165	A65	8b304e49d8b38be15fc1dc495f0dcc33
199	794	Aard, Frank	\N	A6316	F6526	A63	2faacd613902a231f9ec3f703c6de291
200	4061941	Aardal, Edward	\N	A6343	E3636	A634	90e8c8a1063f8cc6546f5d9011476066
201	4061941	Aardal, Ed	\N	A6343	E3634	A634	93ebccef17c9d620b4edfaea243a7071
202	4061941	Aardel, Ed	\N	A6343	E3634	A634	de809c80844c5bc874f96032b14b393a
203	3564408	Aardal, John D.	\N	A6342	J5363	A634	84a834e811dae0d82edf6e239879b78f
204	4061942	Aardwerk, Bob	\N	A6362	B1636	\N	9b5a39ec00ea3dfab089d0187c2ee449
205	803	Aardvark-Bagpuss, Fritz	\N	A6316	F6326	\N	6dcc63eb41c43334cd3931a2ed6d2da4
206	4061943	Aaris, H. Barclary	\N	A6216	H1624	A62	b8749017cddea9fb3e6f4d9f8a841100
207	4061943	Aaris, H.B.	\N	A621	H162	A62	ef4871c7eece5dd6ce1d83a31496b34b
208	819	Aaris, Jan H.	\N	A625	J562	A62	d39d93086937c71a5782977fc3dbc986
209	819	Arris, Jan H.	\N	A625	J562	A62	a3a3327ce9d5db859d7ad245e9771199
210	1739837	Aarn, Kimberliegh	\N	A6525	K5164	A65	cd17b7d31e70140263accf202cd2a743
211	1739837	Burroughs, Kimberleigh	\N	B6251	K5164	B62	66b02ac46dae0d2d7a825e60f279f4c5
212	828	Aarnio, Carl 'Kalle'	\N	A6526	C6424	A65	4dc2231438b704a2935113ab32fa2c4a
213	832	Agit-Prop	\N	A2316	\N	\N	27fbb653f2ff6d3d277eaac2957630e5
214	836	Aarniokoski, Doug T.	\N	A6523	D2365	A652	d7314fba0314bc6d1b997fba0e19a3b8
215	836	Aarniokoski, Doug	\N	A6523	D2652	A652	313fd9c399e988dfe0ab8350a02775e7
216	836	Aarniokowski, Doug	\N	A6523	D2652	A652	d217f0262246260f6240675bf0389670
217	836	Cassius, Arnold	\N	C2654	A6543	C2	27162a1753996c3d32c77238747df458
218	838	Aarniste, André	\N	A6523	A5365	\N	544f2021bdc6a6f4583b7568a6703f6f
219	4061944	Arnseth, Pål	\N	A6523	P4652	\N	c4856a91c7066d0c963f43bf5ff05340
220	862	Aash, Aaron	\N	A265	A652	A2	407eb402dd8ba7aa1d061c471b60b63d
221	1739850	Aaron, Mrs.	\N	A6562	M6265	A65	7f18c6eca0674c8d75f31cf5f9c04bf1
222	865	Aaron, Andrew	\N	A6536	A5365	A65	57a419d0cacd51e5efd40768b7be71cf
223	1739854	'Miss Ann Marie'	\N	M256	\N	\N	25c5d0489b8848fa98f2b8cc8062b9aa
224	874	Aaron, Braden	\N	A6516	B6356	A65	58d0575dd15fd7b9003a89612dc06009
225	874	Stone, Braden	\N	S3516	B6352	S35	2bad75fafced7d9aec4474bdb6c182fe
226	3564423	Ph.D., Daryl Aaron D.Min.	\N	P3646	D6465	P3	8ac69b62af6b2e963a48b3249b22c05e
227	3564425	Aarons, David	\N	A6523	D1365	A652	a53222f257ccbdd5fcd27f039ea2c561
228	890	Aaron, Mr. David	\N	A6563	M6313	A65	4b265caf1279d04a58c6e6e476cfa8de
229	3564427	Aaron, David	\N	A6531	D1365	A65	b1a3172a992d49f8532fce66248ab55e
230	4036927	Aaron, Fanae	\N	A6515	F565	A65	a93c74ee9376e1398c6b01211ccd3b91
231	4036927	Aaron, Fanee	\N	A6515	F565	A65	10b7bf972dba763d1e369e329573d3fd
232	900	Aaron, Henry 'Hank'	\N	A6565	H5652	A65	4a4205707ca6edb4feddb7d89a4f954e
233	900	Aaron, Henry	\N	A656	H565	A65	383dcde0d579987ae82c9022e3b56c0e
234	3564431	Aaron, Harriotte	\N	A6563	H6365	A65	55e809f71d79ce500728fc4e6c7a7df0
235	903	Aaron, John	\N	A6525	J565	A65	ef55abd52b386cf90a74af103309a32f
236	2701220	Aaron, John A.	\N	A6525	J565	A65	bd7c60b5c6071621de0ac0cbb51f8992
237	915	Aaron, Rabbi Jonathan	\N	A6561	R1253	A65	44a4d4b4337478d427b3ee22aa7b88ef
238	1739869	Aaron, Joy	\N	A652	J65	A65	8f693c36d3eaccd576663432031c54a0
239	920	Aaron, Lt LJ	\N	A6543	L3426	A65	be9596dcd84ef4a4ae308971d72dcad0
240	1739873	Greening, Karen	\N	G6526	K6526	G652	ba9bab43bdef6ccbf497f6061efda20a
241	4061945	Aaron, Mary R.	\N	A656	M65	A65	bce58de66f118f0f9fd723af0cd6b6a0
242	4061946	Perrye, Matthew Aaron	\N	P6536	M3651	P6	bfdfd74c9b19b43049ca20e621164f5b
243	1739876	Comfort, Rae	\N	C5163	R2516	\N	fc85e5db48d93176741b6bb883013a9d
244	4061947	Aaron, Pamela	\N	A6515	P5465	A65	e7b1f340ba3724759d839d6a7e62c1f1
245	938	Smithee, Alan	\N	S5345	A4525	S53	d17aa3d722654581d124c0120aacaa08
246	4061948	Aaron, Richard E.	\N	A6562	R2636	A65	237bef720bdfd53c7792f0b740ffdf50
247	3564439	Aron, Sam	\N	A6525	S565	A65	dbbf44c578a2b4524d77392cf7de0d97
248	4061949	Aaron, Steven	\N	A6523	S3156	A65	76ec5ef7f13dca4b31c0299360671fcf
249	4061949	Aaron, Steve	\N	A6523	S3165	A65	8b304e49d8b38be15fc1dc495f0dcc33
250	4061950	Aarrons, Mark Buck	\N	A6525	M6212	A652	c2628a2c1add2aaff7425ff92095bec5
251	4061951	Aaron, Dominic	\N	A6535	D5265	A65	2f778ce706df790e9d2db41b81196025
252	4061951	Aarons, Dom	\N	A6523	D5652	A652	cfc2c5c72e18d4af9f20fd6650e26934
253	3063863	Ayers, Paul	\N	A6214	P462	A62	3db21bca94b9de210b366664b32e0cdc
254	3063863	Ayres, Paul	\N	A6214	P462	A62	4f2e453bed9fb5f8ff10acd2240d2008
255	3063863	Ronns, Edward	\N	R5236	E3636	R52	96b0543bc72d40afb70aa69d6ff15c11
256	3063864	Stone, Riel	\N	S3564	R4235	S35	4a17182ba7e76e43587b66b6c36de651
257	2701244	Aaronson, Emily P.	\N	A6525	E5416	\N	e20382e4d81b058d1afd3e71d838b43f
258	3063866	Ashe, Penelope	\N	A2154	P5412	A2	50b611b37aacd61f378d7f2bbdb2496b
259	996	Scott, Jason	\N	S2325	J2523	S23	142f921e6d761a3f3d63868342d34a79
260	996	Scott, Jayc	\N	S232	J23	S23	940f3fa5507d185ff54f0e9141814f45
261	1001	Aarre-Ahtio, Tapio Ilmari	\N	A6314	T1456	A63	9f773df6e2944132c3482e1aabd3b117
262	1739899	Akhtar, Shanez	\N	A2362	S5236	A236	456e79381321b20c12744659789d2c92
263	1007	Aarroskari, Jocce	\N	A6262	J2626	A626	ae2ab13654db4e72792c67da40927523
264	1012	Aarseth, Øystein 'Euronymous'	\N	A6232	Y2356	A623	11b5878df53fb62acade57685cbc0296
265	4061952	Aarskog, Bjorn E.	\N	A6212	B2656	A62	33cec962d0e5b16fe546a79eff4509e0
266	4061952	Aascog, Bjorn	\N	A2126	B2652	A2	c5e84fc9e96eddeaa9aaa36ceb30fc31
267	1739907	Arti	\N	A63	\N	\N	3d7c2fe730119b69e8caf192d8591475
268	1739909	Aarts, Arletta	\N	A6326	A6436	A632	b338a95cab5466b2ba08b0a9f28a6dc0
269	1044	Dúné	\N	D5	\N	\N	74b70d173dc000f51c04940e507f1690
270	4061953	Aarvold, Mike	\N	A6143	M2614	\N	3f439512128048dbc6609edb659e299a
271	1739918	Aaroe, Ami	\N	A65	A56	A6	40979e6b8f265e7d9aa9d32f4512b60c
272	1739918	Aaröe, Amy	\N	A65	A56	A6	ef6db07e9fdc4fe6cb8768016a0b6ca9
273	1739918	Aaröe, Anne-Marie	\N	A656	A56	A6	6f5913f161f22d753627489ac2903cee
274	1739918	Delmas, Amy	\N	D4525	A5345	D452	881af4d6bff4745777f7fa0043f56b34
275	1053	Martin	\N	M635	\N	\N	81d6f316d169150d0e8733866c38684d
276	1071	Wheaton, Tim	\N	W3535	T535	W35	f9fdb747b9decaa2a42bd76f4f25d30b
277	1091	Aasen, Johan	\N	A2525	J525	A25	67930190e6baeb0b38f4b8d92ea35638
278	1091	Aasen, Johnny	\N	A2525	J525	A25	8fb7bfb737f08625099f50da401996a9
279	2701257	Aaseng, Jon Aaron	\N	A2525	J5652	A252	c9a36572449a40cf2f948fffba9e8fec
280	3564473	Aasgaard, Ann-Karin	\N	A2635	A5265	A263	29e41aec69f04800000bde29290573bb
281	3564473	Aasgård, Ann-Karin	\N	A2635	A5265	A263	360feaaf9e1e2b0f3c8fb60c391cec58
282	3564473	Åsgaard, Ann Karin	\N	S2635	A5265	S263	ce6189ff80dee1ce31765de35cdb5eb0
283	3564473	Åsgård, Ann Karin	\N	S2635	A5265	S263	4d5b304f46f931d9ed08fe6b070c0dbb
284	1739933	Asiya	\N	A2	\N	\N	45643fe1d2107cf614e2f546a539d7dd
285	1110	Aashi	\N	A2	\N	\N	79877baab73ef6d523939cd9eb323d86
286	1110	Aasi	\N	A2	\N	\N	7c5cd8763b4d57de6656109930b98bd6
287	1110	Asie	\N	A2	\N	\N	a55b6bf862213bac5bcdddc16cb4ab68
288	1110	Asi	\N	A2	\N	\N	124faff21e1cd2fcb8c2ac76a5f584ed
289	1110	Assie	\N	A2	\N	\N	5b32f076f16a7ddffac5d8d866d8b45e
290	1116	Aasland, Bjørn	\N	A2453	B2652	\N	b09a4c1bcbe282e37ecde65dfc21837e
291	1117	Asland, Derek	\N	A2453	D6245	\N	42843a8f0d42752a6447d56275c2ee39
292	1739944	Aastrup, Helena	\N	A2361	H4523	\N	10e29cce6dd612b53e23b1f7e6087c39
293	3316952	Aleem, Atif	\N	A4531	A3145	A45	9722ccdeca90741ae366e471928a02ec
294	1125	Atish	\N	A32	\N	\N	6cbfde0300928c7d0f0dc03eba120e3c
295	1739951	Armi	\N	A65	\N	\N	17835e83a8557bc5501cc85b2bf469b6
296	3564483	Aaviksaar, Eva	\N	A1261	E126	A126	0c188de901d062fd52d2d15fda9debd1
297	3493796	Rahman, Anne Nurul Ain Ab	\N	R5645	A5645	R5	28f32c41f7746072bea209831e082274
298	1739960	Estevez, Dayrein Aba	\N	E2312	D6512	\N	9c527c8365db8a4ab506d01a140182a6
299	1739965	Maya	\N	M	\N	\N	719fe28004fcdd81a820602924aa8074
300	1739965	Shakur, Maya	\N	S265	M26	S26	356bf25c05539390713647db48ee2d70
301	1739965	Sørensen, Maya	\N	S6525	M2652	\N	d4dd8e00f5c6b5030bc4523b5bc0537c
302	1167	Abacan, Jose Mari R.	\N	A1252	J2561	A125	87068425a47b12a48f016c34d56838e1
303	1170	Ojuel, Abad	\N	O2413	A1324	O24	68c4e62b73b73c39dcfac692f81c15d8
304	3493800	Abad, Xavier	\N	A1321	X1613	A13	ea4abf1f9579862bcceae545d832c2bf
305	3493800	Abad, Xavi	\N	A1321	X13	A13	59e969093a08058f4f93fdb4928848b1
306	1179	Abad Jr., Artemio C.	\N	A1326	A6352	\N	d4886262a769aa8ea2259ed0c93b8dc5
307	1179	Abad Jr., Artemio Cruz	\N	A1326	A6352	\N	e0e14c4d0f0d31beea694274c2e92c42
308	1179	Abad Jr., Artemio	\N	A1326	A6351	\N	001c859674a70dc028562d5b6a8f93a2
309	1179	Abad, Artemio Cruz	\N	A1363	A6352	A13	fbc691e0cc1f419161374b1de2eb96de
310	1179	Abad, Temi	\N	A135	T513	A13	69bc6f981130ba8ceb9563445c0e77ab
311	1739985	Abad, Encarna	\N	A1352	E5265	A13	40420e38f3c47ccd76a15bfe0eb25f40
312	1195	Abad, Fabián O.	\N	A1315	F1513	A13	6a65f85db33c8b3d7760a0b43f2e475f
313	1199	Abad, Paco	\N	A1312	P213	A13	bd4d5566dafe20813cb35ad2ff5cb951
314	1739993	Abad, Kay	\N	A132	K13	A13	f55c2c95ea4352f1fb156de58c426766
315	1739993	Dizon, Katherine	\N	D2523	K3653	D25	c93251cb3757ba375f7a1cfca889f8b8
316	1221	Abad, Teo	\N	A13	T13	\N	3b23f1c850a37800589ff20d6bffd646
317	3564500	Abad, Dr. Marco	\N	A1365	D6562	A13	cec4079c18fdfa396915113497d420e9
318	2701278	Abad, Minnella	\N	A1354	M5413	A13	403b773f3138bd22a79c2d6e21c75c7b
319	1740001	Abad, Melodie	\N	A1354	M4313	A13	bedf81e64843084c2a48eeecb502b13b
320	1225	Abad, Nico	\N	A1352	N213	A13	faf94907198b8872fde1877f320a8a42
321	1230	Abud, Ricardo	\N	A1362	R2631	A13	48af2c396d1aff32c9809a6afd2367e2
322	1234	Abad, Timothy Adam	\N	A1353	T5351	A13	eb78e7bae3d2af396298faf2baca1af4
323	1234	Abad, Timothy	\N	A1353	T5313	A13	46ebf32036d59c2f7a62255f052a7ce5
324	1236	Abad, Xavier	\N	A1321	X1613	A13	ea4abf1f9579862bcceae545d832c2bf
325	1236	Padrosa, Xavi Abad	\N	P3621	X1313	P362	6d3a24fa57916caba3a506caf5cfa3bf
326	1240	Abad, Oscar	\N	A1326	O2613	A13	9187134e4c860a5b295610a5aaf7943f
327	1740019	Abad-Santos, Anna	\N	A1325	A5132	\N	b273ebbed02861adf336f09e15135fd3
328	1740019	Santos, Ana Abad	\N	S5325	A5132	S532	7617d4d9576d000989ac6af374eb73f6
329	1246	Abadal, J. Ignasi	\N	A1342	J2521	A134	e294f08726e74eabcba164f2fb194c05
330	1246	Abadal, Josep Ignasi	\N	A1342	J2125	A134	5d34b02254fc33659a5f7183673547fa
331	1246	Abadal, Josep	\N	A1342	J2134	A134	9a3994b0e22e3f11ed32ff1107c0fdf8
332	1246	Abadal, José Ignacio	\N	A1342	J2521	A134	a92b3e7fa6a8df360fcca896e3a9ffa3
333	3316958	Abadam, Michael Sam	\N	A1352	M2425	A135	43b354098f84d221a07e116afd4169af
334	1254	Abades, Cesar	\N	A1326	C2613	A132	6c69ffec1c1ba531e5a1b6503816001b
335	1254	Albades, Cesar	\N	A4132	C2641	\N	c1467693a6772eb0172cf1e04c2d46b7
336	1256	Abade, Reyes	\N	A1362	R213	A13	73b0f7bc4bfaaf0c871631a3d0dc6eee
337	1256	Reyes	\N	R2	\N	\N	e7ec4c603ee70851f5266811e1d54ee5
338	1256	Tejedor, Reyes Abades	\N	T2362	R2132	T236	9d85eab310061cdf44551c2ca05cbb19
339	4061954	Abades, Oscar	\N	A1326	O2613	A132	2643dc3ca6746a0c42cf4d71315f6a0f
340	1258	Abadenza, Apolonia	\N	A1352	A1451	\N	9d63ec4096cf07841a1be09096155c12
341	1258	Abadesa, Apollonio	\N	A1321	A1451	A132	7c552cef2b43ff9f06071b7852dcd64f
342	1258	Abadesa, Apolonio	\N	A1321	A1451	A132	01c427b27a1157a515d92ca9f4eacbf8
343	1258	Abadesa, Polon	\N	A1321	P4513	A132	08913b6f99c310dc5336eb46ba77db4c
344	1258	Abanesa, Polon	\N	A1521	P4515	A152	f28659a75badf30257a89e3c547201a4
345	1260	Abadessa, Dante	\N	A1323	D5313	A132	df843a8fe9cee78a53d706cde9d13415
346	4061955	Abadesa, Joy	\N	A132	J132	\N	7d3e6d6294e54dda2ffb180151e77886
347	1261	Abadesa, Rene	\N	A1326	R5132	A132	308782edd956b3f83d32df0608462fe8
348	1261	Abadessa, Rene	\N	A1326	R5132	A132	d09a6d8778b1875718093ee8a7bb89ec
349	1261	Abadeza, René	\N	A1326	R5132	A132	a4a305c3e2a012c20ea3cd668c185f67
350	1740028	Abby	\N	A1	\N	\N	9639a3cf1f865cbf90a537245e3deb2e
351	3564514	Abbadi, Marwan	\N	A1356	M6513	A13	a4125e1287329ef98cf1a42cec6dbb9c
352	1272	Abadia, Lysander O.	\N	A1342	L2536	A13	2ebd2141225cc3125bb05318e37a97e1
353	1273	KLVE, Oscar Abadia	\N	K4126	O2613	K41	4ace7bf9a00e41cfcd0dff63dd0223da
354	1274	Abbadia, Victor	\N	A1312	V2361	A13	dc27c1cea67fbb31b054aa98dc4ca59b
355	1277	Abadie, Alfred C.	\N	A1341	A4163	A13	46ce18fa365596ae66081bb29cf0840f
356	1291	Abadie, Spencer	\N	A1321	S1526	A13	8be7ad2ef3f081a9d0ddebe47121fb58
357	1302	Abaddie, Luis	\N	A1342	L213	A13	3d16e2dcaf22df1252891e960516c24d
358	1302	Abbadie, Luis	\N	A1342	L213	A13	37e09f7440660ec77901ae921542aa59
359	1302	Abbadié, Luis	\N	A1342	L213	A13	b9209ef8134b524c1a62a9890e294f7a
360	1740043	Abadi, Rumina	\N	A1365	R513	A13	55e2161b392c480fbff5120d529990be
361	3564522	Abadin, Mar	\N	A1356	M6135	A135	cef6893c6b441c186dd8fe564053e2b9
362	4061956	Abagat, L.	\N	A1234	L123	A123	17d990a95d021553adde5f35fd531f93
363	1323	Abagnale, Frank W.	\N	A1254	F6521	\N	738a052eca8f5e93bd6821bf50a725fb
364	1324	Abagnale, Soony	\N	A1254	S5125	\N	3864a6d0f262df38dc1b8bb26e48380e
365	1326	Abagouram, Youssef	\N	A1265	Y2126	\N	a04058dbb45a02b4fe6a25905d29a93c
366	1330	Mighty Show Show Players, The	\N	M2321	T5232	\N	c9bc4b2183745d7a8e1678573ef6738a
367	4061957	Abahmed, Hesham	\N	A1532	H2515	A153	a4c5bc29239893047821500f46e8aa9b
368	1334	Abaid, Moa	\N	A135	M13	A13	e19d3f504a77083ee52d41abb3ff351d
369	1338	Abainza, Ver	\N	A1521	V6152	A152	84076d855879f8e5e7b82e1c5c24a9ee
370	1740055	Abaituna, Susana	\N	A1352	S2513	A135	002ac442ea6c39bd3ea16b0e94176b8f
371	1740055	Abaitúa, Susana	\N	A1325	S2513	A13	f015b2661ddac6abb3ab2335f38af1e0
372	1740055	Gómez, Susana	\N	G525	S2525	G52	0db05c2ce445e3805368d42bf961c8c8
373	1359	Abakarov, A.	\N	A1261	\N	\N	e07af30709eda8aac6b65a681396f62e
374	1367	Splash, Duo	\N	S1423	D2142	S142	bab92beebd5078973e7b99f87d9cfddd
375	2701300	Abalahin, Ana	\N	A145	A5145	\N	dbbe836af98efa5745e11e2550c44308
376	2701300	Abalahin, Anna M.	\N	A145	A5145	\N	60d5d64c041a2c97c41c019ceeef87f5
377	2701300	Abalahin, Anna Maria	\N	A1456	A5614	A145	86e119efd902d8fb48e5ebd36ecf3313
378	4061958	Abalakina, T.	\N	A1425	T1425	\N	66372469ac4f8d7abf1781ed57e0a8ab
379	1373	Abaldonado, Ronnie 'Ronnie Roy'	\N	A1435	R5656	\N	d4b7517fae251c61958f944a6a155f5b
380	1373	Ronnie, bboy	\N	R51	B165	R5	b09c513416454183858e00a9cc9ea150
381	3564541	Abalon, Charla	\N	A1452	C6414	A145	2c707bf7b0ee147eed779668ae1df0d6
382	1382	Abalos, Mayor Benhur	\N	A1425	M6156	A142	cf9f780d27cde60075e57fc3b9a1b9ae
383	1385	Abalos, Jayson	\N	A1425	J2514	A142	d73f0502548bdec4b778fe3c75f0efac
384	3564543	Abalos, Jaime	\N	A1425	J5142	A142	d2611e6285de9d88e66839e77c68e609
385	3564545	Pajar-Abalos, Lyza	\N	P2614	L2126	\N	f8272686ad2976cb13d374cc46156939
386	1393	Abalos, Ralph	\N	A1426	R4142	A142	a51bf99307c6b08e11499b0bca9c1ba3
387	4061959	Ábalos, Ramiro	\N	B4265	R5614	B42	24f20d8a9849a8e1e8322333d65717a8
388	2701304	Abalos, Ruben S.	\N	A1426	R1521	A142	a8e2ad4724b5e7bb39ff7529f053ad8e
389	2701304	S.Abalos, Ruben	\N	S1426	R1521	S142	fb1adfc6d584743771ac7bb138820eb8
390	1397	Abalov, E.	\N	A141	E141	\N	889a497ac64ad79b1158bfe897873d4c
391	1740076	Abalyan, Nvard	\N	A1451	N1631	A145	3c056617c678c52fd23ac14a7cf20238
392	3228467	Abbane, Othmane	\N	A1535	O3515	A15	96bf4c605fbfe7821297e8c0382a3c3d
393	3228467	Othmane, Abane	\N	O3515	A1535	O35	3b0ce1e8a86fee561da85d65e1800114
394	3564554	Abaño, Kay S.	\N	A12	K21	A1	36cd1976dfd2e635723c195e136e61d1
395	3564554	Abaño, Kay	\N	A12	K1	A1	fd3266df056d2759d0002bd41b7ec6b5
396	1425	MD, Juan Carlos Abanses	\N	M3252	J5264	M3	9de30cc988b8b2af225978f178e7bedb
397	4061960	Bast, Seb	\N	B2321	S123	B23	ed3639ce81623ca80bf9a367a8fc10df
398	3564557	Abanto, Manny 'Pandoy'	\N	A1535	M5153	A153	7abd4c81553673f9958c0d6eb6e0c117
399	3564557	Abanto, Manny	\N	A1535	M5153	A153	dcd66b2d533addfa90cac31b753c7ce7
400	3564557	Abanto, Manuel 'Pandoy'	\N	A1535	M5415	A153	fd3f7fba567afd72718450a47b92551a
401	3564557	Abanto, Manuel Pandoy	\N	A1535	M5415	A153	270d66c4ff3e6e38629ac7fddc92a87a
402	3564557	Pandoy	\N	P53	\N	\N	2d187a7276928bcbdb4888597ae79a98
403	3410712	Abar-Baranovskaya, M.	\N	A1616	M1616	\N	611e54c781be410dd02604ba1ce7cdb8
404	3410712	Baranovskaya, M.	\N	B6512	M1651	\N	3a27a6c2f04f3d08658baf6313a55278
405	4061961	Abaravich, Patric 'Sparky'	\N	A1612	P3621	\N	e45b0c07445aa538c61cdd296ec397f0
406	4061961	Abaravich, Patrick	\N	A1612	P3621	\N	937e776ebe1d1597b4e1ab39fa2107f8
407	4061961	Abaravich, Patric	\N	A1612	P3621	\N	408a40083f493fbc3c8af6ba58fb4fb6
408	4061961	Abaravich, Pat	\N	A1612	P3161	\N	4a7eadb1c598fa01c5cff334c6c8894d
409	2701312	Abarbanel, Samuel X.	\N	A1615	S5421	\N	bee40dfb770b8c10e2e95a723ac40908
410	2701312	Banel, San-X-Abar	\N	B5425	S5216	B54	c1800a11921c1bd86046b21a82fa2305
411	2701314	Abarca, German E.	\N	A1626	G6516	A162	d8a8d0db2c05e978508be5d5d48a7283
412	2701314	Abarca, German	\N	A1626	G6516	A162	74d8b51d7ccdefa3d725f5dabc526228
413	3564564	Abarca, Jaime	\N	A1625	J5162	A162	0ef0b30b345f297c083ca9c85d629b5f
414	4061962	Valle, Braulio Salvador Abarca	\N	V4164	B6424	V4	0ecae7227890b5e32feaca47948273cb
415	2701317	Abarca-Benavides, Cady	\N	A1621	C3162	\N	5279af9ee09f9f13826bace6d403c4ba
416	3063903	Abarca, Carme	\N	A1626	C6516	A162	8cc3e150497533fad3faea945169bf4a
417	1740099	Abarca, Dr. Elena	\N	A1623	D6451	A162	2b149b0bbfde247a21f8f3a70f932349
418	4061963	Abarca, Maria Martin	\N	A1625	M6563	A162	8e8f1506438ce423f14badcc1eb788b4
419	1740105	Abarca, Paulina	\N	A1621	P4516	A162	1e327c45a5a2efc2653c8a07f9e8c170
420	1740105	Abarca-Cantin, Paulina	\N	A1625	P4516	\N	9637032e503721b50a6524a130cb1419
421	1450	M5	\N	M	\N	\N	3f44a84e6e34fdb5a2f89c68d8c36175
422	1740108	Ximena	\N	X5	\N	\N	c8f464c2e5871592c0159dab617147ea
423	2701320	Abarcar, Gabe	\N	A1626	G1626	\N	82cd42e7ea376b3c745c5fc9bfd728d3
424	4061964	Abarenov, A.	\N	A1651	\N	\N	47160f6ff19cc2ac5f6bbe11321be3f0
425	4061964	Abarenov, Anatoli	\N	A1651	A5341	\N	acca6861e52b7925da1a8a15337e566a
426	1456	Kigoy	\N	K2	\N	\N	df96828ffb43de36e8bd6cff8a3f1ec8
427	4061965	Abariotes, Stephen	\N	A1632	S3151	\N	63f051ac9a54b37b653704080879d2c9
428	4061965	Abariotis, Steve	\N	A1632	S3163	\N	c6c492f04864b1583d3617529692c3c7
429	1460	Abakarov, Rabodan	\N	A1261	R1351	\N	be8b92dcbcc49665f6a1e0bf3929dae6
430	3493810	Abarquez, Adones	\N	A1623	A3521	A162	33ccfbf84dde20e694fd0551ea599643
431	3493811	Abarquez, Alexis Megan	\N	A1624	A4252	A162	71cca6a338dae02a6612c713e6cd0b6d
432	3493811	Abarquez, Megan	\N	A1625	M2516	A162	a520ff67fd442f529d837b97d96e936c
433	4061966	Abarquez, Joejay	\N	A162	J2162	\N	acfdad59b7327cd1c9dd2264e72b69c3
434	4061966	Abarquez, Joey	\N	A162	J162	\N	d5f33d25d44ac133465c19f3be585998
435	4061966	Marquez, Joejay	\N	M62	J2562	\N	ff40e20c724abaf2f1823de0a08554ed
436	3564574	Abara, Daisy	\N	A1632	D216	A16	2e95488ffaa6e973b15dc02556156040
437	3564575	Abara, Dhang	\N	A1635	D5216	A16	6f087fe6d36da249855fba76cbfd4e86
438	3493812	Abarintos, Michael	\N	A1653	M2416	\N	75d373c001598f251ca08e4eac9a86db
439	1477	Abascal, Dr. Antonio	\N	A1243	D6535	A124	22a0318365be9c5f2b0ec58ed7588d1d
440	1740132	Abascal, Natividad	\N	A1245	N3131	A124	1531b1ae1eefb881722d598577c36600
441	1740132	Abascal, Naty	\N	A1245	N3124	A124	9b46ecdf1efb7032997d48cdf031a69c
442	1485	Abascal, Ramon	\N	A1246	R5124	A124	7d2b94a91eea7876f82415c8054cc88c
443	4061967	Abascal, Sylvia	\N	A1242	S4124	A124	459157fa35c4be80bbe01a33628aa731
444	4061967	Baker, Silvia	\N	B2624	S4126	B26	8c39c3fd80c5674c1d7fd2a8f217ce17
445	1490	Abashidze, D.	\N	A1232	D1232	\N	72b11301ea748f0c90ef92d947e23fab
446	1490	Abashidze, David	\N	A1232	D1312	\N	6e21fb8089830289d60538afb1c67f53
447	1492	Abachidzé, L.	\N	A1232	L1232	\N	29fd700befb70fa0977674fb5a5075f9
448	1740138	Abashidze, T.	\N	A1232	T1232	\N	3b801005bfbbda5f9c5cc17e194e4ffa
449	1496	Abashin, Vlad	\N	A1251	V4312	A125	c76b8e6c27a4b6014ccd07cc13509f25
450	1502	Abasolo, Rolando T.	\N	A1246	R4531	A124	959eac4cc8217e61650e2c82c2bb800b
451	1502	Abasolo, Roland	\N	A1246	R4531	A124	e0e73246010dea6cbe359e79e4570f75
452	4061968	Abaczovic, Gertraude	\N	A1212	G6363	\N	984ee5f6950826fa2192f0bfd478e745
453	4061968	Abazovic, Gertraude	\N	A1212	G6363	\N	211fc748d96794f1d9719572c1bf5509
454	1740148	Abbassi, Elizabeth	\N	A1242	E4213	A12	4db1432cb1acc0cc83e5d6c9159882c6
455	3564584	Abostado, Teri	\N	A1236	T6123	A123	5ef0db6ebe749e1d90f75b7ae6de4e5e
456	3564584	Persons, Teri	\N	P6252	T6162	\N	21b52bb774ab0e623ad0c999ee6b03df
457	3564586	Abat, PO2	\N	A131	P13	A13	0e07aa3347706b6330875b48e8f21a8e
458	3564587	Abat, PO2	\N	A131	P13	A13	0e07aa3347706b6330875b48e8f21a8e
459	3564589	Elliott, Loretta Abata	\N	E4346	L6313	E43	dfa8bf5b97448be37c4cd09a6ef882d1
460	1521	Abbatantuono, Diego	\N	A1353	D2135	\N	c192d8729cfbe59feac586cb6f0b481d
461	4061969	Abate Jr., Richard	\N	A1326	R2631	\N	6c76dd80a77d25442461ba19b36d6b61
462	1740155	Abate, Aurélia	\N	A1364	A6413	A13	3027560f3b1076b4b05117b3be7b0730
463	2701332	Abate, Robby	\N	A1361	R13	A13	c3d7937f339607c388d2131c7fec3165
464	1740156	Abate, Clàudia	\N	A1324	C4313	A13	e8043db0b993820b19c62eb4f1de1056
465	4061970	Abbate, Fabio	\N	A131	F13	A13	eb660300b50fb3abbe732e866d453eec
466	2701338	Abate Sr., Richard	\N	A1326	R2631	\N	681269cef62ffd42cdce8bdba3132880
467	2701338	Abate, Richard P.	\N	A1362	R2631	A13	430c73dd62dfdfa1ec6691fbec48cf40
468	1545	Kane, Thommy	\N	K535	T525	K5	979acddf174ea18187c009c9269e74fc
469	1545	Poverty	\N	P163	\N	\N	c31ca1d586dba96db67e4c7dcfb22639
470	1552	Abati	\N	A13	\N	\N	abde31c829c266ad40ce2b15450cc6c3
471	3564597	Abatie, Alesia D.	\N	A1342	A4231	A13	c0d971ce16a13efbcf3fcd6aa906d41c
472	1561	Abatucci, Serge	\N	A1326	S6213	A132	a2ceb489600ff88860176ae44c3b30de
473	1569	Abate, Anthony Shaw	\N	A1353	A5352	A13	207e660dbd2cf24172d02f81d8874e55
474	4061971	Abawag, Emmanuel I.	\N	A1254	E5412	A12	6d52d88212435783df9f63791420616a
475	4061971	Abawag, Immanuel	\N	A1254	I5412	A12	1a23553c64f246a379509a91a08c8f0b
476	1575	Obay, Korhan	\N	O1265	K651	O1	6a69f7858846d5ae44334b6faefcf1ad
477	3063917	Abaya, Dave	\N	A131	D1	A1	c9cc142573ed42644430504eb8e5b089
478	4061972	Abaya, Geoffery	\N	A1216	G161	A1	162e3f843b6220bd7129b93b50a6e5ff
479	3441976	Abaya, Prof. Leo	\N	A1614	P6141	A1	1324bbec5c93efa1e12f85ae9bc83a91
480	3228480	Abaya, Manolo R.	\N	A1546	M5461	A1	80ce14d592195976c83c0e8195fd8d30
481	3228480	Abaya, Manuel R.	\N	A1546	M5461	A1	31ae81d200c2c7b65504558e525b1e69
482	1590	Abayahyah, Sofian	\N	A1215	S151	A1	f73f33661732f598504fe756d97bace9
483	1591	Abayan III, Beauty	\N	A1513	B315	A15	3ac954defa4fad8bcb881d993b0606f4
484	1591	Abayan, Rufino 'Beauty'	\N	A1561	R1513	A15	dd0e52a252877e1417aaaf6d668d1878
485	1591	Abayan, Rufino	\N	A1561	R1515	A15	99611f2ece556663b971edf756349aa1
486	4061973	Abayon, Nerio	\N	A156	N615	A15	dc2d02bdcaf235c56a5f2d9466fc6afc
487	3063919	Abaygar, Carmela	\N	A1262	C6541	A126	09200c31276aee4006a94a68bfabf671
488	3063919	Abaygar, Ma. Carmela	\N	A1265	M2654	A126	89cb362bb9c0a7479c21dd792d648a45
489	3564606	Albahar, Elsa	\N	A4164	E4241	A416	9555fee35d59be03939b7c3df606f015
490	3564606	Albautar, Elsa	\N	A4136	E4241	\N	6266c0aacf4d0d06099ca6da950e7a41
491	3564606	Albaytar, Elsa	\N	A4136	E4241	\N	eaeca0830965624429c9637f6d97784a
492	3564606	Albutar, Elsa	\N	A4136	E4241	\N	7cd9fedfa397a57419932abcb0b68250
493	1608	Abaza, Rouchdi	\N	A1262	R2312	A12	3ba0b42e0abdd39c60e83492ce0c129e
494	1608	Abaza, Rouchdy	\N	A1262	R2312	A12	74e60ad1f4aa1e674177e7228f6950a3
495	1608	Abaza, Rushdi	\N	A1262	R2312	A12	3d405f4af79009ed82933325bc5983cf
496	1608	Abaza, Rushti	\N	A1262	R2312	A12	a5dddba2c74bbe0cbf842614a60b097c
497	1740189	Abazadze, M.	\N	A1232	M1232	\N	9bffb1025051866738c2fd8d6f921e87
498	1740192	Abazie, Lucy	\N	A1242	L212	A12	572713fa6e5d4b90ab9e56baa11c21d8
499	1624	Abazoski, Aleks	\N	A1242	A4212	A12	f15fe54cf71d253fdc6c0279c86b154b
500	1740193	Abrazova, Taalaikan	\N	A1621	T4251	\N	5ad9ccfbaf4e91ef2884ff923743ea7d
501	4061974	Abano, Jenus	\N	A1525	J5215	A15	4169fd920ce2e8dccaec56d02229b6d8
502	1641	Pimp, Da	\N	P513	D151	P51	ff6d0f1d3cc36af78634d2c9112da106
503	4061975	Abbad, Clàudia	\N	A1324	C4313	A13	34c4c98f391beee5c6b034df7576b689
504	1740200	Abad, Montse	\N	A1353	M5321	A13	f64adf40667f705a795fc928588bb575
505	1644	Abbad, My Rachid	\N	A1356	M6231	A13	10008a8681365635c563f3677303bdc8
506	1647	Abbadi, Dr. Ahmed	\N	A1365	D6531	A13	7a8e5f42ecc5303206023de5a707caf9
507	1740202	Abbadie-Hauser, Axelle	\N	A1326	A2413	\N	50ba29329d89bc2e58486a0a61de85e0
508	1652	Abbazi, Brahim	\N	A1216	B6512	A12	12b95b1239f327de4fae8c53e37ea2c6
509	3564611	Abakumov, V.	\N	A1251	V1251	\N	d1d8dd9774367a054e0effd4654b2bd8
510	3564611	Abbakumov, V.	\N	A1251	V1251	\N	aa23dc4702ab0b17b8d876510e375945
511	3063923	Mensah, Abigail Abban	\N	M5212	A1241	M52	00a67f4e2f953e3849000aa0e342ee46
512	3063923	Mensah, Abigail	\N	M5212	A1245	M52	6053ad2acb80156c5e3adc4d5b3afa86
513	1662	Abbash	\N	A12	\N	\N	aabb92dca4fab3e70d829a6b322a5e66
514	1662	Bhai, Abbas	\N	B12	A121	B	60b857cff19fca1fa66e6af59d960aa3
515	4061976	Abbas	\N	A12	\N	\N	d7b464b79ff2dc43fab5e1b6aba0417b
516	3228483	Abbasov, Adil	\N	A1213	A3412	A121	df240c12ed960d2593e3c030573fab47
517	1680	Abbas, Cassim	\N	A125	C2512	A12	fd736275c9c84835c89b5bc032c58bf6
518	1689	Abbas, Rassan	\N	A1262	R2512	A12	a8ee37d881e981dd7b3c6b4cd3f193da
519	1699	Abbass, Imran	\N	A1256	I5651	A12	6450854e262012010a7037fdb1499d0f
520	2701358	Abbas, K.A.	\N	A12	K12	\N	83561604f3cf480c81ba30e662715237
521	2701358	Abbas, K.B.	\N	A121	K12	A12	5e7936a3990fc0d06719b3d6a868a5db
522	2701358	Abbas, Khwaja Ahmed	\N	A1253	K2531	A12	1c5cc8be1492d36b43f6bd1dcfc0101d
523	2701358	Abbas, Late K.A.	\N	A1243	L3212	A12	bec9f0b5693ce3a20f84fc93efcb52e0
524	2701358	Abbas, late Shri K.A.	\N	A1243	L3262	A12	51846a652b4ffe6a93e96b4ccdbe397e
525	1708	Abbas, Wiz	\N	A12	W212	\N	6c222e68edd17866d1d2c1a87eb6fd25
526	1708	Abbas	\N	A12	\N	\N	d7b464b79ff2dc43fab5e1b6aba0417b
527	3564620	Abbas, Mohd.	\N	A1253	M312	A12	1606ab511a3659ec4414e719501d65d5
528	1740220	Abbas, Meriam	\N	A1256	M6512	A12	0a182aa459351e596180a84bff275583
529	1724	Khokar, Qamar	\N	K2625	Q5626	K26	0ca4ab2b958bbdc12617288d3b4cf49b
530	4061977	Safdar	\N	S136	\N	\N	dd8dcfcc3ed6ff58e0633ef861c81358
531	4061978	Abbas, Yehia	\N	A12	Y12	\N	036e4f38a9c1856269d58e78ac55ced3
532	4061979	Klahr, Jonathan	\N	K4625	J5352	K46	077634079fbcebc6d602cf1accceadab
533	3564629	Abassi, Rashid	\N	A1262	R2312	A12	2ff7121fd54eb176353a01dc18d4170e
534	3564629	Abbas, Rashid	\N	A1262	R2312	A12	5bf31b36b039ddec6429e2de6d850ca8
535	3564629	Abbasi, Rasheed	\N	A1262	R2312	A12	b805ef24665ab9f878b2981a4f076a3c
536	3564629	Abbassi, Rashid	\N	A1262	R2312	A12	c8b93f91043a1a58b3c728f066ff1fff
537	3564629	Rashid	\N	R23	\N	\N	12aaedf2544497666587758bba8a3838
538	1761	Abbasi, Rizwan	\N	A1262	R2512	A12	1dc0fd792c6632dec0e1126c77bd4fca
539	1775	Abbasov, Elxan	\N	A1214	E4251	A121	016e782cc5c2c2f0378b463fec87f861
540	1776	Abbasov, GÃ¼ndÃ¼z	\N	A1212	G5321	A121	0ba4f2543d886f6d1d8aa45c8d9e989b
541	1776	Abbasov, Gündüz	\N	A1212	G5321	A121	91ae538d5d1500695e923dec4bc4dede
542	1777	Abbasov, Haciaga	\N	A1212	H2121	A121	66e8a07544bdbe683ccdf98bab7df652
543	1740233	Abbasova, Lejla	\N	A1214	L2412	A121	65fc4bfeb5b8dde64fa7121df5430137
544	1740233	Abbasová, Leila	\N	A1214	L4121	A121	a008e104fec21149bf7df4979a2ddab3
545	1740234	Abbas, Hiam	\N	A125	H512	A12	ede9a8887266f64480649116efac0ba7
546	1740234	Abbass, Hiyam	\N	A125	H512	A12	e4c723109b794e37bd1b14481c0c2b61
547	1740234	Abbass, Iliam	\N	A1245	I4512	A12	062cc9265780eb535085aa4e953a33bf
548	1740234	Soualem, Hiam	\N	S45	H5245	\N	22631d5b0ae1d92009ccb26910e86fac
549	1740244	Abbute, Allison	\N	A1342	A4251	A13	8657cb29f910916902368cde2604b0bb
550	1800	Abbate, Det. Gregg	\N	A1326	D3262	A13	fd7551de3a48f08767236be487a5c826
551	1740254	Nancy	\N	N52	\N	\N	a33b73f30cde1640b9ac3ec98c7c2831
552	4061980	Abbatecola, Joe	\N	A1324	J1324	\N	dd61a4157b690faddad2f25ab5af4e7c
553	4061980	Abbotecola, Joe	\N	A1324	J1324	\N	64d977f9e55f6af298029e2a2633baa4
554	4061981	Abbatecola, Oronzo	\N	A1324	O6521	\N	490578c2618de09b98431ab8f1ce9afd
555	3316982	Abati, Joe	\N	A132	J13	A13	0e08f6b33deac2a75e790e5aa2db7e41
556	1740257	Abbatielo, Gabby	\N	A1342	G134	A134	8532319c4fd6da2575ee6cf5b394d181
557	4061982	Abbatoye, Jerod	\N	A1326	J6313	A13	36d5079e09570c6bfe085d78ce91f686
558	4061983	Abbatoy, Timothy B.	\N	A1353	T5313	A13	2e8e33b7c9be8fc58804d4685f5a5244
559	4061983	Abbatoye, Timothy B.	\N	A1353	T5313	A13	e0c52c0fa86538ca79548f9cb7df8ef3
560	4061983	Abbatoye, Timothy	\N	A1353	T5313	A13	f8a32fb5dbc00f39c1c5f68cd660ab85
561	1827	Abba	\N	A1	\N	\N	5fa1e1f6e07a6fea3f2bb098e90a8de2
562	2701388	Abbazi, Mohamed Oumouloud	\N	A1253	M5354	A12	bfe7b8026b81f741781a238b9c606fab
563	2701388	Abbazi, Mohammad	\N	A1253	M5312	A12	4f2c55df0f1bfc8d33a767f7c535e200
564	2701389	Abbazi, Siddartha	\N	A1236	S3631	A12	bd00fe01b709d3aa7e9c38ea1e5a60bb
565	2701389	Abbazi, Sid	\N	A123	S312	A12	13fe9acfbd614413078a49d37dacf612
566	2701389	Abbazzi, Siddhartha	\N	A1236	S3631	A12	140377e2ecc17d51479edb8bc10832c7
567	1833	Abbe, Charles	\N	A1264	C6421	A1	1081be8aab94e506fb8bfcb9c2247c36
568	1837	Abbe, James	\N	A1252	J521	A1	3e68352a95ec9f57eca16f536383221e
569	1838	Abbe, L. R.	\N	A146	L61	A1	44b967a6174bfe8102a10f09a11b4a75
570	1843	Abbe-Schneider, Marty	\N	A1253	M6312	\N	66deb7a353e699b5c0ea80bd7fb59ca7
571	4061984	Abella, Daniel	\N	A1435	D5414	A14	d467768a0a7a3b57815ea37659ef8eb6
572	3564647	Abbenda, Joe	\N	A1532	J153	A153	0aee9321b2ded1108b0eeb768c4896c3
573	2701394	Abbene, Sidonie Gabrielle	\N	A1523	S3521	A15	d35e33c32159900815a3debe8b12fe78
574	4061985	Abbane, Victor	\N	A1512	V2361	A15	7e98c777c730a68c4e44b7b3a4511d1b
575	4061985	Abenne, Victor	\N	A1512	V2361	A15	41d17968e2679e8c6088cac925564c56
576	4061986	Smith, Erika	\N	S5362	E6253	S53	3058ed0bac322fface05c477d0a206ea
577	1740266	Abby	\N	A1	\N	\N	9639a3cf1f865cbf90a537245e3deb2e
578	1740268	Brianna	\N	B65	\N	\N	d152efa3e0f22ed9b66f95592b58a20e
579	4061987	Abbey, Anna 'Cha Cha'	\N	A152	A521	A1	29f32aef057b60c3dcdac5921cd448b9
580	4061987	Abbey, Anna M.	\N	A15	A51	A1	f177ff92e363a30bab2de0e5de273efe
581	4061987	Abbey, Anne	\N	A15	A51	A1	dca9b44d58aad7a080a9e229989d77e5
582	1864	Abbey, Bray	\N	A16	B61	A1	62e186462b0d40ad73f723ad8d9c46ba
583	1864	Abeydeera, Stefan	\N	A1362	S3151	A136	e96aaa69b3e80400a4b4863d843f41c3
584	1869	O'Connell, Noel	\N	O2545	N4254	O254	da9fcad48b94ad73f2a03dcda4addbda
585	1740274	Jemini	\N	J5	\N	\N	4aa8b8479844003e031655a18dc30ca4
586	1870	Abbey, Glen	\N	A1245	G451	A1	0917ca148364539cabd1bb841d2f799b
587	1873	Abbey, Greg	\N	A1262	G621	A1	8eb469bc0bfaa0f9e0efb833ab31bd73
588	1873	Campbel, John	\N	C5142	J5251	C514	4aa02756f56c90e4b9bb21f04fd0d884
589	1873	Campbell, John	\N	C5142	J5251	C514	6c68f67919cdaf04d61a22d3115f48d5
590	1873	Frankson, Frank	\N	F6525	F6521	\N	04864a6b4f6c3eb38b5f050bb1b7ce94
591	1740277	Abbey, Kelly	\N	A124	K41	A1	4ec16df977dcafdd7440cdcedd44725f
592	1740278	Abbey, Mae	\N	A15	M1	A1	3cce5020d3a8d99557164ef3c01cde28
593	1740283	Taylor, Jackie Abbey	\N	T4621	J2134	T46	e0c0553536b26aef054f37819f66bc75
594	1896	Abbina, Franco	\N	A1516	F6521	A15	c3fdf7636df7357c0341bfd45f4ed436
595	1896	Abbine, Franco	\N	A1516	F6521	A15	269c575c545622b00be6827f1644719a
596	4061988	Abbinanti, Donald Joseph	\N	A1535	D5432	A153	12e417dfcdd293c5029ac83ae0f0781b
597	4061988	Abbinanti, Donald	\N	A1535	D5431	A153	3d1f2a20d92754d2de864ce8563e7cf9
598	2701400	Abbitt, Dave	\N	A131	D13	A13	fd0df935b29363dbb6ce82075115002f
599	2701400	Abbitt, David M.	\N	A1313	D1351	A13	8b8778988c5c393317e96f8ebdbb868c
600	4061989	Abblett, Donald	\N	A1435	D5431	A143	030f86f3f45a068d3f17f4da200fd23c
601	4061989	Abblett, Don	\N	A1435	D5143	A143	086fbfedaf59df31a27b69edbd0cfaf6
602	4061989	Ablett, Donald	\N	A1435	D5431	A143	67590201db3b501eb29dbd125df78969
603	3564667	Abbodanante, Rich	\N	A1353	R2135	\N	6e9e6fc12fd53c478c4e804ff2762777
604	1925	Abbondanzieri, Pato	\N	A1535	P3153	\N	aebb819f9f97ddb3c064388951f00326
605	4061990	Abbott, Barry	\N	A1316	B613	A13	3cf7656cfe66f42d4e62023e91916bfe
606	4061991	Abbott, Charlie	\N	A1326	C6413	A13	499e9c46010841b9425fd63fadd2f098
607	3564675	Abbott, Geraint	\N	A1326	G6531	A13	2a01cfb4c909349a608890541ea60a86
608	4061992	Abbot, Kathy 'Style K'	\N	A1323	K3234	A13	cef5075640e5387562063d167803b05a
609	1948	Abbott, Kioka	\N	A132	K213	A13	8b5e2cd3384c315e8e89b56a4bd65033
610	1740308	Abbott, Loretta	\N	A1346	L6313	A13	c14fa49ac4051a34694100944f4033fd
611	1954	Abbott, Russ	\N	A1362	R213	A13	d773853f1941cbbe4282c9cee4bb19b1
612	1954	Black Abbots, The	\N	B4213	T1421	\N	7a6cdcc5c1148277137cd4a1eba7f518
613	4061993	Vahan, Katherine	\N	V5236	K3651	V5	07f8fecacbce23d5600c1b62a31fd20d
614	1967	Abbot, Abdul	\N	A1313	A1341	A13	ba8069590f02f86a4880f7419b6471bb
615	1967	Abbott, Abdul	\N	A1313	A1341	A13	0fe337dcb5c95465e6c813eb262846cf
616	1968	Alexander, Abbot	\N	A4253	A1342	\N	27c1da02be37df49e07085c79ce3c444
617	3564679	Abbott, Alex	\N	A1342	A4213	A13	3fbbd89258db56db20cd614474563dd9
618	1740322	Antoinette	\N	A5353	\N	\N	5fad747662b3bb9a2feaa4f95d760071
619	1740323	Abott, Ashley	\N	A1324	A2413	A13	378069be00f6046a62a0f5b462b84eb6
620	3564685	Abbot, Bill	\N	A1314	B413	A13	1ca9592fa67103ca99d33882e2316ef1
621	3564685	Abbott, William	\N	A1345	W4513	A13	fd9304e2cdfcfd3331d0732ee2f88e01
622	3564687	Abbott, Brooke English-Anne	\N	A1316	B6252	A13	d5ca5f62fbda0bcfe5b321af97494d71
623	3564687	Abbott, Brooklyn	\N	A1316	B6245	A13	efeb0d5c892374a00000097a01aa90af
624	1989	Abbott	\N	A13	\N	\N	e94953712c74734754d91a3889745f9e
625	1989	Costello, Abbott &	\N	C2341	A1323	C234	e8c2215a1977cfda24a8d0b5c32f0b5e
626	1989	Costello, Abbott and	\N	C2341	A1353	C234	dc36f962e0390553b65c8dcd400c050d
627	4061994	Abbot, Carol	\N	A1326	C6413	A13	6a64aa273ea061181f6f55da896f8b95
628	4061994	Abbott, C V/M 420372	\N	A1321	C1513	A13	5cd99791a984ffb5008b7f73f7d5efc1
629	4061994	Abbott, Carole	\N	A1326	C6413	A13	6dc77a552ba96187835ba1c3a44c74f7
630	4061994	Abott, Carol	\N	A1326	C6413	A13	d04226a6fb70571c02719b359cdea5c5
631	2701414	Abbot-Fish, Chris	\N	A1312	C6213	\N	9f0e7570246a0cd917ccbce9bbda1742
632	2701414	Abbott-Fish, Chris	\N	A1312	C6213	\N	5b2ec4109d9de68ba52338e2919501b1
633	2013	Abbott, Det. Dave	\N	A131	D313	A13	2d1fb2cce49be0a319ecbac468e23527
634	2014	Alexander, Abbott	\N	A4253	A1342	\N	4cbc8bc63f38cd7b2632e029db972b2e
635	2014	Alexander, David Abbott	\N	A4253	D1313	\N	e61469de03ef7423551f3e01095c58a8
636	4061995	Abbott, Dave	\N	A131	D13	A13	fc2139d1da45fe682e943fd0f8a4ed45
637	4061996	Abbot, Dave	\N	A131	D13	A13	3e495de721bcef7192fa4a112e2fee33
638	4061996	Abbott, Dave	\N	A131	D13	A13	fc2139d1da45fe682e943fd0f8a4ed45
639	2017	Abbott, Tank	\N	A1352	T5213	A13	c7de8c50aed6ab720954711ab8aca21a
640	1740342	Deb, World Wide	\N	D1643	W6431	D1	f9fcc53dd81bf564a77a58e8c1a79ee4
641	1740343	Abbot, Diahnne	\N	A135	D513	A13	f433034438c01bc16c5779a1a7a0b195
642	1740343	Abbott, Diahnne Eugenia	\N	A1352	D5251	A13	da77675ac8a3fd392cbbf58eae322e2c
643	1740343	Déa, Diahnne	\N	D35	D53	D	14c67821e31eb6ddb2c0c2f8fc5bec2f
644	1740345	MP, Diane Abbott	\N	M1351	D5135	M1	e1c6d69fa191344e936fad6a5aa85ec6
645	1740345	MP, Diane Abbot	\N	M1351	D5135	M1	da9cfc7bfc21954751248bb887e71410
646	1740345	MP, Dianne Abbott	\N	M1351	D5135	M1	f9e1e589691dc95321b7d9fbb3197b82
647	2701417	Abbott, Douglas	\N	A1324	D2421	A13	7882705822d8d39c584f36bdf19a2491
648	3063948	Hallowell, Eleanor	\N	H456	E4564	H4	f55108239c1e2ccce102e6baec300a3b
649	1740353	Wain, Emily	\N	W54	E545	W5	cad1604e843f7893d1d3aa61ec65878b
650	2029	Abbott, Eric J.	\N	A1362	E6213	A13	5e8fdb137f789d885fa9ed30f598c97d
651	2029	Reyez-Abbott, Eric	\N	R2136	E6262	R213	83f9fe730c30eaa1731d37a9f6dc15d3
652	2034	Abbott, Frank	\N	A1316	F6521	A13	4406512d3a80bda583c7d938d269ea7c
653	2038	Abbot, Fredric	\N	A1316	F6362	A13	e1b8f46ab96d42bf9217ccd8bcac8230
654	2038	Abbott, Frederic	\N	A1316	F6362	A13	7755f0cc1c0b580188028d175a8a9db9
655	2039	class, G.P. Abbott - Quartermaster 2nd	\N	C4213	G1326	C42	966a694bae76bc97dcf7001c32afb6e2
656	2701420	Abbot, Gareth	\N	A1326	G6313	A13	c1b41de278eb7109a0f7f7cc87371b80
657	4061997	Abbot, Gary	\N	A1326	G613	A13	086e70382bd7bf6af4c7a5ee1698ad53
658	4061997	Abbott, Gary	\N	A1326	G613	A13	8b344dd7848b32fa48553a82c331bd40
659	2042	Abbott, 'Bud'	\N	A1313	B313	A13	3e141bbd77c1cd5c4e9ddc69a6f1a0ce
660	2043	Abbott	\N	A13	\N	\N	e94953712c74734754d91a3889745f9e
661	3564697	Abbott, Greg	\N	A1326	G6213	A13	05c073dadaf7e3f227eef3c8703d2e75
662	1740363	Abbott, Gypsie	\N	A1321	G1213	A13	08127c88ad95deaaa2c5e9b7e0b1583a
663	4061998	R.N., Commander J.A.R. Abbott	\N	R5253	C5362	R5	5d8b9b7d9973d7d81ef9002414b3126e
664	2058	Abbott, J.F.	\N	A1321	J13	A13	52271c7cb0f72bbbec9961a8eb12c32a
665	2058	Abbott, Jack F.	\N	A1321	J213	A13	cac2a7ceb1779a66f124d1eff12d9264
666	2058	Abbott, Mr.	\N	A1356	M613	A13	28a066861c56af340a3339fc88d119a0
667	3316995	Abbot, Jerry	\N	A1326	J613	A13	96c4ce713de1da06d433b189a3fe7339
668	2086	Abbott, John	\N	A1325	J513	A13	4e64d3c27d27606fed58beb39c5e6342
669	3228498	Abbott, John	\N	A1325	J513	A13	4e64d3c27d27606fed58beb39c5e6342
670	2701432	William, John	\N	W4525	J545	W45	f286d47dcc47218bdf7d06045a7d1a00
671	2088	Abbott, Joe	\N	A132	J13	A13	1b0845c4be895a532218b264e189bf3c
672	1740384	Ph.d., Kathryn Abbott	\N	P3236	K3651	P3	fa88042119b697e177377411bda26d62
673	2091	Abbott, Everette	\N	A1316	E1631	A13	1bac116f7a2e866f909b229be5865bc3
674	2098	Abbott, Bill	\N	A1314	B413	A13	47e195622ac4662abd55ddfa34bcf451
675	2098	Abbott, Lenwood Ballard	\N	A1345	L5314	A13	e4e1d3823dc62c4dff35b0d00374123a
676	2098	L.B.Abbott	\N	L13	\N	\N	42e537334f80b302b1d4e532e305adfd
677	4061999	Abbott, Larry Wayne	\N	A1346	L6513	A13	2db183c9f7075a2c6755dc24c9c01b7c
678	4062000	Abbott, Leonard	\N	A1345	L5631	A13	7820966f8a6bd08aa0481b89276496b8
679	4062001	Abbot, Mark	\N	A1356	M6213	A13	696c4ee0bc662d5bff5c6d3160458ad1
680	3493831	Abbott, M.	\N	A135	M13	A13	d6618962e2ccbea472f8c820c7c91415
681	2108	Demoralised, Skint &	\N	D5642	S2535	\N	fab7d0e11419327d8d2d2ca32df6d76d
682	3564729	Abbott, Mathew	\N	A1353	M313	A13	625c4b23aaef43ccbff5f64d59474db8
683	3564729	Abbott, Matt	\N	A1353	M313	A13	346d393ce3dd7ffc8d0925a0c189075f
684	2110	Dancers, Merrill Abbott	\N	D5262	M6413	\N	2e549b56dc66969a3d58c7032b743d52
685	2110	Dancers, the Merrill Abbott	\N	D5262	T5641	\N	65d93a8134e52c0f7368a410f9a734c3
686	4062002	Abbott, Mike	\N	A1352	M213	A13	9d763cc35e6c3a1b7f440308e65ef87b
687	2113	Abbot, Mike	\N	A1352	M213	A13	29ac31be5199dae64925163fc9415a9b
688	2115	Abbott, Mitch	\N	A1353	M3213	A13	2d76a434a5c76bb35757d9a1a0868e41
689	4062003	Abbott, Patricia Davey	\N	A1313	P3623	A13	53305b401ddfcf7fe3df66cc2a64e412
690	4062003	Abbott, Patricia	\N	A1313	P3621	A13	ec03efdfa732e1eeb3587b8ee324a103
691	4062004	Abbott, Paul G.	\N	A1314	P4213	A13	fd60f3f5a3b5986a560cf397dd7fa644
692	3564739	Abbott, Lt. Paul W.	\N	A1343	L3141	A13	2a27ebaae8eb103079347dfd0a96646a
693	2133	Abbott, Phil	\N	A1314	P413	A13	8e90dc9c461874a169e96e72d6259e39
694	2136	Abbott, Raymond M.	\N	A1365	R5351	A13	b2bf4406e8d42412a4c2657d959df50d
695	4062005	Abbott, Bob	\N	A131	B13	A13	0f58fd6348d5da31f2d3d3487a6dc2c0
696	4062005	Abbott, Robert B.	\N	A1361	R1631	A13	e8b20fe07b2d79a3ddda31de3ef57622
697	2147	Abbott, Mr. Robert S.	\N	A1356	M6163	A13	3c85289df97f3268083eeff0cb14a2d8
698	2150	Farce, Air	\N	F626	A6162	F62	faac369c8338d3e8d19487595f7d57ac
699	2150	Farce, Royal Canadian Air	\N	F6264	R4253	F62	87a54961600d4bc06c3980d336bc487d
700	2150	Royal Canadian Air Farce, The	\N	R4253	T6425	\N	5dfb56a30208ccfb1f796af75cd3b5da
701	4062006	Abbott, Ron	\N	A1365	R513	A13	a6bd44131f71f284672ae5d30366daf4
702	1740427	Abbott, Sarah M.	\N	A1326	S6513	A13	ca76447bfb4af4a861078a5870ddfb81
703	1740427	Abbott, Sarah	\N	A1326	S613	A13	203d5f748f33b4ddd29a2ff9f3250801
704	4062007	Abbott, Shannon G.	\N	A1325	S5213	A13	57b359df62f55a0f6eb581225423516b
705	2160	Abbott, Steven	\N	A1323	S3151	A13	02b21b022bd125e8d326eadfd418d00d
706	2170	Abbot, Thomas	\N	A1352	T5213	A13	7e8f13c9b44e039b6a3a275a045cfbf0
707	3316999	Abbott, Tim	\N	A135	T513	A13	656cf4ede5aac324dac2797cd29cef73
708	2173	Abbott, Tom	\N	A135	T513	A13	b43b89ee5f326f384c9014afe29fbce9
709	3564752	Abbott, Vincent	\N	A1315	V5253	A13	18b81fdf9f45e9fd9a7438a96fb019de
710	3063965	Abbott, W.J.	\N	A132	W213	A13	1914a588ce54a8f39339a937f7e759e1
711	2183	Abbott, K. Zachary	\N	A1326	K2613	A13	99535e9af5c2a4e4417d284af5bc6374
712	2185	Abbott, James	\N	A1325	J5213	A13	14403b79701c829194dd4856181cb96b
713	2185	Donnelly, James	\N	D5425	J5235	D54	e30a7eec0d99bcfc5bad6d786374cc29
714	1740442	Abbott, Vickie	\N	A1312	V213	A13	c0449c112418e61caf9ae51164feb6a0
715	2701463	Abbou, Jean Marc	\N	A1256	J5621	A1	2a6b16953c94312aabf1efda54724f87
716	2192	Abou, Pierre	\N	A16	P61	A1	085d572728e02b86f09c64b30dccf918
717	1740449	Abboud, Carole	\N	A1326	C6413	A13	5a439a7ff68afef24a688886e7a53fc6
718	1740450	Aboud, Colette	\N	A1324	C4313	A13	bf86875f9b159591a6c60222ddc7c3dd
719	4062008	Abboud, Dan	\N	A135	D513	A13	f8aa3492d69b4dd9f034dd4475bb52a5
720	2203	Abboud, Nor-Eddine	\N	A1356	N6351	A13	e1e6a50ea907c60fe1ec46270f588cc0
721	2203	Assoud, Nor-Eddin	\N	A2356	N6352	A23	fb83db63b193bb42ae7932ae61a71118
722	3564758	Abboud, Rob	\N	A1361	R13	A13	2ea04f8a962b7729f7d862026f636481
723	1740457	Mallette, France	\N	M4316	F6525	M43	d2b22b99f4376277fee354078127c910
724	3564761	Abbrugiati, M. Vittoria	\N	A1623	M1361	\N	9ff403faee2b1dd31988e6e99e7e2faf
725	3564761	Abbrugiati, Mariavittoria	\N	A1623	M6136	\N	47a4fcb2035bd1ff0b70023731c6f4c4
726	3564761	Abrugiati, Maria Vittoria	\N	A1623	M6136	\N	1e7f3be54d21f750a431eb50e86aaa2e
727	2214	Abbruzzese, Guiseppe 'Joe'	\N	A1621	G2121	A162	4d81104616c52ed1d6583d1789677e88
728	3564764	Abbruzzese, Anthony	\N	A1625	A5351	A162	d69a6380e754cbfc7e5d0f65476036ba
729	1740476	Abbe, Michele	\N	A1524	M241	A1	17ad529d241c00609f517019a9b96b89
730	1740476	Abbe, Michèle	\N	A1524	M241	A1	257f0e5de8beca9229e84f4f527ef4b2
731	1740476	Abbe-Vannier, Michele	\N	A1565	M2415	A156	0aa2c5fa455e0a70ed388890744a373c
732	1740476	Abbé, Michèle	\N	A1524	M241	A1	ce54d0dc5b815fb015ba9d3cdb846ca5
733	3063973	El Qudouss, Ehsan Abd	\N	E4232	E2513	\N	fbd11be831f4b736a57fc4a032a30e6a
734	3063973	El-Kodouss, Ihsan Abd	\N	E4232	I2513	\N	e34928765e187c224a275355eadcf884
735	3063973	Elkodous, Ihsan Abd	\N	E4232	I2513	\N	b37e882e0824e413edbbe8a644d4f082
736	3063973	Koudous, Ehsan Abdel	\N	K3251	E2513	K32	612fcf350485c0e3fde273cd802b0a6d
737	1740480	Daoud, Ayat	\N	D3	A3	\N	0bffb5fc3fcb4d749e00b5dffb8d3e2b
738	1740481	El Farrag, Nadja Abd	\N	E4162	N3213	\N	8b95d4aab13c63e783fd27959eedab2f
739	1740481	el Farrag, Nadja 'Naddel' Abd	\N	E4162	N3253	\N	ee4f60d4200b17e5a1af8eafbbbc6a46
740	4062009	Abdlhamid, Hmaoui	\N	A1345	H5134	\N	5ae6d8ea3fe20b6fd0fa9ed787e6dc28
741	1740483	Elhadi, Maysa Abd	\N	E4352	M2134	E43	20ee3743d1173d3c27f9aaefd9194d43
742	2239	Abd-Allah, Dr. Umar F.	\N	A1343	D6561	A134	4da071741c3418a140d1b9325408f8cd
743	2239	Abd-Allah, Dr. Umar Faruq	\N	A1343	D6561	A134	c38f4810d8a86e983ba97e6304eef962
744	1740489	Abdala	\N	A134	\N	\N	81aa3b0455cd73d6ba6d5eaba00eef0c
745	2250	Abdala, Jose	\N	A1342	J2134	A134	9489953d62a681c3d354600fda7509cd
746	2701475	Abdali, Ahmed Al	\N	A1345	A5341	A134	2ec2366b9ad8a9c8426e5f57338cc190
747	2701475	Abdali, Ahmed	\N	A1345	A5313	A134	a0b5fb01915eb8f974b03955adc15695
748	2260	Al-Sayed, Ahmad Abdalla	\N	A4235	A5313	A423	05f86814c51127f33fbe47b776ac5027
749	2260	Alla, Ahmed Abd	\N	A4531	A5313	A4	cd535b8ac45bbb97038569ad4bbb445a
750	1740493	Abdalla, Mikayla	\N	A1345	M2413	A134	f96f1d7714bf023a138f2fa59b341f4e
751	1740495	Carmo, Paula	\N	C6514	P4265	C65	ddef2d4d1fce43addaa6a685b085d892
752	1740501	Alabdalla, Hala	\N	A4134	H4134	\N	a3b2d4a54e2148742e2d99e69fcf3307
753	1740501	Yakoub, Hala Alabdalla	\N	Y2141	H4134	Y21	f35d7908a179db2002cf59eea7ccb471
754	2290	Abdalla, Milton	\N	A1345	M4351	A134	88d2d76d50b3a99d229d1a38286161a6
755	2292	Abdallah, Dr. Mohammed Ahmed	\N	A1343	D6535	A134	ca3f5c6c3740239d2081c0648d225eee
756	2293	Abdallah, Mohren Ben	\N	A1345	M6515	A134	f4007dc81c10a76ae4075888e9473977
757	1740504	Abdala, Rose	\N	A1346	R2134	A134	dfbc5a14b9f0349c7844d4f05f7c36fa
758	2305	Abdalov, P.	\N	A1341	P1341	\N	6e76942dbb6ca9575136a8d6b7eea405
759	2306	Al, Abd	\N	A413	A134	A4	2416427e958748900e1659ee39204c1f
760	2320	Azeem, Mohammed Abdel	\N	A2531	M5313	A25	854f2ab2a842fca78767c1da67eb1257
761	2322	Abdel-Azeez, Kareem	\N	A1342	K6513	\N	0f74f5a682444dcaadada362a4dd1d46
762	1740510	Aziz, Loubna D.	\N	A2415	L1532	A2	41028acbba1b8aa072d93b31cf0fe227
763	1740510	Aziz, Lubna	\N	A2415	L152	A2	0f5ba6e9ca78d8cb260b238a2e2dff1f
764	1740510	el Aziz, Lubna Abd	\N	E4241	L1513	E42	e00f6af2ae4c5c88b999ac331ec444c1
765	2325	Baky, Abdel	\N	B2134	A1341	B2	45288b326abbb090811c7f5fd935eecf
766	1740512	Ghafour, Reham Abdel	\N	G1651	R5134	G16	b4083602f1fd5368044c0146bc80d125
767	1740515	Hamid, Berlenti Abdul	\N	H5316	B6453	H53	d5d297256e72dbc87e8bedd4ae51e54b
768	4062010	Nour, Nasri Abdel	\N	N6526	N2613	N6	fb1ab85b1554fd8b7abc6a4f8e878ac2
769	2349	Rahman, Capt. Mohamed Abdel	\N	R5213	C1353	R5	14040a8bae34c8a3773f002266b4be8a
770	3564782	Rahman, Dr. Motaz Abdel	\N	R5365	D6532	R5	6def24e0af03fd22ba59bad20a81ccbf
771	1740521	El Razek, Ghada Abd	\N	E4623	G3134	E462	25b98e6ec8e20bd37d399098bec28892
772	3063992	Abdelsalam, Professor Shadi	\N	A1342	P6126	\N	c9cc224c36b454e74e49bebe41ca430a
773	1740522	Salam, Rachida Abdel	\N	S4562	R2313	S45	339ec4ee1b57372dea55d41e65c550ea
774	1740522	Salam, Raschida Abdel	\N	S4562	R2313	S45	48203d059a76bd466d2191894b2890f9
775	1740522	al-Salam, Rashidah Abd	\N	A4245	R2313	\N	d7cfa0d03de176bcf031d1c3e0916144
776	4062011	Shafi, Haidar Abdel	\N	S1361	H3613	S1	e8e5134df74236d72ba25cabb8dec63a
777	2355	Wahab, Mohammed Abdel	\N	W1531	M5313	W1	dc2bed062a17fa8ad45bda7f5f757ec7
778	2367	Abdel-Al, Dr Nasser	\N	A1343	D6526	A134	e37ba9cf86b62d08af8232fd4af84291
779	1740527	Abdel-Maksoud, Nora	\N	A1345	N6134	\N	9655b2f122d0f94c93ec79f8027f39a4
780	2378	Monem, Tah-Rick	\N	M5362	T625	M5	cdd836315c74b87bd755d8e0b4419ef1
781	1740529	Shahid, Nada Abdel	\N	S3531	N3134	S3	5d00136240713f345bcb4ebfd9f4f971
782	1740529	Shahid, Nada	\N	S353	N323	S3	0a940cb3fad34c8aac8d022b56ff0e34
783	1740529	Yousif, Nada	\N	Y2153	N321	Y21	7b30153186f23d5e8f4e9c34505c06da
784	3564790	Abdellah, Abdeslam Ait	\N	A1341	A1324	A134	ff91548767a109e86a75c9d6ac1e87a6
785	2406	Abdelghani, Hassan	\N	A1342	H2513	\N	63d436e37f78c7d949718973d686e75d
786	2409	Hatim, Abdelghafour	\N	H3513	A1342	H35	8daa2baf1ff29c9d73b8b5875763689d
787	4062012	Abdelaghni, Baba	\N	A1342	B1342	\N	47899215b260e2919ea7721f6ab7c9b2
788	4062012	Baba, Abdelchani	\N	B1342	A1342	B1	20d667b46f479b509bc696608872f22c
789	2413	Abdelghani, Lasfar	\N	A1342	L2161	\N	fecd05f9b98aee8fd2db892a0a17e720
790	2413	Lasfer, Abdelghani	\N	L2161	A1342	L216	7b23838e4443f668af9a11ecf6697c92
791	3564793	Abelhadi, Elabdi	\N	A1434	E4131	A143	7950e9efeec953e7af3403046dfbf626
792	2422	Belmjahed, Abdelhak	\N	B4523	A1342	\N	c85d58a6185f00ca1db6d357ab135db5
793	2434	Abdelli, Kader	\N	A1342	K3613	A134	b88ca872ba47e312cd65a2d839ce8963
794	2434	Abdelli, Kamel	\N	A1342	K5413	A134	fbb22713ae55fcc2a8889141cdd06eba
795	2439	Taleb, Abdelkader Alaoui	\N	T4134	A1342	T41	5019b1b17dbff6f6e12c7d89b9c16953
796	2440	Aizoun, Abdelkader	\N	A2513	A1342	A25	dd75ed3a2f5a43c516e9337350af7882
797	2459	Abdella, Sgt. Joe	\N	A1342	S2321	A134	29b2c8ee0f5484182f763c951cef1824
958	3058	Abe, Cameraman	\N	A1256	C5651	A1	4e3a68aae28cb340053c80c10b30ae8d
798	2460	Abdala, Marlon	\N	A1345	M6451	A134	85a90e39f3f493f5bbb2b7fa3f7a2c89
799	2479	Abdelli, Lofti	\N	A1341	L1313	A134	a6ea5956fca3315a8d8ae5e398f8d61d
800	4062013	Abdelmalek, Sonia	\N	A1345	S5134	\N	c8e6dddd883b21ab0baf6125aa0706aa
801	2495	Chouayet, Abdelmonem	\N	C3134	A1345	C3	333bf7d87c66d25539a7f2c83af0207e
802	2495	Chouiette, Abdelmonem	\N	C3134	A1345	C3	f6047b0fa4b942b270efa367fe08e27e
803	4062014	Abdelmoumen, Mohamed	\N	A1345	M5313	\N	b7e23a4e30764121647582114aa012b7
804	1740547	Nour, Cyrine Abdel	\N	N6265	C6513	N6	28982c3e481ec8329422448feb0e3c9c
805	1740547	Nour, Sirine Abdel	\N	N6265	S6513	N6	7b70880ab5e27471636c155974dff9f1
806	1740547	Rahme, Serine Abdel Nour	\N	R5265	S6513	R5	30451feee34d75edaaacdf742fb7f9f6
807	3064007	Abdelrahman, M.	\N	A1346	M1346	\N	7ef5fdd7f2d62192be2bd83592320444
808	2512	Abdelouahab, Adil	\N	A1341	A3413	\N	87a8767df58d35c34b0ec0a9b4870e0c
809	2512	Abdelouhab, Adil	\N	A1341	A3413	\N	cc2ed978b9a9ce8230ed3e2c6b03ae66
810	4062015	Bissar, Abderrahim	\N	B2613	A1365	B26	24d019b673068ea91955ceacceb73de6
811	4062015	Mohamed, Bissar	\N	M5312	B2653	M53	9ce677adaba22c91a7be55764250cf85
812	2530	Cheers	\N	C62	\N	\N	a586edb3ff2c4f16faf52ba4cc0b3132
813	4062016	Kadech, Abderrahim	\N	K3213	A1365	K32	368f62e3b643cdab17dfbbbbd8a99453
814	2531	Cheers	\N	C62	\N	\N	a586edb3ff2c4f16faf52ba4cc0b3132
815	3228532	Abderrahan, Antar	\N	A1365	A5361	\N	93881c8a131f6a18e67c3d8d116bba17
816	3228532	Abderrahman, Antar	\N	A1365	A5361	\N	8fafef8e8326cee20cd532c7e11e9650
817	2539	Abderrazzaq, Marwan	\N	A1362	M6513	\N	06731775dd00082ed2dedba5b69148c8
818	2541	Chellaf, Abdeslam	\N	C4132	A1324	C41	9efcc7bacb6a3df706e039afe84f4e9a
819	2541	Langry Jr.	\N	L5262	\N	\N	c163169cc2b1ad9f141cb2ad074315fe
820	2541	Langry	\N	L526	\N	\N	2a4bdc7bb0b8bd39bca3440fe2b97246
821	4062017	Manoel, Abdessamad	\N	M5413	A1325	M54	32dff64d4111747e1375dbb9b5ae601f
822	4062017	Manouil, Abdessamad	\N	M5413	A1325	M54	dc7e336f25e301c624867b43e345db00
823	1740562	Abdi, Dr. Hawa	\N	A136	D613	A13	3ce70a516b268542236d08bd1773cdc9
824	1740563	Honeyz, The	\N	H523	T52	H52	b6bc0c0e5cbb9982e1fde27cd0e1a32f
825	1740563	Honeyz	\N	H52	\N	\N	8d606c4c1e24604c4350a71e57fab856
826	2582	Abdigappar, Niyaz	\N	A1321	N2132	\N	eeff105eb37f3371484cbd5005cee72e
827	3064009	Abdil, Amina	\N	A1345	A5134	A134	f6c69ceb7bf0143013be7b3b571da77a
828	1740578	Abdo, Carmita	\N	A1326	C6531	A13	3f58e55e4e3b775fb5e88102acf877b6
829	1740580	Abdou, Fifi	\N	A131	F13	A13	4bcba21a9cba61e077256b3b59968ce0
830	3564820	Abdo, Dr. Francis J.	\N	A1361	D6165	A13	494c9c521e66ce80ca5c4ad0790867ef
831	2609	Abdou, Jihad	\N	A1323	J313	A13	cd0f6c62a6a40343db8b4c2b76840ddb
832	2610	Abdo, José	\N	A132	J213	A13	7bbed98062699bd252e4f1b0eade20e7
833	1740590	Abdollahyan, Fatima Geza	\N	A1345	F3521	\N	828c2a977587f1809746cea9ed0e51a3
834	1740595	Abdoo, Rose M.	\N	A1362	R2513	A13	9eda6b4a1c920d80ad99f8947044e32b
835	4062018	Abdool, Al	\N	A134	A4134	\N	fe2bf08d5221e01b33f1477051e8187f
836	3228540	Aboulmagd, Hossam	\N	A1452	H2514	\N	f5f2837db1ae9edd44a3a1b3fbd8b4d9
837	3228540	Magd, Hossam Aboul	\N	M2325	H2514	M23	7d4fe03e4fcdf76e6d47a5228eb69226
838	2661	Abdoune, Ali	\N	A1354	A4135	A135	c72596e57047a96363a3b503fa705d3d
839	2667	Abrakhmanov, A.	\N	A1625	\N	\N	4bf157e9b4c21aca3a076a0b52819f84
840	3064015	Abdrashev, Rustem	\N	A1362	R2351	\N	0ca93814fe208a7704c9e45e54def759
841	2669	Abdraschitow, Wadim	\N	A1362	W3513	\N	7eb2a649968e86237f7a5830f7e95030
842	1740610	Abdrazaeva, Tynara	\N	A1362	T5613	\N	3e9dd9669f0331c75a7e53fe174efda1
843	2689	Bhai, Abdul	\N	B134	A1341	B	b7d971eedcb65affb345b36e1127ed18
844	4062019	Bhai, Abdul	\N	B134	A1341	B	b7d971eedcb65affb345b36e1127ed18
845	3564839	Abdul, Computer	\N	A1342	C5136	A134	722e3877cc424a2799f53352111ac49b
846	2718	Ahad, Elias Abdul	\N	A3421	E4213	A3	451a2af493667180be60594f2ae50d0f
847	2728	Abdul, Detective Salaam	\N	A1343	D3231	A134	3eca925940da9c4486679cdada767b18
848	4062020	Abdul	\N	A134	\N	\N	e80a0702d314d055d05af996fe60cff9
849	4062020	Sheikh, Abdul	\N	S2134	A1342	S2	df38d2c7a07c88715a34ae111570dcd7
850	2738	Jaleel-Adil, Dr.	\N	J4343	D6243	J434	6394e31bc61b46b9c65b252ffb2f9b81
851	2746	Khalim, Mokhd Rizal Abdul	\N	K4523	M2362	K45	1adcbc36170cad77bc5c485e43217e50
852	2748	Abdul-Jabaar, Kareem	\N	A1342	K6513	\N	da48c6378cc9c61616e992e04b6b2533
853	2748	Alcindor, Lewis Ferdinand	\N	A4253	L2163	\N	2235d8d2f49f4aa305648e2dc9308601
854	2748	Alcindor, Lew	\N	A4253	L4253	\N	6961ee602560629066dc639b8660807c
855	2749	Abdul-Jabbar II, Kareem	\N	A1342	K6513	\N	cf08f7a83e9d70e39bf9cfeb54eefbf9
856	2749	Abdul-Jabbar Jr., Kareem	\N	A1342	K6513	\N	62074094557d700abd5062ce1551fab7
857	2749	Jabbar II, Kareem Abdul	\N	J1626	K6513	J16	b40e1d5453c593e748bd975ea972c5df
858	2751	Jabbar, Martin Abdul	\N	J1656	M6351	J16	cd119d90bb607fc0e6119c5b57490bc6
859	1740624	Abdul-Jillil, Aminiah	\N	A1342	A5134	\N	cfb2361f2fd8ab20dc1e427c2697e1e3
860	2759	Bilal	\N	B4	\N	\N	de1b65f6bb26bc73eb06674a2aab5161
861	2760	Mansour, Malek	\N	M5265	M4252	M526	cb72430f0d42b3aba06ed94e354be85b
862	4062021	Ogli, Nawruz Abdul	\N	O2456	N6213	O24	78290205dd858c7f96369358b3f641d9
863	2769	Bilal	\N	B4	\N	\N	de1b65f6bb26bc73eb06674a2aab5161
864	2769	Boys, The	\N	B23	T12	B2	38221acc5dfd2342f29f46ccc5559917
865	2770	'Hakeem'	\N	H25	\N	\N	9e708e68d36586cb1d3c6e75d1193ca9
866	2770	Abdul-Samad, Hakim	\N	A1342	H2513	\N	4834e5470a9928b0b561974b0ada65a9
867	2770	Abdulsamad, Hakeem	\N	A1342	H2513	\N	12ff1678e1d169849b71289419c9805c
868	2770	Adbulsamad, Hakeem	\N	A3142	H2531	\N	33ca6eb61cf65cde0a1a6fee08275cd6
869	2770	Boys, The	\N	B23	T12	B2	38221acc5dfd2342f29f46ccc5559917
870	2770	Hakeem	\N	H25	\N	\N	3d55a3672cc280b7b83aaffa71811fcc
871	2771	Abdulsamad, Khiry	\N	A1342	K6134	\N	503b57da84f829662c18abd635f1f7cc
872	2771	Boys, The	\N	B23	T12	B2	38221acc5dfd2342f29f46ccc5559917
873	2771	Khiry	\N	K6	\N	\N	2105375b992c18f5359e64130c69ce16
874	2772	Boys, The	\N	B23	T12	B2	38221acc5dfd2342f29f46ccc5559917
875	2772	Tajh	\N	T2	\N	\N	bca97c9c715883fff091fad6d19091e8
876	1740634	el Aziz, Yasmin Abd	\N	E4251	Y2513	E42	b42d60057a0ae29ee39aa83dc63f0c08
877	4062022	Abdula	\N	A134	\N	\N	446b41dda0312ea708808850191949fd
878	4062022	Abdullah	\N	A134	\N	\N	1cbc455c31531a6b16435a0ef32faaf4
879	2816	Abdulla, Mr. Isa Ghuloom Redha	\N	A1345	M6245	A134	cce087287082865b84a2b266e446e7c4
880	2821	Abdulla, Naseer	\N	A1345	N2613	A134	46a5cd02f49c55aac28f960b18d0df1a
881	2821	Abdulla, Nasser	\N	A1345	N2613	A134	04749b3c7a0e40bf51cd9d7470059665
882	2821	Abdullah, Naseer	\N	A1345	N2613	A134	bfce14dccabafd2130e9c681d5b3f985
883	2821	Abdullah, Nasir	\N	A1345	N2613	A134	b8ff1d51a23565467834454ed74cda1d
884	2821	Abdullah, Nasser	\N	A1345	N2613	A134	4d3b9839b452b81798b694f1c4c9ef43
885	2821	Abdullah, Nassir	\N	A1345	N2613	A134	ac0eb5e02091b5556b95ce6de311c136
886	2828	Abdullayev, A.	\N	A1341	\N	\N	f0f11a1f25c9c558395fa0036fee74c2
887	1740647	Assorti	\N	A263	\N	\N	e3c99779a8c6310096e447e98ec77c99
888	3564858	Abdulla	\N	A134	\N	\N	2eacdb9a3b599fa07b5b4a7a2dedeca9
889	4062023	Abdulla	\N	A134	\N	\N	2eacdb9a3b599fa07b5b4a7a2dedeca9
890	2835	Abdulla	\N	A134	\N	\N	2eacdb9a3b599fa07b5b4a7a2dedeca9
891	2837	Jordan, His Majesty King Abdullah II of	\N	J6352	H2523	J635	43ccd334fb8dab09616f2e57d3207bfa
892	2837	Jordan, King Abdullah II of	\N	J6352	K5213	J635	73df6ad584a935b4041c8fc26507dd30
893	2837	Jordan, King Abdullah of	\N	J6352	K5213	J635	49f229619950e7e23be2e31ef3be5fbd
894	2837	Jordan, Prince Abdullah of	\N	J6351	P6521	J635	4c3df496543ebb6c502577b948a42246
895	2840	Abdullah, Dr. Abdullah	\N	A1343	D6134	A134	16db877b1404e0e284dd1981fe6d28b0
896	1740654	Abdullah, Burçin	\N	A1341	B6513	A134	dbd69be54a663e394ce80beb3a6557f8
897	2858	Abdullah, Dr. Daud	\N	A1343	D6313	A134	d02a0436f47fd4ea8288278be5a74e76
898	1740655	Devyn	\N	D15	\N	\N	5806a3b931a73135e48369e0c99fd2dd
899	4062024	Abdulla, Dimen	\N	A1343	D5134	A134	a7f8e00f983e6a26987e52ebaf8d1ef6
900	4062025	Abdullah, Dr. Farooq	\N	A1343	D6162	A134	9780569c819053742b1e8c5d406aa178
901	4062026	Abdullah, Dr. Farough	\N	A1343	D6162	A134	17cd666debdb16139904df6e8e588518
902	2864	Abdul, Haji	\N	A1342	H2134	A134	e7249e712326aca81c7040cdd67baaf3
903	2864	Abdull, Haji	\N	A1342	H2134	A134	8e784d7cceb8d6b630a8ab64761f20fc
904	2864	Abdull, Khalid	\N	A1342	K4313	A134	843ca090dc34c28bc17cc3c4481923ac
905	2871	Abdullah, Joseph	\N	A1342	J2134	A134	37a824212a7978079c6de35ee815a35a
906	3564865	'Abdullah, Kwaku	\N	A1342	K2134	A134	f5e01fba0c2e2948f3a9091072c2217e
907	3564865	'Abdullah, Kweku	\N	A1342	K2134	A134	52b78a65e7daaaa3fc06edc73c68141a
908	3564865	Ware'Abdullah, Kweku	\N	W6134	K2613	\N	67f2eba363201907a8b460c4761583bc
909	2876	Subash, M.	\N	S125	M212	S12	fa2d82f1bb999c1b0f9e7795e059feb7
910	4062027	Abdullah, Mogamat	\N	A1345	M2531	A134	c97b5ae4a9386ba72fa829293a4d9aa9
911	2883	Abdul, Mohsin	\N	A1345	M2513	A134	e675ecf84b746987f4c3bb6ac5842f4f
912	2883	Abdulla, Mohsin	\N	A1345	M2513	A134	8a57f3e0963e39077523b4dfb751e3d0
913	4062028	Morocco, His Royal Highness The Prince Moulay Abdullah of	\N	M6264	H2642	M62	7593757bb349a70fa5129eaf86a05e8c
914	2887	Daglioglu, Abdullah	\N	D2424	A1343	\N	252e2d77d12656175975a587e386cd7e
915	2887	Fahim, Abdullah	\N	F5134	A1341	F5	391ea54836f09db5491e753246e4e71e
916	4062029	Abdullah, Faisal	\N	A1341	F2413	A134	74e5aeafff3132b0623ea783d627fc54
917	3064025	Abdulla, Raficq	\N	A1346	R1213	A134	5a3875f42dc7e4b7f53d08d3df73a13e
918	1740682	Abdullah, Khadijah	\N	A1342	K3213	A134	98feaf1ef16271c38a3042c6bab6405d
919	3228555	Abulahi, Mohammed	\N	A1453	M5314	A14	5e68516c3b79fa0cd30a086594122916
920	3228556	Abdullayev, D.	\N	A1341	D1341	\N	df2aaf99714cf4282b8d65041aebba16
921	2925	Abdulaev, Farkhad	\N	A1341	F6231	\N	22f43bba91437ce26c727499fb04aba5
922	2927	Sakili, Farman	\N	S2416	F6524	S24	e3e4823cf53067ad07b7e71817123083
923	2931	Abdullayev, K.	\N	A1341	K1341	\N	d64da8b6450d54e168f733c67802fdfa
924	2931	Abdullayev, Kazim	\N	A1341	K2513	\N	8ebbe618d7ff842814d10b92f79daf3c
925	2932	Abgulayev, L.	\N	A1241	L1241	\N	a1b57d75d47f4957264f76879779e36c
926	2936	Abdulayev, N.	\N	A1341	N1341	\N	1185ec4348df42ff0860a8ba8b2e526d
927	2936	Abdulayev, Nurullo	\N	A1341	N6413	\N	9c7ecc28046a93feda6f74189e935c07
928	2936	Abdullayev, N.	\N	A1341	N1341	\N	861882d02871ae622ebb9a55025fc7f4
929	3564873	Abdullayev, T.	\N	A1341	T1341	\N	925e8dc25a2efe77aaa55170ad777190
930	2950	Abdullayev, Fatkhullo	\N	A1341	F3241	\N	900a7914a99bec5ea338d47aeb4be5ea
931	2954	Abdulov, A.	\N	A1341	\N	\N	2f976cfff7cc8ef04c7f76365567c4c9
932	2954	Abdulov, Alexander	\N	A1341	A4253	\N	56f24336c596f6163ccb3e468a6cac21
933	2956	Abdulov, O.N.	\N	A1341	O5134	\N	d0cf6a5b876e28c1628d32b096e755ed
934	2956	Abdulov, O.	\N	A1341	O1341	\N	1da99d6d279d180486799965c1454c31
935	2957	Abdulov, Vitali	\N	A1341	V3413	\N	981633e28c64b8e114b43bf12584708e
936	2958	Abdulov, V.	\N	A1341	V1341	\N	888e2b519bb172dd8f8e165326a36224
937	2962	Abdulrahim, Dr. Tajudeen	\N	A1346	D6323	\N	de65745975052b6fc201336d92d3865b
938	1740700	Nadja, Abdulwahab	\N	N3213	A1341	N32	78d6c58791861a376d7878eb0297999d
939	2978	Idries	\N	I362	\N	\N	f8d97f321f68fd7deff590c1a732460d
940	2980	Jamil	\N	J54	\N	\N	cd7e165cc44e4d1176b294afb4f11fc3
941	4036954	Abdürrahmanov, Arif	\N	A1365	A6136	\N	c20e967733f3dd871b9c33924b6c98ce
942	4062030	Abdumaran, Umbe	\N	A1356	U5135	\N	5b54f71a7d49733cf906e4160cee37e8
943	4062030	Abduraman, Adan	\N	A1365	A3513	\N	405bfbbd9c8917e77ef9834d84b5d19b
944	4062030	Adan, Abdul	\N	A3513	A1343	A35	30a522e2567d3dff2998828c2e17e108
945	4062030	Adan, Abduraman	\N	A3513	A1365	A35	877c0739bdbcf33babe41e66a15a356f
946	4062030	Adan, Umbe A.	\N	A351	U5135	A35	b7cbaef5f4d36d677a3fa99d4df7f09b
947	4062030	Adan, Umbe Abdul	\N	A3513	U5134	A35	4c9914aac65a1622d4b2d19e979927fa
948	4062030	Adan, Umbe	\N	A351	U5135	A35	6f173698b4b2cfb9b2faf75e9d790cee
949	1740712	Abdy, Pam	\N	A1315	P513	A13	dbe810cf5d00aed9771caaeaa4605ea5
950	3010	Abdyshaparov, Ernest	\N	A1321	E6523	\N	4b1c5dc051e7461a9cce0fea30bb2edb
951	4062031	Abé-Ishii, Carolyn	\N	A1264	C6451	A12	a09be7dc2ad36a20ba7e3d8baff47e2d
952	2701576	Norton, Hatsue	\N	N6353	H3256	N635	a7791b3921547e9eaa6ba9b81402c1a9
953	1740729	Abe, Sei	\N	A12	S1	A1	cfed36346fb844c2f3f035a5d3bafb6a
954	3317025	Ave, Isao	\N	A12	I21	A1	2923f7b420f3926793116b15e5d2c578
955	3317025	Oyaji, Oyaji	\N	O2	\N	\N	df8c8b9a62736bb234d533dcb6001ae4
956	3317025	Oyaji	\N	O2	\N	\N	615e63e1dfaf3b2b936cb69f4c346fa5
957	3064038	Abe, Keiiche	\N	A12	K21	A1	da6bfbda3a765812c7b92efd2da7da21
959	3063	Abe, Kobo	\N	A121	K1	A1	698deea5e296e772067ce4adc875b650
960	1740739	Abe, Machiko	\N	A152	M21	A1	6b85f7d7f988616b80466d55e92c7c87
961	1740739	Anami, Machiko	\N	A52	M25	A5	b5e0cebcf4570bb32fbab086b3aeefb9
962	3075	Abe, Matt	\N	A153	M31	A1	256445ae198470af8f2b12429a1f1c46
963	2701590	Abe, Tomohisa	\N	A1352	T521	A1	5b390d8b6d7908ff2c973288638be775
964	3564914	Abe, M.	\N	A15	M1	A1	e22ba6c8a26dcc0aee92181c16408797
965	2701594	Abe, Naomi	\N	A15	N51	A1	6750281d0899ad010f3bd10d9e6c3bdc
966	4062032	Abe, Singo	\N	A1252	S521	A1	9095df09e65e77acf458beaacd46d8dd
967	2701602	Abe, Shûji	\N	A12	S21	A1	34678cdf7f1e8979726ab640cd8ec14f
968	4062033	Abe, Daizaburo	\N	A1321	D2161	A1	9e7512622b6ef21cd6ce5f172d1606e4
969	4062033	Abe, Taisaburô	\N	A1321	T2161	A1	063b0d5d98773afcc2703b6c664d7e0f
970	4062034	Takashi, Abe	\N	T21	A132	T2	382689b9f4697747fd425b7fa411a8f8
971	3108	Abe, Takehiro	\N	A1326	T261	A1	45328ea7f945a8d5c2a8d136ec62cc05
972	3109	Jackson, Jackie Chan	\N	J2525	\N	J25	dea222f078285def46ac488acff6ca0a
973	4036960	Abe, Kimei	\N	A125	K51	A1	064510c6bb0c438f2807fb16a26270b6
974	3118	Abe, Tsoyoshi	\N	A132	T21	A1	e33911ef2f31b65044dd50a970207ed7
975	3119	Li, Chen-tung	\N	L2535	C5352	L	ada3af00ed851f8c80670fd67f0b1c90
976	3121	Abe, Tooru	\N	A136	T61	A1	5289007f051c351ce3d5a0b08889ce52
977	3564947	Abe, Youko	\N	A12	Y21	A1	77158f255f4ba99fd812ddd6ae7bc178
978	3064049	ABe, Yoshitoshi	\N	A1232	Y2321	A1	925d2309784da3f296f4c45880c9b3d2
979	3442045	Abe, Yu.	\N	A1	Y1	\N	53c3f12847e8da0d71002750d5ebe80b
980	3132	Abbe, Jack Takuta	\N	A1232	J2323	A1	a4f4c3bd7d5055144d90a20f5ca9ff0b
981	3132	Abbe, Jack Yutaka	\N	A1232	J2321	A1	2821726c721511c07aa823494e94c091
982	3132	Abbe, Jack	\N	A12	J21	A1	643ef465c21b4ac51b39eab00eb8c201
983	3132	Abbe, Utaka	\N	A132	U321	A1	8054beb77b4a3caa96bdef19bd389c09
984	3132	Abbe, Utake	\N	A132	U321	A1	b08a6da4b22302948ec2d03552eb1d70
985	3132	Abe, Jack	\N	A12	J21	A1	33705dad61a8e5f766a8dcade99c90ec
986	1740793	Ama, K. Abebrese	\N	A5216	K1625	A5	69892d85a8c369d36170697bd6500706
987	3564955	Abecassis, Laurent	\N	A1246	L6531	A12	a3fe0ed00cba0b6567b08503427f0e90
988	2701617	Abecassis-Amichai, Limor	\N	A1252	L5612	\N	e7645d006514ffeece18550120fcebec
989	3064055	Abécéra, Gilbert	\N	A1262	G4163	A126	b17febf7166bfb616f5cd3e674617796
990	3154	Abecia, Freddie	\N	A1216	F6312	A12	d32355206061071d4ab512a1d9295bc8
991	3154	Abelia, Freddie	\N	A1416	F6314	A14	5198348bbaea20ce48b7aad3cf4d21cb
992	3154	Avecia, Freddie	\N	A1216	F6312	A12	237fff68b84a3ebc948c1d5a238bff79
993	3154	Aviecia, Freddie	\N	A1216	F6312	A12	26fbac2ed96aeb995a53f9a8a820a7b3
994	3155	A, Danny	\N	A35	D5	A	86b40ab7e0cabf2c27c9ed2fbc693bbf
995	3155	Abeckaser, Danny	\N	A1263	D5126	A126	09446cef901b06b1203b9c25be617681
996	3155	only, Danny A - credit	\N	O5435	D5263	O54	f6daa29b6f03c78f1aceea4b07225da2
997	3162	Abed, David	\N	A1313	D1313	A13	637dcfb183d940adb3dc5dc0b304c4fb
998	3168	E, MR.	\N	E56	M6	E	a0ffe8f0ffa1e52cd2fcd4e64ee0fe70
999	3174	Abedalnour, Youssef	\N	A1345	Y2134	\N	a56c6536f47a2f24a5ee6bb04561dc58
1000	3176	Abed-Navandi, Dr. Daniel	\N	A1351	D6354	\N	b3100c24eb14bb8ac4e25182e1cf7d43
\.


--
-- Data for Name: aka_title; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.aka_title (id, movie_id, title, imdb_tiny_index, kind_id, production_year, phonetic_code, episode_of_id, season_nr, episode_nr, note, md5sum) FROM stdin;
13117	833595	Malhação - Adolescência: A Passagem da Infância Para a Vida Adulta	\N	2	2011	M4342	\N	\N	\N	(Brazil) (nineteenth season title)	320b4fa8ae74411e55cde509d9883e9c
6017	393076	Dirty Pair	\N	2	1985	D6316	\N	\N	\N	(USA)	f77196370d0815fd72eb57ea2896c0e3
32738	1662042	Aasman	\N	1	1952	A25	\N	\N	\N	(India: Hindi title) (alternative transliteration)	98743dd72fbc5135079ea0e658deee3d
30289	1651366	Un lac pour la prairie	\N	1	1961	L2164	\N	\N	\N	(Canada: French title)	ff3bbe8a003d03d7bbc55c55f464ce0b
27209	1639798	28 Tage	\N	1	2000	T2	\N	\N	\N	(Germany)	107c90b89a3dc3b296453e3d57a9ab36
35906	1670559	Still Orangutans	\N	1	2007	S3465	\N	\N	\N	(International: English title)	62c03e63118567b64e55f67a98335a45
48289	1708452	Dead Wrong	\N	1	1994	D3652	\N	\N	\N	(Australia)	7c034ac397e1fe86ae9dd019b523d80d
17126	1080309	Reportageholdet: Forsvarsadvokaten	\N	7	\N	R1632	17147	\N	\N	(Denmark) (series title)	41a9c7c526f315fd9e1de11d98ce0dfa
31090	1654848	Typically British!	\N	3	1997	T1241	\N	\N	\N	(UK) (video title)	fe673c589307198ee81829ec955dd99d
11641	751100	Anime hachijuu nichikan sekai isshu	\N	2	1987	A5252	\N	\N	\N	(Japan)	f7b4bfab04e47b268875bf3e989020ac
44686	1697797	Cinderella	I	1	1916	C5364	\N	\N	\N	(USA)	72fb9014d499b619ebadfc441ec1501b
33557	1664452	The Pain	\N	1	1988	P5	\N	\N	\N	(International: English title) (literal title)	1309a1511d3d17a2bb984b2883ff9def
14425	899231	Der Mann im Rathaus	\N	2	1979	M5632	\N	\N	\N	(East Germany) (alternative title)	e24c35c268782896e6dbebea200cacab
15646	979751	Tar det åt hjärtat?	\N	2	1995	T6326	\N	\N	\N	(Finland: Swedish title)	e62f141b6007c1e277d111cab14fd85c
17782	1119850	The Attack	\N	7	\N	A32	17787	1	13	(International: English title)	bfece896ce3e2639c5fb3148cf5fa7b4
41277	1687488	Antonio's Secret	\N	1	2008	A5352	\N	\N	\N	(Philippines: English title)	90ffac03dd2f94f8e97ca00206d5b484
35211	1669200	Yellowcake operazione urano	\N	1	1978	Y4216	\N	\N	\N	\N	8c48378c26e30acdf6a9ab3b73280c8e
34048	1666024	Weda'an Bonapart	\N	1	1985	W3515	\N	\N	\N	(Egypt: Arabic title)	477a15d2de285344e4ad00d5297381e7
4120	253704	Ein Hauch von Mord	\N	7	\N	H2156	4243	3	1	(West Germany)	3b1608b1735f2fb33d4ae5dbc254aae4
32008	1658918	Triumph des Herzens	\N	3	1986	T6513	\N	\N	\N	(West Germany)	5db73dd910ccd0124b9376385fa87bb6
48064	1707580	Children of Heaven	\N	1	1999	C4365	\N	\N	\N	(USA)	350a5cbb6ff5c399b51a12ac6740043e
10442	702203	The Case of Kukotskiy	\N	2	2005	C2123	\N	\N	\N	(International: English title) (informal title)	dd05f3d015f6d0cfb0c7c95cb689317e
37484	1674219	King of the Joropo	\N	1	1978	K5213	\N	\N	\N	(International: English title)	3e2b20917e9ef7521aa099efedb2d953
33821	1665361	Story of Adachi Factory: For the Job Development of the Disabled in the Industrial Vocational Aid Center	\N	1	2012	S3613	\N	\N	\N	(International: English title) (imdb display title)	05e067f0bc1d899ecb23b9cb27680a5c
9060	620172	The Howard Stern Radio Program on Television	\N	2	1994	H6323	\N	\N	\N	(USA) (working title)	fbdb6c5f9738e9d54368ae7deb869b52
16507	1042451	ABC Primetime	\N	2	1989	A1216	\N	\N	\N	(USA) (informal short title)	f67eebb8ea6f85adf511d702259af5ff
25863	1634109	Maybe This Time	\N	1	1981	M1323	\N	\N	\N	(Australia) (informal short title)	bfdf84c7fc032548187e6dc22dce3251
26028	1634429	The Sixth of May	\N	1	2008	S2315	\N	\N	\N	(UK) (DVD title)	c6f4fbff990499ede5dff9e936f9ea56
25107	1615418	Raideen	\N	2	1975	R35	\N	\N	\N	(Italy)	51c64b1feba6e9593e425fb6e91ee32f
45074	1699464	Das Ende	\N	1	1979	E53	\N	\N	\N	(West Germany)	a99683dadc2d565b0f2667445089c6b9
9705	660762	ITV Play of the Week	\N	2	1955	I3141	\N	\N	\N	\N	f1cdec1b5b81f3e4d75a5c4047eda1e7
1050	73554	American Horror Story: Asylum	\N	2	2012	A5625	\N	\N	\N	(USA) (second season title)	e04eb318b6f87ef9ddcb99c2bb405c59
24743	1598994	The Special Unit	\N	7	\N	S1245	24748	11	3	\N	d068de78e577ca62722d1457d91544ba
14714	913971	The Remembered Lullaby!	\N	7	\N	R5163	14723	1	179	(USA)	140b866934f3805afad16612af37272e
47464	1706104	B'Yom Bahir Efshar Lr'ot et Dameshek	\N	1	1984	B5161	\N	\N	\N	\N	e24526048db7e76095d10f8b74032175
31208	1655471	The Girl from Nowhere	\N	1	1931	G6416	\N	\N	\N	(USA) (TV title)	4cb24432ea73b2ea513fb14a42b6ee9d
13493	854715	Tyler Perry's Meet the Browns	\N	2	2009	T4616	\N	\N	\N	(USA) (complete title)	eafb7d557b2354a0644b87e58e5580ea
39721	1681793	Anything for a Friend	\N	1	1973	A5352	\N	\N	\N	(USA)	3e4543f07b22d3daedaa65db417b7c58
43065	1692363	Apocalypto	\N	1	2006	A1241	\N	\N	\N	(Germany)	fa340c59315c1c628d989a18f6b1600b
34629	1667675	Africa strilla	\N	1	1950	A1623	\N	\N	\N	(Italy)	66574c8151474e42c2da9ab5b04dd02e
22288	1417596	Golden Hill	\N	2	1976	G4354	\N	\N	\N	(UK) (new title)	40b0b029309fd6e7d2deb3ab57389687
37780	1674950	Aliyuri	\N	1	1989	A46	\N	\N	\N	(Georgia) (alternative transliteration)	a0e6aa87e415f20b51c56fe74c5abadb
36200	1671269	Red Quay	\N	1	1958	R32	\N	\N	\N	(literal English title)	73377627f765f3b5cb87101201d828ef
21409	1346359	The Howard Stern Summer Show	\N	2	1990	H6323	\N	\N	\N	(USA) (promotional title)	0237d570f748961447d1c4879f143623
7842	544074	Brazil's Got Talent	\N	2	2013	B6242	\N	\N	\N	(Brazil) (working title)	e1346ef54853daabb7905a9a2e5ac430
37475	1674200	La sconfitta di satana	\N	1	1949	S2513	\N	\N	\N	(Italy)	c474b12f9ed9fcf5eaa2051bcd09b549
37643	1674634	Alien Hunt - Attacco alla Terra	\N	4	2007	A4532	\N	\N	\N	(Italy) (imdb display title)	37e5fcd81de137488b4fd3b0d5908e68
13241	840347	Goodbye Marienhof - Die ultimative Fan-Box	\N	2	2011	G3156	\N	\N	\N	(Germany) (DVD box title)	37cb1b4bd124fde0098896d58f747aaa
14830	920181	The Sky and the Earth	\N	2	2004	S2536	\N	\N	\N	(International: English title) (informal title)	9cd72fcdc342d37e4be6ea662b2de214
15017	942686	Nini - den stille uke	\N	2	2001	N5352	\N	\N	\N	(Norway) (second season title)	a86e1ca5383579d159a2962f666669f7
31690	1657794	È nata una stella	\N	1	1955	N3523	\N	\N	\N	(Italy)	df6027a1880a58d713a286949c9b7b59
43342	1693371	Those Crazy Years	\N	1	1971	T2626	\N	\N	\N	(USA)	9cd9753269d19907a5d1427367b0bb7e
23698	1523936	Underbelly: The Golden Mile	\N	2	2010	U5361	\N	\N	\N	(Australia) (third season title)	ffa5503dc03e3e6f96f2217ab33bff29
10823	710217	Kew 3D	\N	2	2012	K3	\N	\N	\N	(UK) (working title)	e7c19c81e85cd0dac4eeb3e48ab26d1f
43863	1694970	Travelling in the North	\N	1	1980	T6145	\N	\N	\N	(International: English title)	03538250e584759c84e2c3ed0d8589c8
29954	1650148	Beatles No. 1	\N	1	1963	B3425	\N	\N	\N	(UK) (working title)	2787c12ca0428cf614c153b8cc6c737d
30689	1653084	Ein mutiger Weg	\N	1	2007	M3262	\N	\N	\N	(Germany)	7e3cef001fe45ca1455af08a03cee565
35478	1669838	The Words of Silence	\N	1	1998	W6321	\N	\N	\N	(International: English title)	b39f74249fe3501bf2fa28c386f3bc50
7240	498911	Amici di letto	\N	2	2011	A5234	\N	\N	\N	(Italy) (imdb display title)	2d1c189f3968096f3a50eb6c9c3fcfd4
20644	1280624	Strandpiraten	\N	2	1976	S3653	\N	\N	\N	(West Germany)	2d22afe6e957208a6d4b8a446a8e2965
7288	502247	Fast Forward Presents Full Frontal	\N	2	1993	F2316	\N	\N	\N	(Australia) (first season title)	d6051acf80b43345c59f81f1ea5fdaac
13783	871452	Headcase	\N	2	2006	H32	\N	\N	\N	(UK) (working title)	f5f5094c6d579dc0930f36df1e381ff8
47114	1705221	Ax - Die Erde	\N	1	1999	A2363	\N	\N	\N	(Germany)	162dd13bb54d1fea35187caa0a3e6558
19230	1202625	Óôï ÐáñÜ 5	\N	2	2005	\N	\N	\N	\N	(Greece) (original Greek ISO-8859-7 title)	633ec9b1e94d1e129002775062715b20
11414	730283	Ein langer Weg in die Freiheit	\N	2	2002	L5262	\N	\N	\N	(Germany)	1c650026b856667c608f6f5e7d10269f
33750	1665116	Bus Action	\N	1	1980	B235	\N	\N	\N	\N	23b1730874d9750afa326ca29905f570
29850	1649695	Fisticuffs	\N	1	2005	F2321	\N	\N	\N	(International: English title) (informal title)	765f3ba4a0cb1f67a3364f35e103c4d0
31102	1654949	13	\N	1	1999	\N	\N	\N	\N	(USA) (working title)	de85cd49b968e25f6506372a47f6033c
242	15590	Tailor-made Murder	\N	7	\N	T4653	247	1	5	(International: English title) (imdb display title)	6f1081dda0e054c6fa39c54ae7a4ceb1
11678	752896	Lance et compte 4	\N	2	2002	L5232	\N	\N	\N	\N	b43d890fc34cd4da8bc0f8993a22c2c6
3482	220739	Run for Money	\N	2	2008	R5165	\N	\N	\N	(USA) (working title)	5e5b072c910f0f977657f83e4d934f53
9003	613765	Hot for Words	\N	2	2007	H3163	\N	\N	\N	(USA) (alternative title)	00f7211343e1d36201fe5a948d08d407
18276	1145219	óÅÚÏÎ ÏÈÏÔÙ	\N	2	1997	\N	\N	\N	\N	(Russia) (original Cyrillic KOI8-R title)	3fc637c451f0a7c141b5f59a4c9e386c
9218	630045	Le spie	\N	2	1965	S1	\N	\N	\N	(Italy) (imdb display title)	e61e01edbf3b15e6786fdfc841bb49ca
37537	1674373	Alice and Martin	\N	1	1998	A4253	\N	\N	\N	(International: English title) (imdb display title)	878ef04838f2b9fedb8aeffbf794be31
31985	1658892	Keine Zeit zu sterben	\N	1	1991	K5232	\N	\N	\N	(Germany)	21d3d542323b0f70a4a232014d6c0167
2770	168134	Club Embassy	\N	2	1951	C4151	\N	\N	\N	(USA) (second season title)	acf3c5c6cc36595574deaa1775351b3a
10523	705444	The Green House	\N	2	1996	G652	\N	\N	\N	(literal English title)	e40fea5c24d4025d57ac13a335a209fa
22096	1404044	The Recommended Daily Allowance	\N	2	2000	R2534	\N	\N	\N	(UK) (complete title)	c0ef4cb983eebbbc7d1955979a51dcfb
26213	1635234	100.000 Dollar für einen Colt	\N	1	1966	D4616	\N	\N	\N	(West Germany)	32dc7a729f3a91224a7c82e986c46202
46783	1704239	The Adventures of Borivoje Surdilovic	\N	1	1980	A3153	\N	\N	\N	(Europe: English title)	3ae7fef59fae991a1a8123c001618e54
2264	148968	Strange Truth: Fact or Fiction	\N	2	1997	S3652	\N	\N	\N	(USA) (working title)	7cdfbaa71d10ba24e3d989d79cb58f33
18717	1166484	SM:TV Gold	\N	2	2003	S5312	\N	\N	\N	(UK) (new title)	907adbbabe8a0009b9aa0ec8df519cda
16019	1012037	Peter der Große	\N	2	1986	P3636	\N	\N	\N	(West Germany)	3973654b49cbbd78522b7435f6b6bf1a
49042	1710528	Memory of Love	\N	1	1973	M5614	\N	\N	\N	(West Germany)	2556cc62b39c22d35ccca32262d51a84
40862	1686140	The Here and Now	\N	3	2007	H6535	\N	\N	\N	(USA) (working title)	74c96cb76c94207d4e8ab2e1f3fe7ca5
28736	1644432	The Happy World of Bunnies	\N	1	1997	H1643	\N	\N	\N	(USA) (working title)	f01eda0a03ce4964e4255168eeeec32c
18088	1136743	Malmequer	\N	2	2010	M4526	\N	\N	\N	(Portugal) (working title)	cca908d3a844027d18e25efbf6580f90
47813	1706743	Babewatch: Scharfe Kurven	\N	4	2000	B1326	\N	\N	\N	(Germany) (TV title)	c5bf8cafb4896414da7cf9b1f001c348
3902	244266	Here Comes Freckles	\N	2	1965	H6252	\N	\N	\N	(USA) (weekend title)	92ede89c6f6e275b95b995c05d93a40d
41330	1687654	A Pillar of Mist	\N	1	1986	P4615	\N	\N	\N	(International: English title) (literal title)	0680cad51631023386f691357c4ec2c7
8121	556505	Goal Field Hunter	\N	2	1994	G4143	\N	\N	\N	(International: English title)	2a8a9e4399ee6beaf30932e8b0b93c21
24854	1605419	Laughing in the Wind	\N	2	2001	L2525	\N	\N	\N	(International: English title)	b51977d36e89ef760b245a92b11856ee
16094	1014463	Sorelle in affari	\N	2	2011	S6451	\N	\N	\N	(Italy) (imdb display title)	b50d4f785930676620f2026f6b27a313
16263	1029009	Police Academy: The Animated Series	\N	2	1988	P4235	\N	\N	\N	(USA) (DVD box title)	4ef03f6d9920e12379c67e132561f5c0
30589	1652691	A Married Man (Who Had Them All!)	\N	4	1978	M6353	\N	\N	\N	(International: English title) (video box title)	477714cb2734fd41c0aed4b707ab0f33
26710	1637200	28th October 1979, a Sunny Sunday	\N	1	1999	T2316	\N	\N	\N	(International: English title) (imdb display title)	f10f83cc4b1ad04ce2b342ab69c417ea
46479	1703317	Hirsekorn Butts In	\N	1	1932	H6265	\N	\N	\N	(USA) (informal English title)	6b0734dd101800eefd8dc37f0f29e373
43456	1693674	Date Wine	\N	1	1999	D35	\N	\N	\N	(USA)	192a10313d21be67ae4bd896deb163ff
5429	358676	Catherine's Wedding	\N	7	\N	C3652	5428	1	1	(International: English title)	80a38c5e447ca5091bcdfa8533b85eaa
11294	727386	Tommy, la stella dei giants	\N	2	1968	T5423	\N	\N	\N	(Italy)	90b3a5887e0e2651c5baa403e670c841
15921	1006676	El otro lado del amor	\N	2	2007	O3643	\N	\N	\N	(USA: Spanish title) (working title)	a8ea2cd8c6dba5bcb708dd2d3aaaaa4f
29372	1647414	Visionen der Angst! - Die Frau mit dem zweiten Gesicht	\N	3	1997	V2536	\N	\N	\N	(Germany)	301e774f47ea19d30cc1b961eaff91fc
1546	107570	Cat Planet Cuties	\N	2	2010	C3145	\N	\N	\N	(USA) (DVD box title)	01c0e4b626e08fc40dbd423941f43f66
46438	1703176	Aus dem Alltag in der DDR - Versuch einer Rekonstruktion nach Berichten und Dialogen	\N	3	1971	A2354	\N	\N	\N	(West Germany) (long title)	997ce859fc7df699943e4944f687cd4e
48733	1709893	Dark Cloud	\N	1	2009	D6243	\N	\N	\N	(International: English title) (imdb display title)	bb9f6203857ff5aa90ab115a589ff41d
32248	1660060	The Red Countess	\N	1	1985	R3253	\N	\N	\N	\N	0aafc91426ec1c5124217efed43ca45d
6119	404293	Anders Refn's Een gang strømer...	\N	2	1987	A5362	\N	\N	\N	(Denmark) (complete title)	f482775d8e65f0f7fa2829a7378dcee5
11853	773089	Blood of the Vine	\N	2	2011	B4313	\N	\N	\N	(USA) (alternative title)	1cebe63f3b3c283d5dab8afa871e0d26
15303	958971	Außer Kontrolle - Leben unter Zwang	\N	2	2009	A6253	\N	\N	\N	(Germany)	f056db710a40c627346ed0d4c24690cc
12188	780272	The Visitors	\N	2	1980	V2362	\N	\N	\N	(International: English title)	6604b293eb94d1a2e5cb8826d51597cc
4543	296551	Don-Don Domel to ron	\N	2	1989	D5353	\N	\N	\N	(Japan)	2060279fc5d20f5f45969c8737b3acc0
4962	332102	Deception	I	2	2013	D2135	\N	\N	\N	\N	e18c413e434c10ab77a9c8e309df50ee
13209	839111	The Marc Wootton Project	\N	2	2008	M6235	\N	\N	\N	(UK) (working title)	d5b28ea7f706a567e730800e0c7e0858
33227	1663405	Yesterday Girl	\N	1	1966	Y2363	\N	\N	\N	(International: English title)	ccef703a2e5d61b72ab0044db625de27
5082	337014	Denjin Zaborger	\N	2	1974	D5252	\N	\N	\N	(International: English title)	99d008989794c82c97fc36b880af30c9
29505	1648120	O Meu Pai	\N	1	2008	M1	\N	\N	\N	(Portugal) (working title)	d066661045f467945a4e6f33fa34a278
29750	1649163	México nocturno	\N	1	1980	M2523	\N	\N	\N	(Mexico) (subtitle)	d983d29673885d94f02eea9613bec1f9
25285	1624815	Zouxiang Gonghe	\N	2	2003	Z2525	\N	\N	\N	(China: Mandarin title) (alternative spelling)	e9dd30215bc70cf3b32384a2df320371
40167	1682829	Willkommen in Amerika	\N	1	2012	W4256	\N	\N	\N	(Germany) (imdb display title)	9972a3453a43e3eed1ed285c9ca03b80
28729	1644411	A beszélõ köntös	\N	1	1941	B2425	\N	\N	\N	(Hungary) (original ISO-LATIN-2 title)	6ab16e97bb1061b30d756df5e0e3a636
14359	896492	Murder, She Wrote	\N	2	1984	M6362	\N	\N	\N	\N	064a9f852153fbed9e5d0f413a856513
6184	406986	Love on Lake Garda	\N	2	2006	L1542	\N	\N	\N	(International: English title)	8b3f5113d098c664fbf3b27d28e790b6
33544	1664431	Achtung! Auto-Diebe!	\N	1	1930	A2352	\N	\N	\N	(Austria)	07ace865e28239bbcc31ba5eea5721cf
21591	1362423	L.A.T.E.R.	\N	2	1980	L36	\N	\N	\N	(USA) (short title)	9f472f6e19e9775111df07136222bc63
9043	618217	How Not to Live Your Life - Volle Peilung	\N	2	2007	H5341	\N	\N	\N	(Germany)	9ac3f396d6f00199f155a9094d3491c8
39205	1679888	Prosjekt 3	\N	1	2000	P623	\N	\N	\N	(Norway) (working title)	1568c618c814b9b1c0e51a69708eb874
33069	1662940	Deadly Blaze - Heißer als die Hölle	\N	1	2001	D3414	\N	\N	\N	(Germany) (imdb display title)	6833bf97b575f506a9b9aa5f70421ca2
11187	724628	Gydas vei	\N	2	1998	G321	\N	\N	\N	(Norway) (new title)	1eace22a4a9b53881377a60d6849adc1
36088	1671008	Ayvazovskiy i Armeniya	\N	1	1983	A1212	\N	\N	\N	(Soviet Union: Russian title)	8ecbbdf36e97769ee41fce57fe9ac82d
17313	1089575	Robinson ekspeditionen 2001	\N	2	2001	R1525	\N	\N	\N	(Denmark) (promotional title)	6878d4f07d05e3f9466129258c373377
13548	857734	Wherefore Art Thou Lennox	\N	7	\N	W6163	13547	2	12	\N	9f77b90c7215069c82e87b79ef354af7
30516	1652435	Man and Monkey	\N	1	1899	M5352	\N	\N	\N	\N	1a03be3f6cc80712d054367efd34f5fd
28745	1644474	Höchster Einsatz in Laredo	\N	1	1966	H2365	\N	\N	\N	(West Germany)	4ec24bee0f86d220d7e21f0a7d4e5f0c
30502	1652379	The Stronger	II	1	2009	S3652	\N	\N	\N	(Brazil) (literal English title)	a3552931e84e0822f2706e19aba06561
21507	1355296	I Kennedy	\N	2	1990	K53	\N	\N	\N	(Italy)	a2bdd090caa6c06ccb103c0984184ca0
30804	1653721	Die Muppets feiern Weihnacht	\N	3	1987	M1321	\N	\N	\N	(West Germany)	f903a22455e6c32f0e81b1416cd8d9d0
42140	1689824	My Mother's Tears	\N	1	1957	M5362	\N	\N	\N	(International: English title)	a52900d16215051239eb484f3f7de2e0
32501	1661135	Die Zauberlehrlinge	\N	1	1948	Z1646	\N	\N	\N	(Austria)	26dcc8057c21472d895b1fc1d2a7bf1f
141	8145	Der Mensch	\N	7	\N	M52	144	1	1	(Germany)	b0b05e2024bba48864bff9d56028450f
33940	1665669	Addams Family - Und die lieben Verwandten	\N	4	1998	A3521	\N	\N	\N	(Germany)	2b5b9939f3947ee127142dd747133daf
44493	1696967	Heritage	\N	1	1979	H632	\N	\N	\N	(International: English title)	99704959490c713ba41ecf678b53dd52
4901	327104	De unge mødre II	\N	2	2005	U5253	\N	\N	\N	(Denmark) (second season title)	037279678614a7b40c362ccb3beb22c5
11341	727770	Rescue Task Force Go Go V	\N	2	1999	R2321	\N	\N	\N	\N	f24dc827e6f8f0914e62510b546f8f31
20999	1317971	Head of the Family	\N	2	1961	H3131	\N	\N	\N	(USA) (working title)	66683ebf742dadc06e7006d5d477fe1d
38830	1678805	Alvorada: Brazil's Changing Face	\N	1	1962	A4163	\N	\N	\N	\N	012cf034b43181574cda13f3e7031342
37666	1674670	Alien Sex Files 3: Alien Ecstasy	\N	1	2009	A4521	\N	\N	\N	(USA) (TV title)	74ba444a381af59cff513ac5f5795bdf
7258	499415	Fristet - hvor langt vil du gå	\N	2	2011	F6231	\N	\N	\N	(Denmark) (promotional title)	e45d69ebce684fa1e15e49a912511646
9292	634418	Das fünfte Gebot	\N	2	2007	F5132	\N	\N	\N	(Germany) (working title)	df5bd7e22771eaf51b4737b895bf1472
14789	918059	Why I Make Movies	\N	2	2007	W5251	\N	\N	\N	(International: English title) (short title)	ef49de365102d01ada551c55c6050592
29056	1645884	Seymore Butts 45	\N	4	1998	S5613	\N	\N	\N	(International: English title) (series title)	549f439f6dc558956507142159250872
18531	1152061	Shortland St.	\N	2	1992	S6345	\N	\N	\N	(Australia)	8198ece2a4b7b973cc2e6936dc0c805d
4600	300131	Dogtanian and the Three Muskehounds	\N	2	1985	D2353	\N	\N	\N	(UK)	e96e88bb0c83576288d83857c25925ae
15858	995855	Party Police: Lake Havasu	\N	2	2007	P6314	\N	\N	\N	(USA) (working title)	410faaf4441f96af6146ce0af2a17871
47076	1705051	Up Aloft on H.M.S. Seaflower	\N	1	1898	U1413	\N	\N	\N	(UK) (alternative spelling)	5e67d14a8f7032abff33ae51a23d06f2
19475	1217544	Serial Theater	\N	2	1959	S6436	\N	\N	\N	(USA) (new title)	426860954f33c2ffa89a5396a66444e1
3530	223371	Charlie and Lola	\N	2	2005	C6453	\N	\N	\N	\N	2facc4ae9096e41ab2d2aefd5895d19a
32892	1662399	Possess My Soul	\N	1	1974	P2524	\N	\N	\N	\N	9b711cc14de527b8867ed358df2c1864
43379	1693498	Il bell'Adone	\N	1	1975	B435	\N	\N	\N	(Italy) (reissue title)	0eee3a3ca11c35a7d14ba7ca554bd4be
44402	1696722	I artista	\N	1	1966	A6323	\N	\N	\N	(Greece) (poster title)	ff4b173f37e1dc69507f8e8c4cb2862b
3962	252722	Der vierzehnte Stein	\N	7	\N	V6253	3963	\N	\N	(Germany)	65d80b331ccaa1029b9acc411c2a182a
17440	1094330	Hope	\N	7	\N	H1	17455	1	6	(USA)	e2c530ca206f7ae7ff3879acb08d9257
4972	333081	äÅÆÆÞÏÎËÉ	\N	2	2012	\N	\N	\N	\N	(Russia) (original Cyrillic KOI8-R title)	c8d77ed668da86afb1569405bae73efa
35265	1669298	Dooly - Der kleine Dino	\N	1	1999	D4362	\N	\N	\N	(Germany)	5331b59d812aa675c92d2837d6bcaaf0
2776	168344	Les aventures de Bob Morane	\N	2	1965	A1536	\N	\N	\N	(France) (alternative title)	94dff852abcc81b37abbb9b91cf50451
28283	1643004	Mahjong 7 Dimensions	\N	6	1990	M2523	\N	\N	\N	(Japan: English title) (imdb display title)	0a48446089d000df76a2ec1d5f0b37f3
46815	1704289	James Cameron's Avatar	\N	1	2009	J5256	\N	\N	\N	(USA) (promotional title)	ec0b3cc8eca122e29b0f66934841ab72
13915	877453	Mo dai wang chao	\N	2	1988	M352	\N	\N	\N	(China: Mandarin title) (informal title)	7e6d3ec05df73814730e5cfadf2186f0
14735	914144	When You Curse Someone, You Dig Your Own Grave	\N	7	\N	W5262	14742	4	16	(USA)	ccbf23de1db295010ba76e9ffd57fefa
6761	473978	The New Fat Albert Show	\N	2	1979	N1341	\N	\N	\N	(USA) (eighth season title)	0d451285c799d3d2786e292599626450
27123	1639430	Vierundzwanzig Stunden	\N	1	1931	V6532	\N	\N	\N	(Austria)	f3757be6906ad3f68daf8f46f18ff866
2029	138920	The Eye of the Storm	\N	7	\N	E1323	2030	4	1	(International: English title)	8b3553193c684babcd06dcc011218b80
28051	1642364	58:	\N	1	2011	\N	\N	\N	\N	(USA) (alternative title)	c5951604d35c5825616738fffa9ebefb
46413	1703073	Woman	\N	1	1940	W5	\N	\N	\N	\N	dc1a49e9d3946ccffa7935b36bd18167
40046	1682587	Eroina di strada	\N	1	1983	E6532	\N	\N	\N	(Italy) (working title)	aac068225cd57aabe40347643e29d9e5
3592	227602	Dramatic Mystery	\N	2	1952	D6532	\N	\N	\N	(USA) (alternative title)	0ae0b354b632baedf6682a2638ccb4b5
25351	1632078	Over 30	\N	2	2009	O16	\N	\N	\N	(Japan: English title)	b3ef2cca8a438fd1e81e0b804c99b62a
22411	1427059	L'uomo ombra	\N	2	1957	U516	\N	\N	\N	(Italy) (imdb display title)	47879907c39ff8c41d8eb48acdb5b50e
10472	703572	The Sword, the Wind, and the Lullaby	\N	2	1976	S6353	\N	\N	\N	(literal English title)	1c119115ba1ce07db549902af695e0aa
30320	1651501	The Legend of Ubirajara	\N	1	1975	L2531	\N	\N	\N	(International: English title)	5b4e07acfb8d7c87a048dd3d195115ed
23829	1528919	Suspicious Rash	\N	7	\N	S2126	23830	6	6	\N	bc31e4cb72cbf4cc7b8957f53eda0da2
49634	1711984	The Closed Door	\N	1	1990	C4236	\N	\N	\N	(India: English title)	7b146dfcc2c1f5beac2ac813cf557430
13126	834142	Malican padre e figlio	\N	2	1967	M4251	\N	\N	\N	(Italy) (imdb display title)	204037da05af58c63e006da9c3784e27
34043	1666021	Granny's Funeral	\N	1	2012	G6521	\N	\N	\N	(International: English title) (imdb display title)	c3489d49fccf2df327da7d742d2750c1
17996	1131394	Scream Queens 2	\N	2	2009	S2652	\N	\N	\N	(USA) (second season title)	cbdb8b0b28b00efb3d6f43da07f165a8
32311	1660423	Das Flüstern des Todes	\N	3	1988	F4236	\N	\N	\N	(West Germany)	c744856b793f6ff14d650af817d61948
14718	913990	Reunion: The Remaining Time	\N	7	\N	R5365	14723	1	182	(USA)	654f6bc8cc3fefb74cd02477b9e22bd6
48910	1710145	Bait - Fette Beute	\N	1	2001	B3131	\N	\N	\N	(Germany)	208bf2c35cc782ab3a91fe565de8c035
4409	285137	Florence Henderson's Country Kitchen	\N	2	1985	F4652	\N	\N	\N	(USA) (complete title)	491a70bb8e5d9f1b0b90ef1ce7cfdee2
4720	305844	Moves	\N	2	2006	M12	\N	\N	\N	(USA) (working title)	82f00c16bd82ab3b4aa512049fdfbbd5
36850	1672457	The Beginning	\N	1	1986	B252	\N	\N	\N	\N	47c5467762a4edcd764049a2df8b3dc6
11843	773012	Der Fremde	\N	2	1973	F653	\N	\N	\N	(West Germany)	6ff6fffec7d26208c7e83a94c9fe23d0
12031	778461	The Great Court Cases	\N	2	1993	G6326	\N	\N	\N	\N	a8b262b3e286b283ae0de510bab52017
31996	1658907	Erich Maria Remarque's A Time to Love and a Time to Die	\N	1	1958	E6256	\N	\N	\N	(International: English title) (complete title)	678b4c1790ae41b01b026519df6326df
45761	1701511	Behind the Shadows	\N	1	2002	B5323	\N	\N	\N	(USA) (subtitle)	a5dd946153f2caa3e376a4230642471e
28087	1642524	Sexta convocatoria	\N	1	2004	S2325	\N	\N	\N	(Spain) (alternative title)	44e4be8fc84e3bcd5694a6bceb6e490a
41741	1688672	Selen anima ribelle	\N	4	1998	S4561	\N	\N	\N	(Italy) (DVD box title)	ca29226a3972e938d707de8734587733
29938	1650086	Death Rode Out of Persia	\N	1	2005	D3631	\N	\N	\N	(International: English title)	ed01e0863de9aad9b84b364192f3764d
27658	1641128	4 Artists Paint 1 Tree	\N	1	1964	A6323	\N	\N	\N	(USA) (short title)	41fcf8cd463790462a6e6fed7643e145
614	44317	The Mayflower Madam: Sydney Barrows	\N	7	\N	M1465	613	2	5	\N	caae5bea840aa60d6dd199a1931724ce
33313	1663791	Krise	\N	1	1928	K62	\N	\N	\N	(Germany) (working title)	a489841f1a71821ef448ed35d4382a12
5900	388299	Vier Frauen im Haus	\N	2	1969	V6165	\N	\N	\N	(West Germany) (second season title)	7558dd36a7f9cd1012ce5b7c8b847f05
11042	719479	ëÏÒÏÌÅ×Á íÁÒÇÏ	\N	2	1996	\N	\N	\N	\N	(Russia) (original Cyrillic KOI8-R title)	abc5cf7733b53290c868e69fcd272377
30376	1651781	Kein Mittel gegen Liebe	\N	1	2011	K5342	\N	\N	\N	(Germany) (imdb display title)	35b2e16e84c70a2f73d4410bfa18b505
47260	1705637	Der Waldhauptmann	\N	1	1988	W4313	\N	\N	\N	(West Germany)	41615e11a338e9ba3b026d74c9eaea6a
29645	1648635	Pappas flicka	\N	1	2004	P1214	\N	\N	\N	(Sweden)	08919f9bdf9def90904c90ec1006f907
21759	1373903	Lobo	\N	2	1979	L1	\N	\N	\N	(Italy)	9d8a60025206acc023f101b89dce15d9
20830	1303642	It's Christopher Lowell	\N	2	2003	I3262	\N	\N	\N	(USA) (new title)	693f3eef2345e1ace7363e523d82403f
43359	1693420	Between Us	\N	1	2011	B352	\N	\N	\N	(International: English title) (review title)	eedf017840b5e5bd399a9dabdd94f547
9783	667200	Jamie Does...	\N	2	2010	J532	\N	\N	\N	(Australia) (DVD title)	9079ca986dbc68c6fa6aa72ab0e6ed9e
10500	704810	Auf der Spree nach Berlin	\N	2	2010	A1362	\N	\N	\N	(Germany) (first season title)	a81f93e2457294164d9762d800b9abd0
23031	1488201	France's Next Top Model	\N	2	2005	F6525	\N	\N	\N	(France) (informal title)	a8753e9b36b4e688e5ac1ecac1753daf
17903	1126794	The Fixer	\N	2	2012	F26	\N	\N	\N	(South Africa: English title) (alternative title)	c6e8930b9f70bd714ab3fc54da3091e5
48337	1708664	The Story of Danny Lester	\N	1	1949	S3613	\N	\N	\N	\N	73d7e472f74602f5d166397585406003
8147	557395	The Weak Link	\N	2	2002	W2452	\N	\N	\N	\N	cb8841e4d568837ede87842ed95823d2
3411	213501	Samurai Pizza Cats - Samurai per una pizza	\N	2	1991	S5612	\N	\N	\N	(Italy)	0f3e8c3ea4318eb3a25711a3fcd44d73
5812	381957	DR-Derude: Den sidste slæderejse	\N	2	1993	D6363	\N	\N	\N	(Denmark) (series title)	49dcf4debb45b5ae06a931c7a274ad04
49258	1710956	Pulau Dewata	\N	1	1979	P43	\N	\N	\N	(Australia) (short title)	5ec23b19d552bca4ade8439c54ac8ff5
20783	1297300	The Burn	\N	2	2012	B65	\N	\N	\N	(short title)	2f492c43b9b1daad13314a2675f384a4
26608	1636476	Eighteen 'n Interracial 6	\N	4	2002	E2353	\N	\N	\N	(International: English title) (DVD title)	c1586a1b98cd34cdb9019757cbe1fa37
8013	553020	Thank God You Came	\N	2	2006	T5232	\N	\N	\N	(Denmark) (literal English title)	9a593b4f8715b795702db6e92dec2664
12167	779680	The Podcats	\N	2	2009	P3232	\N	\N	\N	(International: English title) (series title)	a01e4622a9a44fd9b8d96c337f76dc06
48367	1708748	Bad Company - Protocollo Praga	\N	1	2002	B3251	\N	\N	\N	(Italy) (imdb display title)	630fb68531e5ea78ae0dce11113e3971
2740	165895	A Fateful Decision	\N	7	\N	F3143	2747	1	2	(USA)	c11104110643c092622d518a3829a02f
34762	1668121	Jimmys Tod - Und was kam danach?	\N	3	1996	J5235	\N	\N	\N	(Germany)	a702b430477fcfae0cd2443742893bc6
45380	1700344	Banus, the Horse Thief	\N	1	1967	B5236	\N	\N	\N	(International: English title)	0fb1b47a6c34ece529d0ddf9c948229d
49570	1711832	Banana meccanica	\N	1	1973	B5252	\N	\N	\N	(Italy) (imdb display title)	f5a7f1f75009f0f78520e5122d9d36cc
6993	482244	Der Fisch-Club	\N	2	2010	F241	\N	\N	\N	(Germany) (imdb display title)	696715da32b82bdd5cc19210da1276ad
45607	1701129	Atlantic	\N	1	1929	A3453	\N	\N	\N	(Germany)	e87cdd10f652efdd338ac69a3cf9ca83
12540	810582	Make a Living	\N	7	\N	M2415	12561	\N	\N	(UK)	3f9f378567cbb1ed2b6ed2bcf94cf3bc
29155	1646286	Der Gelegenheitsdieb	\N	1	2012	G4253	\N	\N	\N	(Switzerland: German title) (poster title)	7faf9938a76b159ef836b6aff8f0fa9b
32538	1661246	Birdseye	\N	1	2002	B632	\N	\N	\N	(USA)	b7a22daeacac31efcba4a626f60a9f8f
35918	1670578	Femmes	\N	1	1995	F52	\N	\N	\N	\N	924c066410ea3fa3f6be1d771b562dbf
41339	1687667	Angano, Angano - Geschichten aus Madagaskar	\N	1	1996	A5252	\N	\N	\N	(Germany) (alternative title)	288774fec1d862f205ba226f8cd1ac0b
22323	1419053	Rotorua, New Zealand C	\N	7	\N	R3652	22322	1	4	\N	a979ff5c3ae68f9a23e6befd87dccac0
45562	1700977	Athanasios Christopoulos, a Forgotten Poet	\N	1	2001	A3526	\N	\N	\N	(International: English title)	9acbe8a6c03ce79064d4d38f15c621ff
28990	1645591	Promises & Lies	\N	3	1998	P6524	\N	\N	\N	(UK) (DVD title)	7e0dd7e882a416fb83a7ebe88ef66c6b
41222	1687334	Anflug Alpha 1	\N	1	1971	A5142	\N	\N	\N	(East Germany) (poster title)	339c01a537d8715ea567b0a68a88b516
12371	792523	Chiudi gli occhi e sogna	\N	2	1990	C3242	\N	\N	\N	(Italy)	dcc101d5640ab55bef7e2c4f41e91dee
28859	1645050	Das große Krabbeln	\N	1	1999	G6261	\N	\N	\N	(Germany)	77f9a455ff14165b9a863dc052fbe83d
25153	1617901	Zap Jr. High	\N	2	2007	Z1262	\N	\N	\N	(International: English title)	c9c9ecc1d28d2dc3a62ad36ee4718195
1601	112107	The League Against Tedium	\N	2	2001	L2523	\N	\N	\N	(UK) (alternative title)	b78eab2a4b5ebad1ddf70c00f8c275fb
15262	957058	Última hora	\N	2	2009	L356	\N	\N	\N	(Spain) (working title)	ad3715ab96326b72885e3642c8a3bd97
42285	1690272	A Cinderella Story Two	\N	4	2007	C5364	\N	\N	\N	(USA) (working title)	9b618a5e14fe1c7b0470c7a87d2d947f
48517	1709256	Liebesgrüße aus dem Badehöschen	\N	1	1973	L1262	\N	\N	\N	(West Germany) (video title)	6343df5ce45d693cd0990d2a19488afd
360	26317	Archi - Der Krimi Planet	\N	2	1987	A6236	\N	\N	\N	(West Germany) (video title)	ba0fd69909245d87f6127eb0fd2e8e08
311	20918	Wandin Valley	\N	2	1981	W5351	\N	\N	\N	(Italy) (imdb display title)	e90679d577371068f64b519240cbe8ee
34266	1666661	Adultery Brazilian Style	\N	1	1969	A3436	\N	\N	\N	(International: English title)	399642cb13626d6bf407cdacc38743a0
5108	338256	Cadenatres deportes con Pablo Carrillo	\N	2	2007	C3536	\N	\N	\N	(Mexico) (alternative title)	15dfb2ed1757c2bb709891693e1b24ca
23077	1491997	Spy Kids	\N	7	\N	S1232	23076	2	4	\N	584b5e388b5230ff5cb31965cc066302
20805	1299139	CBS Sports Sunday	\N	2	1981	C1216	\N	\N	\N	(USA) (new title)	4635227e017ae5c84ab06ee495322e6a
6412	442435	Era of the Archer	\N	2	2007	E6136	\N	\N	\N	(International: English title) (literal title)	deac672b429b68668bd4d20e46ac63a4
16065	1012432	Petsburgh	\N	2	1998	P3216	\N	\N	\N	(USA) (alternative title)	20c68efa2cfe9576343617d716823a5f
18921	1182550	Barry Crocker's Sound of Music	\N	2	1970	B6262	\N	\N	\N	\N	13ade3888e213d74cbc1032ef368910b
12887	828684	Magnum	\N	2	1981	M25	\N	\N	\N	(West Germany)	eaf4616c129617e7bdf6da1a2a46a5ba
2322	151798	Big Brother 8	II	2	2007	B2163	\N	\N	\N	(USA) (eighth season title)	e44fd0220a14c7244e33b258b1648ffc
43598	1694138	Frost Giant	\N	3	2012	F6232	\N	\N	\N	(USA) (new title)	f036fdd5e8514175d55cf7c21c6b1fba
29183	1646438	His Hated Rival	\N	1	1914	H2361	\N	\N	\N	(USA) (alternative title)	38ce7f7fa66bfd2c829d016c481d241b
27569	1640834	Thirty Six Hours	\N	1	1965	T6326	\N	\N	\N	(USA) (alternative spelling)	d224b6d01fc7525aaf3f11fd9fb3fef0
41468	1687978	Angela and Angela	\N	1	1988	A5245	\N	\N	\N	\N	b5e7c3f76078c0a53d6522fe5ee182ea
32034	1659033	World Wide Adventures: A Touch of Gold	\N	1	1962	W6431	\N	\N	\N	(USA) (series title)	90626362cf28e3a9886a9827678213d9
43937	1695198	Armin	\N	1	2007	A65	\N	\N	\N	(Croatia)	fa2c2ce0190820699b819ed593bb1d98
36063	1670919	Story of a Beloved Wife	\N	1	1951	S3614	\N	\N	\N	(International: English title)	131f650c6216ba92c40e7f8f90aec077
1382	93454	Appleseed XIII	\N	2	2011	A1423	\N	\N	\N	(International: English title) (imdb display title)	7d3172b67e3dbcc7653bbeb540ab23a7
36491	1671800	The Cistern	\N	1	2001	C2365	\N	\N	\N	(International: English title)	0f417a356179ef1d0a64deaf808faa3f
32048	1659078	The New Leather Pushers (Fourth Series) #4: A Tough Tenderfoot	\N	1	1923	N4361	\N	\N	\N	(USA) (series title)	69cde8e66d37ffa46ef2aa1cdc5a1a15
1326	90858	Anthony, formidabile formica	\N	2	1999	A5351	\N	\N	\N	(Italy)	069e3bc2444b81ffed20e8e62f8ccce3
21799	1377064	The Muppet Show	\N	2	1976	M132	\N	\N	\N	\N	2e5170fb00529771296d6fae5bd30cfb
46737	1704158	Her Nights	\N	1	1978	H6523	\N	\N	\N	(India: English title)	2936ac78982520335576fc85b1a0e5be
19595	1227203	Stepfather Steps	\N	2	2012	S3136	\N	\N	\N	(International: English title) (imdb display title)	5b33f4e11b6bb4e66db4d95f17a65b0f
4862	323872	De club van Sinterklaas & de brieven van Jacob	\N	2	2004	C4152	\N	\N	\N	(Netherlands) (fifth season title)	be2ee3042eab67b1a27191b9f67c0c67
9072	622263	Happy Marshal	\N	2	2012	H1562	\N	\N	\N	(International: English title) (imdb display title)	b424301592245281ce3ab99b7c36cf59
13333	846642	Match Game 77	\N	2	1977	M325	\N	\N	\N	(USA) (fifth season title)	e0f00b936cb94347c590c387cf20ed16
39263	1680106	Superfuckers	\N	1	1985	S1612	\N	\N	\N	(West Germany) (dubbed version)	b1f8fb7053067b9f1b10baff086bc051
32268	1660145	I passi dell'amore	\N	1	2002	P2345	\N	\N	\N	(Italy)	ffbd56af1cb571d7112c71d66f2a703d
48688	1709750	The Clown's Revenge	\N	1	1912	C4526	\N	\N	\N	(UK) (literal English title)	098281fe1b981bade88a5ce5fd04922b
24218	1559366	Die Erben der Saurier - Im Reich der Urzeit	\N	2	2001	E6153	\N	\N	\N	(Germany)	e9a29f415cdbfdce2b0a89a2e641dc9e
49910	1712708	Ticket ins Chaos	\N	1	1985	T2352	\N	\N	\N	(West Germany)	793aa0905d3a810eaedcd61f12f9510a
11048	720162	Beautiful Women	\N	2	2010	B3145	\N	\N	\N	(Greece) (alternative title)	3f2ff92fd5908de17d2787c37ff62892
29918	1650012	Gunfight	\N	1	1971	G5123	\N	\N	\N	(USA) (alternative title)	dabf460b087121fd36fe623281dc4bcf
29009	1645686	Dog Hermit	\N	3	1995	D2653	\N	\N	\N	(Canada: English title)	0c04243270fdb3f32bbd568b1065a923
26877	1638258	20 Cigarettes	\N	1	2010	C2632	\N	\N	\N	(International: English title) (imdb display title)	9de7c9d310fadd2736358b8a44f54d11
25881	1634145	Ellipsis Reel Five	\N	1	1999	E4126	\N	\N	\N	(USA) (alternative spelling)	ac2a7612a873cbec02fcdd97889eb502
8119	556456	The Dangerous Partner	\N	7	\N	D5262	8118	1	23	(USA)	7cc879b7940b2221a70c22714918c009
8487	572645	The Israelis	\N	2	2007	I2642	\N	\N	\N	(International: English title) (literal English title)	055bcec9760dc1303b35df0d4c04430d
33564	1664480	The Bitter Love	\N	1	1958	B3641	\N	\N	\N	(International: English title)	17271b03c1297eff98538d046092ee51
4925	329842	Crimes of Passion	\N	2	2013	C6521	\N	\N	\N	(USA) (working title)	a26a30bbc8abe5559db12fae0ee843be
48512	1709248	Red Wind	\N	1	2002	R353	\N	\N	\N	(International: English title)	81f39fa89d8a35043504a37e154584a2
35966	1670650	I diavoli dei mari del sud	\N	1	1938	D1435	\N	\N	\N	(Italy)	e6bee1123c1c2f707230c921c981349e
29592	1648452	A Favourite Domestic Scene	\N	1	1898	F1635	\N	\N	\N	(UK) (imdb display title)	09213951ad6c8ab4e6d4502cadecc086
40415	1683926	Peel	\N	1	1982	P4	\N	\N	\N	\N	089da1151f30aabdc8d6f26747f1683c
20733	1289374	Bobbie Gentry's Happiness	\N	2	1974	B1253	\N	\N	\N	\N	c41243079b7a94d50441724337f4980b
39151	1679637	Bitteres Meer	\N	1	1987	B3625	\N	\N	\N	(East Germany)	012cbd270227b0e9db91655dd3de348f
43869	1694979	The Answer Man	\N	1	2009	A5265	\N	\N	\N	(USA) (new title)	7f0235019bd5ec6f9f0665b98bc23b77
41693	1688565	Alms for a Blind Horse	\N	1	2011	A4521	\N	\N	\N	(International: English title) (imdb display title)	23994089b50defb704394423e57763b3
27766	1641349	40 mq di Germania	\N	1	1986	M2326	\N	\N	\N	(Italy)	1eebcb148f8e737cc485f96fcf2fc793
233	14894	51 Grad Nord - Deutschland querdurch	\N	2	1991	G6356	\N	\N	\N	(Germany) (alternative title)	f98db1d78b6ec5c27756145b4b3149e2
45251	1700048	Asterix and Cleopatra	\N	1	1968	A2362	\N	\N	\N	(UK)	418c51d368ddc49beed8164310be1009
934	60906	Alloo Goes Serious	\N	2	2001	A4262	\N	\N	\N	(Belgium: English title) (working title)	5470add77787e2056a2790290355599f
34558	1667491	Afghanistan Year 1380	\N	3	2002	A1252	\N	\N	\N	(International: English title)	f84464ed32f8a11ecfdb2f6acdd1fd09
161	8805	24 - Twenty Four	\N	2	2001	T5316	\N	\N	\N	(Germany)	64805f39499f91ad119cf9d9c57a395c
34222	1666519	Châtelet-Les-Halles	\N	3	2007	C3434	\N	\N	\N	(France) (working title)	530c57268150b15b3d983457c53f3b8b
49010	1710459	V Baku duyut vetry	\N	1	1974	V1231	\N	\N	\N	(Soviet Union: Russian title) (imdb display title)	f47a89b803754a4d9e6c08cf2eac42ce
31894	1658638	Ryan and Lee in a Tenement Tangle	\N	1	1930	R5345	\N	\N	\N	(USA) (copyright title)	6bbb62ca9496c730466920f87e1cac99
36219	1671294	Red Flesh	\N	1	1967	R3142	\N	\N	\N	(International: English title) (literal title)	a390c8ab0d1573117eac72b5948621a4
42102	1689772	Anne... la maison aux pignons verts	\N	3	1985	A5452	\N	\N	\N	(Canada: French title) (imdb display title)	bfa0a11c82498de072fe931afbfb453a
41087	1686816	Those Days	\N	1	1954	T232	\N	\N	\N	\N	914ba85d62510af42e9b950b22f8570c
20380	1268012	Die 13 Geister von Scooby-Doo	\N	2	1985	G2361	\N	\N	\N	(West Germany) (dubbed version)	fb65083e85b6256bb2a4e12c7cc61ff9
36401	1671587	The Maisug Child	\N	1	2011	M243	\N	\N	\N	(Philippines: English title) (imdb display title)	85d49a9da5e085729f669ab88d34ab10
6186	407143	Einer gegen 100	\N	2	2008	E5625	\N	\N	\N	(Germany) (alternative spelling)	d5e8864f72090ee4ddf8361900c78e58
6748	473172	Mentors' Choice	\N	7	\N	M5362	6747	1	7	\N	924de142c092124e9128f08ad1e09d45
21150	1329524	The Gladstones	\N	2	1959	G4323	\N	\N	\N	(USA) (working title)	88bd5b70ebc972a481428098953490a6
30663	1653004	A mia madre piacciono le donne	\N	1	2004	M5361	\N	\N	\N	(Italy)	1c7c45a5755d069083933e2e2b67a2f7
35596	1670060	Bloody Life	\N	1	1977	B4341	\N	\N	\N	(International: English title)	6dc69c3fc83cbb5a7bb0bf8bb004672e
34435	1667156	Love Class	\N	1	1973	L1242	\N	\N	\N	(literal English title)	63ccd36102e9fd36ab9ed15b4b8adc5a
36945	1672570	The Moss	\N	1	1990	M2	\N	\N	\N	(International: English title) (informal literal title)	2ae1097dc915cc5ece0cf92021b170c6
29753	1649202	Dolci vizi al foro	\N	1	1966	D4212	\N	\N	\N	(Italy)	2d18ad8cd2bfa416c1639609f5ca8d32
10965	718550	Rex: A Cop's Best Friend	\N	2	1994	R2121	\N	\N	\N	(UK)	858e90c1e736d2c27b05b04824a988da
35109	1669134	Im Auftrag von H.A.R.M.	\N	1	1966	I5136	\N	\N	\N	(West Germany)	f8006262de9ebaec6e3642e7f2c960c1
22698	1458164	Thibaud	\N	2	1968	T13	\N	\N	\N	\N	89511e004675923739992cf6e5ed0ab2
69	4288	12 Ouns Mouce	\N	2	2005	O5252	\N	\N	\N	(USA) (alternative spelling)	123fc1dba423b78abbd5e20244017fc0
21031	1321562	Fergie: Duchess on a Mission	\N	2	2009	F6232	\N	\N	\N	(Australia)	51cc18b7db741dcc9f1ad4b67b72424b
27269	1639978	2÷3	\N	1	2000	\N	\N	\N	\N	(Germany) (Berlin film festival title)	ed14b5859a4df07e3868effc28e0ade1
48451	1709018	Die Rächer von Missouri	\N	1	1959	R2615	\N	\N	\N	(West Germany)	c72cd2cf75cf94cc59419de1d17faf89
40854	1686075	Hae Boo hawk shi gan	\N	1	2001	H125	\N	\N	\N	(South Korea)	3fcfee97e1e9b406663b42608ec233cc
2283	150819	Welcome to Reality	\N	2	2004	W4253	\N	\N	\N	(USA)	c0aef125ecbfd3f2d13a4f469760c42b
3017	185316	Glass Jumps	\N	7	\N	G4251	3016	1	8	(USA) (working title)	a860bc22d99c547a515478074d79ca03
41874	1689210	Angélique in the Ottoman Palaces	\N	1	1967	A5242	\N	\N	\N	(International: English title)	445910c1ec6cdf84df630e6cbc6e957b
20941	1314221	The Mug Root Beer Dana Carvey Show	\N	2	1996	M2631	\N	\N	\N	(USA) (alternative title)	53509d64f15f3a46c506b17dc2cc257b
10297	697690	Kamen Rider Blade	\N	2	2004	K5636	\N	\N	\N	(Japan: English title)	9a30971bea1f8e068115eed00a64ef6e
43972	1695343	Army of Darkness: The Medieval Dead	\N	1	1993	A6513	\N	\N	\N	(UK) (video title)	a9b652c9ee722e418ca124f107ff33a9
31892	1658605	The Lost Child	\N	1	1912	L2324	\N	\N	\N	(USA) (working title)	0c8105592e0a6b11dc703ef69eeaa6cc
15979	1008485	Histoire de famille	\N	7	\N	H2363	15984	\N	\N	(France)	d9a2635d2653f1094577ff01306f0aa2
41323	1687625	The Real Life of Pacita M.	\N	1	1991	R4123	\N	\N	\N	(International: English title)	7a7f16cf02c10cd775798a5a16fd5c2d
7311	503061	Funkhaus	\N	2	2007	F52	\N	\N	\N	(Germany) (alternative spelling)	c35b327dc6814cd481f80257569aeb90
26655	1636694	$186 to Freedom	\N	1	2012	T1635	\N	\N	\N	(USA) (alternative spelling)	e7873d09951cb4157ad383a60591d42c
15529	974829	Play	\N	7	\N	P4	15548	1	4	(USA)	ee529b04efbe34b456c3ce84ed4039e7
41265	1687458	The Fate of Virgin Mario	\N	1	2008	F3162	\N	\N	\N	(International: English title)	5b8d2711ad44cbdd922768d83eebfb7a
34740	1668036	Central Park After Dark	\N	1	1903	C5364	\N	\N	\N	(USA) (copyright title)	2843631651a5ae942edcc78d6936c48a
10365	699306	Circumstances of a Boyfriend and Girlfriend	\N	2	1998	C6252	\N	\N	\N	(USA)	3edf8c1712ede40786000da7014b45c4
7489	510196	Gunparade March: A New Song for the March	\N	2	2003	G5163	\N	\N	\N	(Japan) (literal English title)	238df56ef9063a4b20cd489942703148
13790	871639	The Ugly Duckling	\N	2	1996	U2432	\N	\N	\N	(Japan: English title) (literal title)	ceb32b5df51939fe463863966b937faa
12919	829242	The Owner of the Perfect Heart	\N	7	\N	O5613	12924	1	8	(USA)	d34ea6321f97d1780f3694d1d2c28e30
49500	1711635	It's Showtime	\N	1	2001	I3235	\N	\N	\N	(Germany)	34851e9794efd418eb0c2fff2b7799bb
40602	1684778	I and My Love	\N	1	1953	A5354	\N	\N	\N	(International: English title)	2df13ff246fe9df16f45f3d20e78f2d5
16349	1033120	Popstars: Live	I	2	2004	P1236	\N	\N	\N	(Australia) (fourth season title)	fdbd9388f70bb5a89eb4eb36b1262f38
13519	856192	Het einde van het begin - deel 1	\N	7	\N	E5315	13518	3	12	\N	f87b298cb07de3ca54024f390a3e5d52
10187	696694	Tamagon the Counselor	\N	2	1972	T5253	\N	\N	\N	(International: English title)	23e7c14da414b9c0c3537f42aded1a87
22566	1444665	Comment ça marche	\N	2	2004	C5356	\N	\N	\N	(France)	47caab597bc04d89f0b60a9c96d4f9e1
46552	1703490	Australie, mon Amour	\N	1	2012	A2364	\N	\N	\N	(Australia: French title) (working title)	c5cc9a8b4cfe17785fc73b0b53a7686e
28770	1644649	Assassinio premeditato	\N	1	1953	A2516	\N	\N	\N	(Italy)	eea7842867c33274b99bb28ed2589caf
18372	1149104	The Sherri Shepherd Project	\N	2	2009	S6216	\N	\N	\N	(USA) (working title)	357a91fca80dd61e66ffb15313666616
14283	890825	Le Nozze Di Figaro	\N	7	\N	N2312	14284	1	1	\N	f249d65eb23829b933669cd020e39417
22586	1446853	The What a Cartoon Show	\N	2	1995	W3263	\N	\N	\N	\N	9b3471399bcbf6476b6dbeea26078acc
27567	1640834	36 Stunden	\N	1	1965	S3535	\N	\N	\N	(West Germany)	826825c1f3fc50ea712fb90527aa849e
6963	480717	The Finder	I	2	1991	F536	\N	\N	\N	(Australia) (video title)	96ac346c3be92b5c6ad70c2d1c2db442
5883	386903	Dragons: Defenders of Berk	\N	2	2013	D6252	\N	\N	\N	(International: English title) (second season title)	1681c922f4a86b93ec5d17b2e4655363
13775	870943	Past Imperfect	\N	2	1991	P2351	\N	\N	\N	(International: English title)	243bf974beba7e62e597a47ca890b083
24527	1586154	Nuild It Beaver	\N	7	\N	N4316	24526	1	8	\N	9b8243594e29841e6048d8a1ff4bd691
37512	1674274	Circle of Fear	\N	1	1992	C6241	\N	\N	\N	(International: English title)	660e49252949dbff2232e813ed27acb7
43038	1692302	Vampira 3: Apocalipsis vampira	\N	4	2004	V5161	\N	\N	\N	(Spain) (series title)	461f635320c05a085fba7437dcd55918
43670	1694418	La prigione di sabbia	\N	1	1952	P6253	\N	\N	\N	(Italy) (Venice film festival title)	b2ca5dcdc9be1359a959d1519059bf83
31233	1655599	Pure Life	\N	1	2012	P641	\N	\N	\N	(USA) (alternative title)	d0ec45c05b4c1e27476769031fe85995
18487	1150251	Psychic Detective Yakumo	\N	2	2010	P2323	\N	\N	\N	(International: English title) (imdb display title)	30d04e8793d3bd79a842aa44ef68f7cf
24862	1605522	Thirteen: Conspiracy	\N	2	2012	T6352	\N	\N	\N	(UK) (TV title)	8295dfe2d6767e4d84a361fe7cf0cbac
16532	1043613	Caged Women	\N	2	1979	C235	\N	\N	\N	(Canada: English title)	c949bdbf22d099aa88db5df2c2432d40
39044	1679378	Beautiful Amalfi	\N	1	1911	B3145	\N	\N	\N	(UK)	66e966026cad298f0d0f0e6737503512
5034	335295	Delvecchio	\N	2	1976	D412	\N	\N	\N	(Italy)	c406efeff7abea6fc9319bd976fde4f1
41526	1688159	Pandemonium	II	1	2009	P535	\N	\N	\N	(USA) (working title)	cbb7997fbd0c2107d153d711d2344aa6
49624	1711965	Bande à Part	\N	1	1964	B5316	\N	\N	\N	(UK) (imdb display title)	1f47825b9057165b13d8f5ed895547df
28509	1643600	9th Company	\N	1	2007	T2515	\N	\N	\N	(USA)	e72bdbca9ad9a6c81e72fa8fc5b6c762
19705	1234586	Der Kaiserkanal	\N	2	2003	K2625	\N	\N	\N	(Germany)	6337924ec5526ae59ff4502b72610cc6
48645	1709620	Surelock: A True Poo Story	II	1	2008	S6423	\N	\N	\N	(Canada: English title) (long title)	987f34e62558a5b37c9aa94696f90b2c
41528	1688171	Engel und Insekten	\N	1	1995	E5245	\N	\N	\N	(Germany)	5c3176d31164710513fe0ef9f21b1174
21028	1321029	The Dream	\N	2	2004	D65	\N	\N	\N	(Australia) (short title)	3e5f8079fcb95de39b01217ac6d5a487
43584	1694069	Journey Into a Lost World	\N	3	1960	J6534	\N	\N	\N	(UK) (working title)	8ef66c0933e40893bb99e5dd45102680
40805	1686006	Please Make Love with Me	\N	4	2002	P4252	\N	\N	\N	(Japan) (alternative title)	da89f352b6332866737db32302059d28
30810	1653733	Tod in den Wäldern	\N	3	2002	T3535	\N	\N	\N	(Germany)	51a9124316e26116014f3c806c12a5d3
23672	1521225	Aus dem Nest gefallen	\N	2	1979	A2352	\N	\N	\N	(West Germany)	fa7fc58c26a306ba58c55c9ab7a2da4c
21773	1374530	The Mole II: The Next Betrayal	I	2	2001	M4352	\N	\N	\N	(USA) (second season title)	ee1e442626ca84eb33d6f06bd25c9df1
19190	1200154	More Than Life at Stake	\N	2	1967	M6354	\N	\N	\N	\N	402c78bd11789db401f4be767219ce5d
42627	1691292	Antoine, le coq du village	\N	1	1942	A5354	\N	\N	\N	(Belgium: French title)	67a392093bd9b4ea2bd3af5d7c8c3322
35999	1670722	Il nemico ci ascolta	\N	1	1943	N5243	\N	\N	\N	(Italy)	c828b700d0f373ba2a10c172dc314722
24173	1556701	Venus und Apoll	\N	2	2005	V5253	\N	\N	\N	(Germany)	a8c106346aa51e450e62f706d1c8dcb2
15447	968308	Militari di carriera	\N	2	1976	M4363	\N	\N	\N	(Italy)	bba6cd46c3baeb404f3fbb204fce73d3
24031	1542783	Bonny Maid Versatile Varieties	\N	2	1949	B5316	\N	\N	\N	\N	a43ac53ac514858682b8d436592ed9a7
45899	1701786	MGM Oddity: Attention Suckers	\N	1	1934	M2535	\N	\N	\N	(USA) (series title)	e235cc506500041590ce7f42712316ed
31572	1657240	A Sister's Love	\N	1	1909	S2362	\N	\N	\N	(USA) (short title)	d983320e66038636e6580caef037bf6b
25417	1632926	Five Dollars a Day	\N	1	2009	F1346	\N	\N	\N	(USA) (alternative spelling)	368ba355226bec3c434efd1007ac8fed
19757	1236887	Tiger Mask II	\N	2	1981	T2652	\N	\N	\N	(USA)	36ae131b4818fc0bb730e3c6c19aba29
41610	1688353	Cambogia Express	\N	1	1982	C5121	\N	\N	\N	(Italy)	0d04d95613257da70760c4e1e1c8a329
4385	277747	L'amore vero non si compra	\N	2	1989	A5616	\N	\N	\N	(Italy)	943d903e3870160cd54d7246fd435ab6
5974	391205	Archrivals	\N	2	2009	A6261	\N	\N	\N	(International: English title) (imdb display title)	47bab32708be9472a58500661abdaef9
16123	1016274	Pink Panther & Sons - I figli della Pantera Rosa	\N	2	1984	P5215	\N	\N	\N	(Italy)	f3241ea61287bee3d5834f4ffaf3ca85
6864	477343	Adventsfest der Volksmusik	\N	2	1994	A3153	\N	\N	\N	(Germany) (alternative title)	ab7ac7fbad937facd5536e0913d78e90
16164	1020306	Platz für Helden! - Das Magazin	\N	2	2005	P4321	\N	\N	\N	(Germany) (alternative title)	324f2fd90abaadc2ba91248b40df0b16
36350	1671501	Mediterranean Song	\N	1	1964	M3652	\N	\N	\N	(International: English title)	ce508745a99619ad795a9e196370c481
10006	688540	Für alle Fälle Amy	\N	2	2003	F6414	\N	\N	\N	(Germany)	d4dc1b3f7cc5c170881ebd6e1674ce34
12969	829870	Tweeny Witches	\N	2	2003	T532	\N	\N	\N	(International: English title)	ba5506e444b79df9781bee007f469b83
8432	568551	Harry e gli Henderson	\N	2	1991	H6245	\N	\N	\N	(Italy)	24deed5785d31389b8b269764cc3b9ab
18565	1155326	On the Night of the Ball	\N	7	\N	O5352	18566	1	3	(USA)	7aadf8d6245b5401c7510f3dbc887686
324	23468	In due si ama meglio	\N	2	1989	I5325	\N	\N	\N	(Italy)	864f8033288f851943a580c19753fce3
41252	1687425	The Yawn	\N	1	1984	Y5	\N	\N	\N	(International: English title) (imdb display title)	0f0f721b79bf9c7ce6a140148dd91c04
6079	397677	East 8	\N	2	1985	E23	\N	\N	\N	(UK) (working title)	baac90d93d103b55010b100fd51abca3
45918	1701827	Attila	\N	1	1954	A34	\N	\N	\N	(USA)	c5169b4b2019ab5883924c5260478f2c
33420	1664156	Schach dem Mörder	\N	1	1957	S2356	\N	\N	\N	(West Germany)	3b04d69af9f95de89ae1971cc8334fb0
31940	1658758	The Veil of Maya	\N	1	2009	V415	\N	\N	\N	(UK) (working title)	3eb80f4dc4e966ae166811ab05c431da
8786	590508	Hitler's Women	\N	2	2001	H3462	\N	\N	\N	(UK)	57a9bcfbeb84687740632a734e33ddd4
5792	381401	Downton Abbey	\N	2	2010	D5351	\N	\N	\N	\N	a68eec163668a0a7074b501c6d5a179d
19979	1242198	Detective Academy Q	\N	2	2003	D3231	\N	\N	\N	(USA)	bd4af8aaf57accc69dd9e38f1a1e947b
11224	725646	The Frozen River	\N	7	\N	F6256	11241	1	21	(International: English title) (literal title)	d58fdce2a14ec83640d666eefa25772c
30526	1652449	Ein gewisser Dick Dagger	\N	1	1968	G2632	\N	\N	\N	(West Germany) (imdb display title)	3239d85ed8558a54dd05d659875bdc79
11449	731601	Die Insel der dreißig Tode	\N	2	1979	I5243	\N	\N	\N	(West Germany)	95864feb69ce10e741f295de3e078510
21097	1326932	The Fairly OddParents	\N	2	2001	F6431	\N	\N	\N	\N	c460e2b226ad06790e274bcb417f2950
8465	571140	Have I Got Old News for You	\N	2	1990	H1234	\N	\N	\N	(UK) (rerun title)	ee013c9d38c54c1b18905f4a4e8c7501
12039	778724	Mato, der Indianer	\N	2	2012	M3653	\N	\N	\N	(Germany) (imdb display title)	2178d340597c1417427423acee65c4d9
41842	1689095	Bangkokin huuma	\N	1	1994	B525	\N	\N	\N	(Finland) (working title)	6a4d752b4764ae7f7f8193e0a302ac09
27181	1639710	25th Infantry, Gen. Burt & Grant Returning from Fight	\N	1	1900	T5153	\N	\N	\N	(USA) (alternative title)	eac7320215d349dd454cc75a1d88b5fb
23497	1513130	Taitania	\N	2	2008	T35	\N	\N	\N	(Japan) (alternative title)	e22b4c2b26d0452c7be046f6745c410f
28956	1645386	Runaway Flight - A Case of Honor	\N	1	1991	R5142	\N	\N	\N	(Germany)	8a1488ad9ed10b4eb471391d239b7eb2
25262	1622644	Zoe	\N	2	1999	Z	\N	\N	\N	(USA) (second season title)	ca06c985359d7c3f547b0cf92ebee4c1
18611	1158385	Simon und Simon	\N	2	1986	S5325	\N	\N	\N	(West Germany)	d9ca6a24e61de92b8de280b860907e49
46367	1702887	Augusta Kneading	\N	1	1986	A2325	\N	\N	\N	(USA)	a57f629e7e18e7a9bdf6f1235e3297f5
37950	1675873	Lost & Found	\N	1	2001	L2315	\N	\N	\N	(USA) (working title)	66b21fbe27af1c6c1690468f16bda324
39804	1681969	Naag Devi	\N	1	2002	N231	\N	\N	\N	(India: Hindi title) (dubbed version)	4de91b74036183e03393d3aa97b5c80e
25394	1632749	The Eagle	\N	2	2004	E24	\N	\N	\N	(International: English title)	c928f68f47ee0872defcbdd5c95c59b5
41504	1688120	Angelo in the Crowd	\N	1	1952	A5245	\N	\N	\N	\N	7653d84eb3f3cd4574c95c93d48b9051
36087	1671008	Aivazovsky and Armenia	\N	1	1983	A1212	\N	\N	\N	(International: English title)	56a3cf1b180c98268b1a4263ff574246
20288	1261755	Terra Kids	\N	2	2011	T6232	\N	\N	\N	(Germany) (working title)	36d19a1f0c769cbcfb8e1d7b97b20a20
14190	886406	Armistead Maupin's More Tales of the City	\N	2	1998	A6523	\N	\N	\N	\N	669ad13e70c8fa414826bc80b5c328d1
5312	352134	Der große Postraub	\N	2	1966	G6123	\N	\N	\N	(West Germany) (alternative title)	31a8e16de6c238a02ac26f93497e3130
42088	1689726	Anna's Will	\N	1	1975	A524	\N	\N	\N	(International: English title)	aa296c3e4c812f8842b67a173e6d7074
4044	253685	Murder of a Rock Star	\N	7	\N	M6361	4243	10	3	(Canada: English title)	aa0d4223da951103ec17c7d3a66aba21
15334	961446	Oh! Super Milk-Chan	\N	2	2004	O2165	\N	\N	\N	(USA) (literal English title)	1273f1291ae8777bd116095be50891a9
9335	635396	The Sense of Touch	\N	7	\N	S5213	9344	4	1	(USA)	11aa7c6cd980a979177eaa8ca0dd81f8
15693	983586	Ozma	\N	2	2012	O25	\N	\N	\N	(Japan) (alternative spelling)	7c3d2b5f3c7d0415aa076f7cea021282
13327	846456	Stephen Hawking's Sci Fi Masters	\N	2	2007	S3152	\N	\N	\N	(USA) (rerun title)	f3ebf3d8b383b894f76bac3ce069fd7e
23251	1503309	Untitled Tyra Banks/Ashton Kutcher Project	\N	2	2008	U5343	\N	\N	\N	(USA) (working title)	264a1a35d6c7c92f31d6bd49fdecef2c
44148	1695877	Django and Sartana's Showdown in the West	\N	1	1970	D2525	\N	\N	\N	(USA)	fa2568014c1264cc182c39cfb4434d72
15100	946004	Julie the Wild Rose	\N	2	1979	J4343	\N	\N	\N	(International: English title)	7d35163ab8ffc20af857420c3f455e9e
9406	635946	Es war einmal... Entdecker und Erfinder verändern die Welt	\N	2	2001	E2654	\N	\N	\N	(Germany)	04c9648f9d8caeafdfaaa4b61a930971
24287	1560754	War of the Worlds: The Second Invasion	\N	2	1988	W6136	\N	\N	\N	(USA) (second season title)	d17688cb070b7853cdeb5af65007ddec
31172	1655315	Une carte postale de Victoria	\N	4	1983	U5263	\N	\N	\N	(Canada: French title)	9a6b9b0fe4a41d01982178496adf40b1
39405	1680804	One Woman's Way	\N	1	1913	O52	\N	\N	\N	(USA) (working title)	8ea8e063a519d7564b8dbf73c250e92e
28503	1643598	Nove Rapazes e Um Cão	\N	1	1964	N1612	\N	\N	\N	(Portugal) (alternative title)	acbdcb17fda30fd64e8e65177dd3b3cd
18747	1169597	Der Rebell des Königs	\N	2	2006	R1432	\N	\N	\N	(Germany) (DVD title)	bb35254d616e6a76172bd081bb6bbf06
34450	1667173	Mrs Emma 11	\N	1	1995	M625	\N	\N	\N	\N	261f99c9a2893f10b5cbf15cc7b9655d
24775	1600963	Eyewitness News	\N	2	1966	E3525	\N	\N	\N	(USA) (new title)	1d4c167d1d302f9c5ef670ccc0f4281b
35438	1669774	Oh! That Wife of Mine	\N	1	1967	O315	\N	\N	\N	(International: English title)	a242b5853242e62dcc523ba6a5a55378
45177	1699868	Asterix erobert Amerika	\N	1	1994	A2362	\N	\N	\N	\N	7bbb6ce2f073182145ae40e0c8fae767
30688	1653082	Ordinary People, Slight Left	\N	1	2006	O6356	\N	\N	\N	(Canada: English title) (working title)	c434c1989186d9c7965175e27cb98abc
3156	192122	Bâtendâ	\N	2	2011	B353	\N	\N	\N	\N	d4670acd6d1a91f1da9a2072348464dc
25846	1634074	Un corpo da amare	\N	1	1985	C6135	\N	\N	\N	(Italy) (imdb display title)	90fed0b6d967a9a827d2e83497ae0d00
8706	586901	Burn! F1 Spirits!	\N	7	\N	B6512	8707	1	4	(Japan) (literal English title)	c12199a99e08f288c6c03ff506827a75
29488	1648042	Never Duck a Duck	\N	1	1939	N1632	\N	\N	\N	(USA) (working title)	811f8da90a98e0ddd85a79752e735377
22079	1402582	Die magische Münze	\N	2	1998	M252	\N	\N	\N	(Germany)	8553a4df753a46a07c4bf58c552956ff
15577	977114	Opération séduction	\N	2	2002	O1635	\N	\N	\N	(France) (short title)	a2783d269c061aa0ef25fac138710e9c
47739	1706557	Babar, roi des éléphants	\N	1	1999	B1632	\N	\N	\N	(France)	758baba2b264a1c80d193f68ce2e2fb2
23493	1512591	Two Twisted - Svolte improvvise	\N	2	2005	T3232	\N	\N	\N	(Italy)	462da1be32356eb475c097a615fa93d9
43585	1694075	Architecture, art de l'espace	\N	1	1961	A6232	\N	\N	\N	(Belgium: French title)	4101a9f50a0d996d4511479f99d8f202
24577	1590308	Un'ondata di desideri e un vagone di guai per Nick	\N	2	1991	O5323	\N	\N	\N	(Italy)	280698fae5919225bf7ecb9337ddc172
7572	517947	Más Gente	\N	2	1995	M253	\N	\N	\N	(Spain) (new title)	fa42e62676226a686d52f3fa6cb0cc4f
37830	1675189	Best Performance	\N	1	1950	B2316	\N	\N	\N	(USA) (working title)	f25ad13eb9a1719e214dd57658ae29b1
4424	285803	The Jenna Elfman Show	\N	2	2005	J5415	\N	\N	\N	(USA) (working title)	3c59d5575366ca3b881a6b1efff6b11b
33863	1665528	Adam and Women	\N	1	1971	A3535	\N	\N	\N	(International: English title) (informal title)	20c9b23724b854268d158e0af9c102fb
1398	96009	Sindbad	\N	2	1978	S5313	\N	\N	\N	(West Germany)	dd31ec760dc60b21c75f4a5dc71dd233
38724	1678550	Vergeltung - Sie werden Dich finden	\N	1	2007	V6243	\N	\N	\N	(Germany) (DVD title)	b3498932482ae948c279e021e889ea8f
7174	494221	Jim Henson's Fraggle Rock	\N	2	1983	J5252	\N	\N	\N	(USA) (complete title)	8df401d4ab71527433cc90ff8f249056
44376	1696605	Big Wind on Campus	\N	1	2002	B2535	\N	\N	\N	(USA) (new title)	f1efd2cfa38acb205440e047636eec1f
36555	1671927	Devil's Castle Dracula	I	6	1986	D1423	\N	\N	\N	(International: English title) (literal English title)	df26f897e976ed4563983e2692d5a043
25715	1633874	Das Wunder in der 8. Straße	\N	1	1988	W5365	\N	\N	\N	(West Germany)	29b6fc0ef6ffcc435a30d133d2652a51
39159	1679665	Marwad's Moti	\N	1	1925	M6325	\N	\N	\N	(India: English title)	6bc51a6bcd9913dce1ae31898dd59aaf
23320	1504716	The Five Vows	\N	7	\N	F12	23387	2	17	(International: English title)	96166e65a732684f6d5663c843a0b481
22541	1443590	The Voice, la plus belle voix	II	2	2012	V2414	\N	\N	\N	(France) (complete title)	e47f1b558eb9b46f38a75f0f4d6fa7d5
21374	1341752	Spuk in der Schule	\N	2	1986	S1253	\N	\N	\N	(West Germany)	9bac3aa52cd977a4cef9cdaa3e728ddb
30557	1652552	Local Hero	\N	1	2013	L246	\N	\N	\N	(International: English title) (working title)	c8e3b6f51fd60322c7fb036ee58e87b9
29153	1646272	A Flower Out of Place	\N	3	1977	F4631	\N	\N	\N	(alternate title)	e6dc181c1af6bda7a7e64980ed65f3aa
31435	1656596	In Cold Blood	\N	1	1995	I5243	\N	\N	\N	(International: English title) (informal literal title)	5dfd126efd3ad58e37190c5f724609e5
24288	1560856	Waratte iitomo!: Morita Kazuyoshi awâ	\N	2	1982	W6356	\N	\N	\N	(Japan) (long title)	5ba7bb253fbb5a409f24813c7889704f
38142	1676585	All American Girl	\N	1	1941	A4562	\N	\N	\N	(USA) (working title)	be028ba3322d27d93aa9e94774657cbf
19094	1196141	Sherlock Holmes: The Strange Case of Alice Faulkner	\N	7	\N	S6424	19093	\N	\N	(USA) (alternative title)	5863c6b119bb216c8fb736081c43e6b4
12499	801992	The Children of Anchor Cove	\N	2	2006	C4365	\N	\N	\N	(USA) (working title)	8d50041fd088e0656be18b9a306c5bc7
19087	1195682	S.T.H.	\N	2	2009	S3	\N	\N	\N	(Philippines: English title) (promotional abbreviation)	1f81e6d7023b6ed778dd84aa5cede265
47588	1706301	Wang Yu kennt kein Erbarmen	\N	1	1972	W5253	\N	\N	\N	(West Germany)	67201ac22629c661db89e1bd1f9db890
44920	1698784	Dark and Handsome	\N	1	1950	D6253	\N	\N	\N	(International: English title)	c04be8b388265dd84f8ddbc4c8a80b27
12076	779308	The Daltons Into Charity	\N	7	\N	D4352	12159	1	40	(International: English title)	b0cc4ab98e3794975e0b7a23389eb7ba
3585	227507	Stairway to Paradise	\N	2	2003	S3631	\N	\N	\N	(International: English title)	cae4128b151b1cb803e42cbe4c37b50d
42906	1691951	The Criminal	\N	1	1931	C654	\N	\N	\N	\N	78655cd2d67d8b3f1b6b687d6a18fce7
23573	1514965	Teknoman	\N	2	1994	T25	\N	\N	\N	(USA)	c241404379488dd0858a288f5e18fe29
39081	1679509	Desperate Road	\N	1	1985	D2163	\N	\N	\N	(International: English title) (festival title)	e97c14d024443d369a76dd078fb91149
41899	1689262	Ankh - Kampf der Götter	\N	6	2008	A5251	\N	\N	\N	(Germany)	33ce194e8aee953d7605ef48a6e2d9c3
35087	1669108	Agent 69 in the Sign of Scorpio	\N	1	1977	A2535	\N	\N	\N	(USA)	44d20d1786e7fc50a4d9feff04c7c5cd
35338	1669514	The Agony of Love	\N	1	2004	A2514	\N	\N	\N	(USA) (DVD box title)	1c6a711d0121632cdf8c389e18b829dc
26238	1635320	La carica dei 101 - Questa volta la magia è vera	\N	1	1997	C6232	\N	\N	\N	(Italy) (imdb display title)	8a765b1d3a8d81158a47f1db68be2a4a
18965	1185705	She Came Out of the Blue Sky	\N	2	1978	S2531	\N	\N	\N	\N	62fae2da7df533ff9271d1c04746ae0a
26819	1638076	Zwei Superfilme in einem	\N	1	2006	Z2161	\N	\N	\N	(Germany)	11a5fa8604a83289d2461e94f7e4da4e
34512	1667357	Terminal	\N	1	2010	T654	\N	\N	\N	(Greece) (imdb display title)	62c1e1718968f46872535ab168d5aba4
1242	81259	A.B.H.S.A.T.	\N	2	2009	A123	\N	\N	\N	(Philippines: English title) (promotional abbreviation)	5408b979586caac66893e0afe9578b12
33782	1665197	Action Girl Allysin	\N	4	1991	A2352	\N	\N	\N	(USA) (alternative title)	5ca86126e86250962b301e530fbbeabb
42409	1690635	Beyond the Mist	\N	1	1986	B5352	\N	\N	\N	\N	f46975d186844b908e98674c2b8270d8
30793	1653680	A Mud Bath	\N	1	1913	M313	\N	\N	\N	(USA) (alternative title)	a6c780dc6d1fca81fb2c325da597ebf7
11086	721580	Krisse Show	\N	2	2006	K62	\N	\N	\N	(Finland) (new title)	d0c36db8d5a84403fc1e649afab0b44f
9634	654793	InuYasha: The Final Act	\N	2	2009	I5231	\N	\N	\N	(International: English title)	b2363d17c6750d360d0161086f2a8cab
48504	1709210	Bagnanti	\N	1	1968	B253	\N	\N	\N	(Italy)	c38fdba316c15a207b13543e4088ea69
3508	222783	Shinning Inheritance	\N	2	2009	S5256	\N	\N	\N	(USA) (informal English alternative title)	05f63bf1271cdfac62fb2a512f5e1a72
21753	1373674	Danny Castellano Is My Gynecologist	\N	7	\N	D5234	21752	1	3	\N	cddd25a666e38040f2471b696c56a2c7
18870	1177415	La principessa e la magia del drago	\N	2	2006	P6521	\N	\N	\N	(Italy)	2c9ba49f1a5e63260544c5b79cf641f2
47127	1705265	Axis & Allies RTS	\N	6	2004	A2426	\N	\N	\N	(USA) (working title)	9a7a88fce50f5f0caf9803f061009b77
37970	1675960	Untitled Mike Leigh Project	\N	1	2001	U5343	\N	\N	\N	(UK) (working title)	51a67dea84038d6826ff54252aef10cc
47574	1706299	Addio mia concubina	\N	1	1993	A3525	\N	\N	\N	(Italy)	9250033e9a0387f731b6a71bc81bc697
25670	1633648	The Making of 'The Terminal Trust'	\N	3	2012	M2521	\N	\N	\N	(International: English title) (imdb display title)	f8c1670e51d414b67db48622ece35276
7022	483324	Critical Incident	\N	2	2007	C6324	\N	\N	\N	(Canada: English title) (working title)	3c78af139245738d935df6573eeb6a01
13714	867598	Inspector Barnaby	\N	2	1997	I5212	\N	\N	\N	(Germany)	ab32d9ca1ee93ed00e4c5765046da80a
49802	1712496	Mississippi-Melodie	\N	1	1938	M2154	\N	\N	\N	(Germany)	7a64c485d7a723c13880dbf3b8977f5e
7386	506304	Good vs Evil	\N	2	1999	G3121	\N	\N	\N	(USA) (new title)	361fc9bc815b271b7e9ec875e13d63f8
15034	943191	Stealth Wind Task Force Hurricanger	\N	2	2002	S3435	\N	\N	\N	\N	069c5d25f27f1d91e1cad0eb7b684267
6090	402991	Etude	\N	2	1993	E3	\N	\N	\N	(Japan) (literal title)	6d2310c06821323941e89712d1508b2c
45227	1700035	Asturias, esa desconocida: Asturias, hoy y mañana	\N	1	1970	A2362	\N	\N	\N	(Spain) (series title)	b1110c531458d01e480bedb1da79fdba
22218	1414193	Personal and Confidential	\N	7	\N	P6254	22227	\N	\N	\N	b2fe7a22b777e435acf056f52d2e7aaf
25632	1633461	Il nostro Natale	\N	1	2001	N2365	\N	\N	\N	(Italy)	1b134764995bab1bbbdd96ddff47546a
33922	1665611	Il ladro di orchidee - Adaptation.	\N	1	2003	L3636	\N	\N	\N	(Italy)	d8efa5882e80685a0523adc5c7d398a6
9194	629027	Lucy ed io	\N	2	1951	L23	\N	\N	\N	(Italy)	6ef309b786707018438f6561440c986d
28825	1644947	Mörderische Tarnung	\N	1	1994	M6362	\N	\N	\N	(Germany)	838f36b0a1afd13203f64a58f2317a52
46452	1703214	I See This Land from Afar	\N	1	1978	S3245	\N	\N	\N	(USA)	67b097dc6c038774b426dc801e5cc55e
15804	991484	Paranormal State	\N	2	2007	P6565	\N	\N	\N	\N	0f54aaf1d6f01fb6ff09105b951712de
46817	1704292	Kinect Fun Labs: Avatar Kinect	\N	6	2011	K5231	\N	\N	\N	(USA) (imdb display title)	1cd501c89195048ec49e7c2217d5343c
43411	1693583	Felix the Cat in Arabiantics	\N	1	1928	F4232	\N	\N	\N	(USA) (long title)	70dde3a1be8bb49854a0eb93a102fc0b
49771	1712427	La pornographie thaïlandaise	\N	1	1977	P6526	\N	\N	\N	(France)	fa7a5de5fd774c0ba98c9c77be26fc95
36476	1671768	The Siege	\N	1	1979	S2	\N	\N	\N	(UK)	7ffc62b5fbbea1b44a0dfa75a25feea8
6138	405441	Otto bastano	\N	2	1977	O3123	\N	\N	\N	(Italy)	a253f3da956f5dee9d6512e269e2702c
38579	1678067	The Guilty One	\N	1	1916	G435	\N	\N	\N	(USA) (alternative title)	2ee0da3233ce4eb0b91af61c38ad1ee3
1173	76493	Ill-Fated Love	\N	2	1979	I4134	\N	\N	\N	(International: English title)	4dadeda7ced2a054adb6a7c4a5505d94
29290	1646867	The Bail Bonds Story	\N	1	1949	B4153	\N	\N	\N	(USA) (working title)	f969bc6fb735ea16110ea404eb3de64e
12900	829176	Madoka Magica	\N	2	2011	M3252	\N	\N	\N	(Italy) (imdb display title)	68b4284d7621ca4a5578432a3a4b9be3
40452	1684046	Girls Dancing Can-Can	\N	1	1902	G6423	\N	\N	\N	(USA) (copyright title)	19a92f95166692a31c5cdb273390932b
46170	1702295	The One Who Came from Heaven	\N	1	1975	O5251	\N	\N	\N	(International: English title)	6a27e66ffc7ff6a26eb45215e7def4f2
49603	1711889	Wedding Planners	\N	1	2010	W3521	\N	\N	\N	(International: English title) (imdb display title)	57c0ca81e9da96256e18e07affcb2b4f
14902	930517	Lorne Greene's New Wilderness	\N	2	1982	L6526	\N	\N	\N	(Canada: English title) (complete title)	339b48da387d8ceec695614fa3e4b9e2
33540	1664428	Achtung Harry! Augen auf! - 6 Wochen unter den Apachen	\N	1	1926	A2352	\N	\N	\N	(Germany)	a8455095211c8e18c0f3bcf8b2ba153a
25444	1632981	The Old West Per Contract	\N	1	1917	O4323	\N	\N	\N	(USA) (working title)	efd85523de2b1248073e3a765101facd
8972	609324	Horror Accidental	\N	2	2013	H6235	\N	\N	\N	(Japan) (literal English title)	535d74c34828adbf7c91fca0c66a4be5
38147	1676588	Trappola per un innocente	\N	4	1991	T6141	\N	\N	\N	(Italy)	517c94dd1854d737c5f48b06010eff65
32862	1662375	Piraten wider Willen	\N	1	1954	P6353	\N	\N	\N	(West Germany)	20388503b7e2e4b3beeef9d87e807b3c
18691	1164833	Sky News: Lunchtime Live	\N	2	2005	S2524	\N	\N	\N	(UK) (first season title)	ed49ac77cf1a3192dc2af72230988307
21190	1333141	The BOMP News	\N	2	1990	B5152	\N	\N	\N	(USA) (working title)	e9688bde68b52e437c4624fa7e57a202
23256	1503544	Michael Winner's True Crimes	\N	2	1991	M2456	\N	\N	\N	\N	0542dd202852933382a5a9674435c2d6
23096	1492921	Totally Spies!	\N	2	2001	T3421	\N	\N	\N	(France)	ef002be322885705248447207d61f757
29416	1647701	Ein Mann mit Phantasie	\N	1	1963	M5315	\N	\N	\N	(West Germany) (TV title)	c1139e4105562143a1e96e4819bc26f2
41184	1687171	Andy Hardy incontra la debuttante	\N	1	1940	A5363	\N	\N	\N	(Italy)	23dacec30b2bd601b73383eb3cf111d7
29365	1647411	Over the Edge	\N	3	2004	O1632	\N	\N	\N	(USA) (alternative title)	599bef812fd876fa6e56a3396e3c9a00
9993	684570	Journeyman - Der Zeitspringer	\N	2	2007	J6536	\N	\N	\N	(Germany)	a25944969a7d69eb99b0a51fa1e664c0
14792	918064	Hitler's Killer Police: Ukraine and Lithuania	\N	7	\N	H3462	14799	1	13	\N	a062a7dc1bad48f851dc81c4efa41e4b
42509	1690989	Anticasanova	\N	1	1985	A5325	\N	\N	\N	(East Germany) (imdb display title)	00f8eca67b893a143fe8ce4f6ffa8fe7
7122	489342	The Blush	\N	7	\N	B42	7123	4	37	(USA) (alternative title)	f7fe30be8b8779ee5a0e6266d13ac44c
27196	1639759	27 heures	\N	1	1987	H62	\N	\N	\N	(France)	df1147c6661a274df9ddc50756f60cad
9927	679563	Jiskefet	\N	2	1990	J213	\N	\N	\N	\N	3c872ffe6689be2ce824b4d66ce3a018
12850	828069	Up, Up and Away	\N	7	\N	U153	12871	1	11	\N	8549e8303b609bbd754369f50f59e296
5030	335021	äÅÌÏ óÕÈÏ×Ï-ëÏÂÙÌÉÎÁ	\N	2	1991	\N	\N	\N	\N	(Soviet Union: Russian title) (original Cyrillic KOI8-R title)	7cb764dd971f987f9a7aeb1b44fa6db6
14249	889254	Mont-Royal	\N	2	1988	M5364	\N	\N	\N	(France)	4404b0fcf5e4a5395240d73ce2e48828
32427	1660876	Alam laysa lana	\N	1	2012	A4542	\N	\N	\N	(Lebanon: Arabic title) (imdb display title)	694562fbbce6a6047bbd79c38556d3ca
15481	973767	Because I Don't Like My Big Brother at All!	\N	2	2011	B2353	\N	\N	\N	(International: English title) (imdb display title)	1ffe8c908d2232823ff47f3393fa6328
38866	1678946	Aliyah	\N	1	2012	A4	\N	\N	\N	\N	badcc93d319b4d66794d7059b075ee08
6009	392536	ä×ÏÊÎÁ ÐÒÉÍËÁ	\N	2	1987	\N	\N	\N	\N	(Bulgaria: Bulgarian title) (original Cyrillic KOI8-R title)	13224d450c52342e2f6fe2ce0a09db69
19232	1202912	óÔÏÌÉÞÁÎÉ × ÐÏ×ÅÞÅ	\N	2	2011	\N	\N	\N	\N	(Bulgaria: Bulgarian title) (original Cyrillic KOI8-R title)	ada8667b25b92368a1b0941a913e85b8
21060	1324935	Ellen, Again	\N	2	2001	E4525	\N	\N	\N	(USA) (working title)	5c11a25c2941021ab60a4f6106489dc7
11685	753069	Planet der Giganten	\N	2	1989	P4536	\N	\N	\N	(West Germany)	2b1eef01ddf5bf8456ab46808f8cb445
20785	1297440	Disney's The Buzz on Maggie	\N	2	2005	D2523	\N	\N	\N	(USA) (complete title)	3d02be9e9284ec9cf0b33206f2f428a7
30848	1653843	Die Dame mit den Sonnenblumen	\N	1	1918	D5352	\N	\N	\N	(Germany)	7a320aac664326c4ce3accaf169e5361
11349	727900	Carnation	\N	2	2011	C6535	\N	\N	\N	(International: English title) (imdb display title)	270fdcfd6d78fa4672d1ac9038bda71e
22340	1421293	Julius Caesar	\N	2	1963	J426	\N	\N	\N	\N	350f5b5dcbc0cbc00157bc6835332326
43223	1693036	Fang nie im April was an	\N	1	1935	F5251	\N	\N	\N	(Germany) (working title)	4e61c6cbf930d2f2eb0d782794e32332
20722	1288263	The Block 2011	\N	2	2011	B42	\N	\N	\N	(Australia) (fourth season title)	4bd60522c32c6f9fdc8dedc2921820e4
46188	1702330	U.S.N. Dept., Auction of Deserters' Effects	\N	1	1904	U2531	\N	\N	\N	(USA) (alternative title)	78b1b78c4a0dd733b3654329d32fc467
32690	1661846	Arrivée de Legagneux dans la capitale belge	\N	1	1910	A6134	\N	\N	\N	(Belgium: French title)	2dc5effad118e967b941c07d5f7169ca
14421	899009	Trider G7	\N	2	1980	T6362	\N	\N	\N	(Italy) (dubbed version)	45a6f6c5c88daea730781c78d8e3f805
46717	1704123	Valanga	\N	1	1978	V452	\N	\N	\N	(Italy)	9823177c90ba33bb0cf4eaecf68bec60
41147	1687031	Andrejka	\N	1	1959	A5362	\N	\N	\N	(East Germany) (imdb display title)	770f8d3bf8f733bdbb09f4e8308c8ab7
32593	1661478	Midnight	\N	1	1950	M3523	\N	\N	\N	(International: English title) (informal title)	9972d3c874e42376b317d40b7b9ef35b
39357	1680454	America in the Forties	\N	3	1998	A5625	\N	\N	\N	(USA) (alternative spelling)	26d40cf9e365631c4edbe645a6eddca0
34290	1666759	Purple and Fine Linen	\N	1	1936	P6145	\N	\N	\N	(USA) (working title)	3c82e2cd54bf7ec201056676d2a77423
19093	1196135	Standing Room Only	\N	2	1976	S3535	\N	\N	\N	\N	0f16686c12186e0a0e297d749c0da8de
44869	1698571	Ask - Montané. EM-mästerskapet i boxning i lättvikt Helsingfors 17.8.51	\N	1	1951	A2535	\N	\N	\N	(Finland: Swedish title) (alternative title)	00070da97f247abea62f38810a7d369c
37058	1672947	Wings Over the Chaco	\N	1	1935	W5216	\N	\N	\N	(USA) (alternative title)	f3b5f4f3ba986b3d749909ecaea86aa9
27139	1639482	24 ore	\N	1	2002	O6	\N	\N	\N	(Italy)	8409956d5ddae87b511fd1b08b07eb23
45912	1701809	Reifezeugnis	\N	1	1954	R1252	\N	\N	\N	(West Germany)	9104a2eb5dad7305e54a545ddd587f11
27435	1640431	Pahchaan a Journey	\N	1	2012	P2526	\N	\N	\N	(new title)	c425bfd75dd968b840a4b2138f416677
45483	1700770	Long Live Ghosts!	\N	1	1977	L5241	\N	\N	\N	(USA)	fd5eb9c73939b0e4f6dd14d4854530ad
41411	1687806	Insel der verlorenen Seelen	\N	3	1987	I5243	\N	\N	\N	(West Germany)	73068aeefe19103f74beac0ad02f305c
36199	1671268	Wasserspiele	\N	1	2004	W2621	\N	\N	\N	(Germany) (TV title)	c45e1c04bfb6feb8ab23e906ff9bf95c
7383	506248	Giga Green	\N	2	1998	G265	\N	\N	\N	(Germany) (new title)	109ab235c406841210f6f51da14d78de
38461	1677528	Galaxy's Diamond	\N	4	1996	G4235	\N	\N	\N	(International: English title)	fd3af6f5b2c69959529efd9730106910
17015	1072073	Real World/Road Rules Challenge: Fresh Meat 2	\N	7	\N	R4643	17018	19	\N	(USA) (informal alternative title)	33912b43fb1efaf94f2e4e04143d4e00
23008	1486219	Agimat: Ang Mga Alamat ni Ramon Revilla Presents Tonyong Bayawak	\N	2	2010	A2535	\N	\N	\N	(Philippines: Tagalog title) (complete title)	d09250b188ef8c04248187afd046e5ef
42642	1691345	Anvers	\N	1	1923	A5162	\N	\N	\N	(Belgium: French title)	f525580ca7c19df2bd7e7f0f96083b25
40894	1686235	Along the Ridge	\N	1	2006	A4523	\N	\N	\N	(Australia) (festival title)	933acf2fee4c0d33f04bf3f2d8183bb4
15019	942823	2 x 2 = Shinobuden: The Nonsense Kunoichi Fiction	\N	2	2004	X2513	\N	\N	\N	(Japan: English title)	abed70cd48b1d7f68ea916f72e465a70
16821	1062042	La course à la bombe	\N	2	1987	C6241	\N	\N	\N	(France)	3912adb1a3bba3ee33994acb877c85d1
33985	1665818	Büchner	\N	1	1979	B256	\N	\N	\N	(East Germany)	94f63e326e2c4f566859cb3229f3914c
36898	1672515	Le destin	\N	1	1997	D235	\N	\N	\N	(France)	c694e725749f58de9b41e9c0b41a88ff
45144	1699730	Partners in Crime	\N	1	2012	P6356	\N	\N	\N	(UK) (imdb display title)	10935f9367640187e6f08e7e85e08c48
8713	587140	Hill Street giorno e notte	\N	2	1981	H4236	\N	\N	\N	(Italy)	31d26082d4c1ebf2a7f9fa617f27bb32
32780	1662185	The Phantom	\N	1	1933	P535	\N	\N	\N	(India: English title)	7532ca7b4582e07add1f74272e7578b6
18681	1164155	Skippy, das Känguruh	\N	2	1970	S2132	\N	\N	\N	(West Germany)	b165cc0cf3b959d5bf9f4699132c705a
43299	1693211	Tam, u nas	\N	1	1990	T52	\N	\N	\N	(Soviet Union: Russian title)	a97cfbfb966f51c4bcc749111abb15b9
617	44535	Agatha Christie's Great Detectives Poirot and Marple	\N	2	2004	A2326	\N	\N	\N	(Japan) (literal English title)	efd74d6d7ed9670935545ade39b868bb
26794	1637984	Two Women, Two Men	\N	1	1998	T535	\N	\N	\N	(USA)	93332df971a77da781a519fb3afd5d81
14725	914058	Naruto Shippuden	\N	2	2007	N6321	\N	\N	\N	(Australia)	7497ed6ec96cdb3a2c2d3cb7f6407a17
6680	469086	In tribunale con Lynn	\N	2	1999	I5361	\N	\N	\N	(Italy)	81d3123909bccd11791fd9f079d2a8ce
14654	913759	îÁÒÏÄÎÙÊ ÁÒÔÉÓÔ	\N	2	2003	\N	\N	\N	\N	(Russia) (original Cyrillic KOI8-R title)	2b82ea03b0daffd2c4c5056bcf344745
30386	1651828	A Little Dove-Tale	\N	1	1987	L3431	\N	\N	\N	(USA) (video box title)	dd17142b57241e70d2e7935123daa779
201	11076	Tricet prípadu majora Zemana	\N	2	1975	T6231	\N	\N	\N	(Czechoslovakia) (alternative spelling)	e65ad8f69b2b654930391a82d30e304b
40753	1685823	Girl Without a Name	\N	1	1973	G6435	\N	\N	\N	(India: English title)	877c1fd0cc97b18d107055e568eb22a1
24455	1579642	Ein großer Schritt für die Menschheit - Die Missionen der NASA	\N	2	2009	G6263	\N	\N	\N	(Germany) (DVD box title)	ce1fb28713efa4018a80fefc053201fc
30950	1654266	Heading Nowhere	\N	1	2013	H3525	\N	\N	\N	(USA) (subtitle)	48cd810b971c5196d34c99fa66b61188
7375	505561	Efter deadline	\N	2	1996	E1363	\N	\N	\N	(Denmark) (second part title)	c60618533b44d0b4d0544e2d3992799b
14465	903175	Sine novela: My Only Love	\N	2	2007	S5145	\N	\N	\N	(Philippines: Tagalog title) (series title)	a50e3358b73e1af9c889d047c341724b
39862	1682160	Il lago	\N	1	1983	L2	\N	\N	\N	(Italy)	ab0af0139799b57008bb836af0c0bfce
29373	1647435	Tod in einer kleinen Stadt	\N	3	1984	T3562	\N	\N	\N	(West Germany)	7dbf1f2487903c6b9ddc0f966ce08d76
42240	1690082	A Scene at the Sea	\N	1	1999	S2532	\N	\N	\N	(USA)	f15e1d29a2bda1bcd09367069c95e971
32810	1662269	Wild Goemon	\N	1	1966	W4325	\N	\N	\N	(literal English title)	665dab28832a79fd591196a637b8a3b4
47418	1705958	Azur & Asmar	\N	1	2008	A2625	\N	\N	\N	(USA) (trailer title)	d9cc141c9e37473663dff290cb567315
21191	1333141	The Chipmunk Hole News	\N	2	1990	C1524	\N	\N	\N	(USA) (working title)	f39cc0fd3d0302be350fd498cf0ff612
26546	1636261	15: An Exploration of Human Violence	\N	1	2012	A5214	\N	\N	\N	(USA: English title) (working title)	01b7e609ab2e60cbd38d22e45d1c4f2e
1432	97052	Grace Brothers	\N	2	1972	G6216	\N	\N	\N	\N	6067eab7089425370285927b42d0347e
8352	560671	Die Jahre 1985 bis 1989	\N	7	\N	J612	8351	1	8	\N	7b8ca74c7865aaf7f9378ef103233143
3229	197242	May I Help You?	\N	2	1998	M41	\N	\N	\N	(USA) (working title)	6fe9f12a1cace4223ce1b56d1a84d08d
25246	1622065	Tzinor Laila	\N	2	2010	T2564	\N	\N	\N	(Israel: Hebrew title) (alternative spelling)	3cc41ec320cd7e196796aa5c7033a3fb
28839	1644979	Una vita spezzata	\N	1	2009	V3212	\N	\N	\N	(Italy)	2827e8941dd4bea830a46dc281ef91bc
34493	1667310	Träumer schießen keine Tore	\N	1	2005	T6562	\N	\N	\N	(Germany) (TV title)	59701cbe08a5cf9a9ff97df43662a79f
44958	1698942	Friday Evening	\N	1	2006	F6315	\N	\N	\N	(International: English title)	428e649c8c738b97ae5ed743c28d505b
16842	1064546	Full House	\N	2	1988	F42	\N	\N	\N	(West Germany)	ecdbaabbe4712c52a2bfa6821b2ca02b
21733	1371332	The Micallef Programme	\N	2	1999	M2416	\N	\N	\N	(Australia) (second season title)	42912dfabebf892a45e7ed6fe1508055
48774	1709937	Melody from Heaven	\N	1	1977	M4316	\N	\N	\N	(International: English title)	155a5e9d534760db30e46816f3453846
3965	253211	National Lampoon's CollegeTown USA	\N	2	2003	N3545	\N	\N	\N	(USA) (complete title)	dbb646490c06f85ed3c601a8756e6720
11055	720210	Kourtney and Kim Take New York	\N	2	2011	K6353	\N	\N	\N	(USA) (alternative spelling)	22c18528aacafcdf25fe4ce18e4ddb0b
12382	793023	Rodgers & Hammerstein's 'Carousel' with the New York Philharmonic	\N	7	\N	R3262	12383	38	5	(USA: English title) (complete title)	0e26b569101be93ad18e070c970c92c8
33530	1664400	Shownieuws presenteert Achter De Schermen Bij Harry Potter en de orde van de Feniks	\N	3	2007	S5216	\N	\N	\N	(Netherlands) (working title)	e0c62aa276ce7678be4791143c57cda6
8058	554173	Marshal Dillon	\N	2	1961	M6243	\N	\N	\N	(USA) (rerun title)	b1c0d191f3f92c4762536ef4cb4c8a08
41946	1689343	Die Anmeldung	\N	1	1964	A5435	\N	\N	\N	(West Germany)	2d35fa2469e2fadf70ffc32fd79d9a73
15586	977548	Oreimo	\N	2	2010	O65	\N	\N	\N	(Japan) (short title)	611889a1724a0e5252709490807ba539
40153	1682783	Lights	\N	1	2010	L232	\N	\N	\N	(International: English title)	6dfd7a42dafd10cfb2abdcc061b581f2
17611	1105937	Rød snø	\N	2	1985	R325	\N	\N	\N	(Norway)	b3570809e144e05e8dd5b537c579c43e
4545	296551	Wowser	\N	2	1989	W26	\N	\N	\N	(USA)	c9c0ff422d9df6a93cd4156408bd205e
42047	1689611	La lucha de Ana	\N	1	2012	L235	\N	\N	\N	(Dominican Republic) (imdb display title)	8a6c62c517c51beb68215b843bfa457e
6217	408593	El chavo del 8	\N	2	1972	C134	\N	\N	\N	(Mexico) (alternative title)	31fe1b416697eb2b59dd34157118b871
371	27810	Mémoires d'un pays	\N	2	1998	M5623	\N	\N	\N	(Canada: French title)	689d3e7c2a8743899afb48559b181ea1
40334	1683331	Un angelo per May	\N	3	2002	A5241	\N	\N	\N	(Italy) (TV title)	d43f55db664b0b5d976d4aff4c90ea33
45775	1701539	Autumn Blossoms	\N	1	1999	A3514	\N	\N	\N	(International: English title)	6bc2c606e55a48bbdab4d928353311c8
29269	1646826	Das kleine Malheur	\N	1	1937	K4546	\N	\N	\N	(Austria)	e5c5c5f6c680d28fde315e135afbe4da
40330	1683327	Ein Engel an meiner Tafel - Eine Trilogie	\N	1	1991	E5245	\N	\N	\N	(Germany) (TV title)	86ef019d46bb35561b2b910254b750d2
7214	496315	Freddy Heineken	\N	2	2012	F6352	\N	\N	\N	(USA) (imdb display title)	232e2d4bcebe1c8ab5b7b599c73f94b3
37377	1673870	Alfred der Große - Bezwinger der Wikinger	I	1	1969	A4163	\N	\N	\N	(West Germany)	49bd53b1528ae747040a3b980cb53b71
28707	1644269	A Seaside Romance	\N	1	1916	S2365	\N	\N	\N	(USA) (working title)	32be98a084759fd60f522bfef167a97e
15689	983480	James May's Road Trip	\N	2	2006	J5252	\N	\N	\N	(USA)	de843df56bb2b5205cd4990afdc3905f
22237	1414816	Der Mann von gestern	\N	2	1969	M5152	\N	\N	\N	(West Germany)	aeaf468180d1ad5c02bf244a7aa1c52c
18736	1168397	Tutti gli uomini di Smiley	\N	2	1982	T3245	\N	\N	\N	(Italy) (imdb display title)	933b812388d4ca9a0ce49b75c96f702a
39489	1681183	American Bullshit	\N	1	2013	A5625	\N	\N	\N	(USA) (working title)	05cce5ff32b715325ef3f7f0156eaac5
47093	1705094	Return of the Magic Hat	\N	1	1946	R3651	\N	\N	\N	(International: English title)	fadf08f7eed6951aa3c12848c813f7b2
16587	1047758	Der Notarzt - Rettungseinsatz in Rom 2	\N	2	1992	N3623	\N	\N	\N	(Germany)	0431a1624ca699cf4e737ca01663f549
16326	1031494	Pompeji - Der Untergang	\N	2	2008	P5123	\N	\N	\N	(Germany) (DVD title)	06c53656273acefa7cf42dede18000ed
3386	211104	Casper & Mandrilaftalen 2: Fisso	\N	2	1999	C2165	\N	\N	\N	(Denmark) (video box title)	22665dc5af628079b243296f3ff20a23
30254	1651236	Die Ritter des Königs	\N	1	2009	R3632	\N	\N	\N	(Germany) (DVD title)	3b9a7d06dfe2324936595c04b9fd8abe
1048	73554	AhS	\N	2	2011	A2	\N	\N	\N	(USA) (informal short title)	2ca4ee5538da909c7ef3cca5ece7c8d4
20022	1243720	Im Namen des Volkes	\N	7	\N	I5321	20079	1	52	(West Germany) (working title)	02487cae248e9399ed4ba897e068bf5f
20423	1271083	Die Jagd nach dem Kju Wang	\N	2	2002	J2352	\N	\N	\N	(Germany)	30789375784c0f3ae89dd31ee1cb7100
4915	329058	Dead Man's Walk - Weg der Verdammten	\N	2	1996	D3524	\N	\N	\N	(Germany) (imdb display title)	3ec8ae15ae4d027307fd27dd229d5cba
47341	1705745	Free Fall	\N	1	1997	F614	\N	\N	\N	(USA)	5f254e7e5ae3997de2387a1dac9b1823
48699	1709785	Brave Pratap	\N	1	1947	B6163	\N	\N	\N	\N	71f4726138964c05de3ffc6ccebeb390
15826	994196	Isabelle of Paris	\N	2	1979	I2141	\N	\N	\N	(International: English title)	d1969b5b2e43a961ce485f73ffcade59
38980	1679231	Am Tor des Todes	\N	1	1918	A5363	\N	\N	\N	(Germany)	50451890583755ecd977fb4e939f2fa1
39280	1680205	Civil War - Ein Krieg kennt keine Helden	\N	3	2010	C1465	\N	\N	\N	(Germany) (DVD title)	c376e2023cd05b8fabbc979ca7963b19
7168	494107	Fra skrot til slot - bedre bolig, bedre liv	\N	2	2004	F6263	\N	\N	\N	(Denmark) (seventh season title)	854317ad65829a9636520680ca704ff3
45749	1701462	In Angst gefangen	\N	1	1988	I5232	\N	\N	\N	(West Germany) (imdb display title)	f5f4a4b61eacf1bfa5a8b9e518f63b24
2214	145678	Noch Besserwissen	\N	2	2007	N2126	\N	\N	\N	(Germany) (second season title)	539766d79edcc300203b310f57b8abcf
32650	1661711	Aakrosh - Schrei der Pein	\N	1	1984	A2626	\N	\N	\N	(West Germany)	b21fdc52956ffb11c981795d47ba5697
46551	1703475	Deadly Unna	\N	1	2001	D345	\N	\N	\N	(Australia) (working title)	69aa174bba482580b9b8d217df06c442
41296	1687542	What Isn't There	\N	1	2012	W3253	\N	\N	\N	(Philippines: English title) (alternative title)	2dc4a0cbc16d5d3282906c05f805b02c
33483	1664281	Sex Odyssey	\N	1	1974	S232	\N	\N	\N	(UK)	8062ff9d834bc2b6a0a2548cfcefa4a6
13170	836536	Ninja, the Wonder Boy	\N	2	1979	N5235	\N	\N	\N	(USA)	056834f014e1b4cc3d64c6d531b49a3d
15624	978703	The Osbournes: Loud and Dangerous	\N	2	2008	O2165	\N	\N	\N	(USA) (working title)	5e501d8fff91868c0264173188cdedb1
6142	405711	Two Worlds	\N	7	\N	T6432	6153	1	2	(USA) (DVD title)	786b87fdb561653b4cc24359566514fc
42743	1691653	He's My Girl II	\N	4	1993	H2526	\N	\N	\N	(Germany)	ccf0eb94053ffbeb80d0651e709e26ef
5464	361521	Dilophosaurus	\N	7	\N	D4126	5463	2	43	\N	8e86a7960483fa86645aebfded2dec4e
27480	1640588	Thirty Years of James Bond	\N	3	1992	T6362	\N	\N	\N	(International: English title) (alternative spelling)	b4a072e849a6ed4f68d962349ce62aff
13569	860392	Menekse and Halil	\N	2	2007	M5253	\N	\N	\N	(International: English title) (informal literal title)	10013265d9ebc2324ca85fac1400fb8d
14608	912110	Les leçons de Josh	\N	2	2004	L5232	\N	\N	\N	(Canada: French title)	53d0a2468b0bf9621ce886df3006069f
20861	1307026	The War in Color: The American Story	\N	2	2001	W6524	\N	\N	\N	\N	b1d71a40fd0e9edc6e1351579b047a63
44800	1698139	Tear and Smile	\N	1	1995	T6532	\N	\N	\N	(International: English title)	4204b772cfefdb2044bc464350895b65
35721	1670176	For Love's Sake	\N	1	2012	F6412	\N	\N	\N	(International: English title) (imdb display title)	b32790978c00c4a004569de8251b842e
15742	987878	Pangako sa iyo	\N	2	2000	P52	\N	\N	\N	(Philippines: Tagalog title) (alternative spelling)	e22a8a11ccc66c372a05bc9f8c2ccd37
42797	1691769	Fifteen	\N	1	2001	F135	\N	\N	\N	(International: English title)	f2c9dd625ce4d347cecb195d529bd4b0
26899	1638316	20th Century Boys: Chapter Two - The Last Hope	\N	1	2009	T2536	\N	\N	\N	(International: English title)	85f928a0ec989433ba665147ed634679
3765	234758	Trans Time Space Fortress Macross	\N	2	1982	T6523	\N	\N	\N	(Japan) (literal English title)	f17507eaf8e48c4b4d5f71d6df0825bb
29512	1648171	Budd Schulberg's A Face in the Crowd	\N	1	1957	B3241	\N	\N	\N	(USA) (complete title)	b9992f1d6ef6baf612407bea97888abf
30269	1651310	We'll See You at the Exit	\N	1	1986	W4232	\N	\N	\N	(USA)	bbf2402fe7f03580a004bcb51aba52d4
38743	1678637	Ambition for Gold	\N	1	1961	A5135	\N	\N	\N	(International: English title)	692f1ecd99c7d2e359d0af790b92bd4c
153162	2001786	Partner	\N	1	1950	P6356	\N	\N	\N	\N	e52c0e6d94785ceb290a1d169745a6a4
43967	1695307	Army Information Film No. 7	\N	1	1950	A6516	\N	\N	\N	(USA) (short title)	54a5ad6ed900499a5cf0ad427f202ad2
20421	1270904	Kit Carson	\N	2	1951	K3262	\N	\N	\N	\N	16364bf1683dd5ff3119828f7e628a35
33185	1663328	Zwei Halleluja für den Teufel	\N	1	1972	Z4216	\N	\N	\N	(West Germany)	c383d785dce6f854b1d88f10f16fac2a
44205	1695971	Sports Parade: Arrow Magic	\N	1	1947	S1632	\N	\N	\N	(USA) (series title)	4bc714d20688e4b9e6bd0f88ccf57b48
8509	574203	Headliners & Legends Bill Clinton	\N	7	\N	H3456	8508	\N	\N	\N	eadbcd4867a9b55c1d2f20da5426be16
28473	1643533	Federico Fellini's 8 1/2	\N	1	1963	F3621	\N	\N	\N	(USA)	b56d2e11c96e389a00122114b1c34af8
32464	1661025	Lo zoo di Venere	\N	1	1985	Z3156	\N	\N	\N	(Italy)	843897258742e408a0f4bb967601beb6
16389	1035136	Port Charles: The Gift	\N	2	2003	P6326	\N	\N	\N	(USA) (last season title)	6b18da4af5b0891256d8f15e3549f544
22835	1471078	Time Classroom: Adventures of the Flying House	\N	2	1982	T5242	\N	\N	\N	(Japan: English title) (literal title)	80fbd7d9d8d512e20e45717b5fd64363
37157	1673238	Alptraumfieber	\N	1	2011	A4136	\N	\N	\N	(Germany) (alternative spelling)	29e9a8e7cf004c7cba9bbbf8eb9644a8
31490	1656773	Absturz - Leben nach der Katastrophe	\N	3	1999	A1236	\N	\N	\N	(Germany)	f2da067744814e6fc46490a2cdb56b0c
37597	1674496	Alice löst das Rätsel	\N	1	1925	A4242	\N	\N	\N	(Germany)	c91bf9a5f4adaf58f03521cb374b237b
37187	1673352	The Alderman's Picnic	\N	1	1910	A4365	\N	\N	\N	(USA) (alternative title)	5ef0558a3b1a4d371d36316d8c4838db
19304	1207194	The Strogovs	\N	2	1975	S3621	\N	\N	\N	\N	2471cedb60839dd9989b3e73cdf8b05d
36405	1671607	Late Autumn	\N	1	1960	L35	\N	\N	\N	(International: English title) (imdb display title)	852ec3d9bbf8455b6e67d83c1ad9dafc
35152	1669184	S.O.S. agente 017 plenos poderes en Estambul	\N	1	1966	S2531	\N	\N	\N	(Spain) (imdb display title)	f68224c0f58d29d302f4c11bff53341f
18049	1133549	SeaQuest	\N	2	1994	S23	\N	\N	\N	(Italy)	1e1a6bb50f1fc42faef3e6ba8288e255
7580	520974	New Dimensions	\N	2	2002	N3525	\N	\N	\N	(Australia) (second season title)	703efa7bd33329124ae2488347f12cb4
43872	1694981	The Charcoal Man's Reception	\N	1	1897	C6245	\N	\N	\N	(UK) (imdb display title)	aca87113e30ba545a61673dbb2b80dc8
3358	206714	Voce dei canti	\N	2	1998	V2325	\N	\N	\N	(Italy) (short title)	853578d33ae47a215993655d0fa8599c
3928	251225	Code Blue	\N	2	2000	C314	\N	\N	\N	\N	988b327044d504ba590932a53eac97a4
3556	225290	Franky's Favorites	\N	2	2009	F6521	\N	\N	\N	(USA) (working title)	48c2306a8fe725bb364a88c7ec8aa91e
42969	1692108	Hideous Mutant	\N	1	1976	H3253	\N	\N	\N	\N	3b1d4a8f2104a62d051c833c72bbf433
49847	1712589	Ghetto Gangz - Die Hölle vor Paris	\N	1	2006	G3252	\N	\N	\N	(Germany) (DVD title)	5ef800512f37153852567facc8e3471a
15272	958015	ï, ÓÞÁÓÔÌÉ×ÞÉË!	\N	2	1999	\N	\N	\N	\N	(Russia) (original Cyrillic KOI8-R title)	5f60f05bb2219933a12dd1c72720a2bc
11014	718898	The Yamauchi Family Banner	\N	7	\N	Y5215	11013	1	6	(International: English title)	a7a9078f39d9251869cd4cc2a4566f2f
1887	129985	Grandparents Are Grand	\N	7	\N	G6531	1886	6	3	\N	d1d992edc7e6a70e16c6efaa6c36f831
41543	1688191	Madcaps il fronte della violenza	\N	1	1968	M3212	\N	\N	\N	(Italy)	2a34f75d39f8cf2cc60b06d24d23b8e0
38736	1678623	Dono di primavera	\N	1	1943	D5316	\N	\N	\N	(Italy)	bb22e621bb44c4c6f581bd9209707c1f
31302	1655886	The Heart's Root	\N	1	2000	H6326	\N	\N	\N	(International: English title)	d1ff664184def0f04bb81e12764406ed
40231	1683097	Letzter Ausweg - Affäre	\N	3	1988	L3236	\N	\N	\N	(West Germany)	40c2f81b1cb5e9c4759f984cbcada568
41944	1689338	Lil' Women 2	\N	4	1996	L45	\N	\N	\N	(International: English title)	d34446331464d12ce70990651539329d
42845	1691867	Áð' ô' áëþíéá óôá óáëüíéá	\N	1	1972	\N	\N	\N	\N	(Greece) (original Greek ISO-8859-7 title)	b49e2af5622c6f249046a035b7d6d6ac
34891	1668704	Agaatha	\N	1	1985	A23	\N	\N	\N	(UK)	843375e7baffc814bebc23384756195b
13654	864111	Maison Ikkoku	\N	2	1986	M252	\N	\N	\N	\N	799aba0154f74539a3f78ee3c72234b1
10172	696559	Êáé ðÜëé ößëïé	\N	2	1999	\N	\N	\N	\N	(Greece) (original Greek ISO-8859-7 title)	0d8eba19411f87d88d5c3df8cc24f355
16728	1054936	Bonds of Blood	\N	2	1997	B5321	\N	\N	\N	(International: English title) (imdb display title)	c383564c27e58ab2f2d98ea7f9176da1
4636	301262	Syksyn sävel retro	\N	2	2012	S2521	\N	\N	\N	(Finland) (second season title)	e602d3179c861abc8f44fc821de5074d
41251	1687420	The Wheel of Life	\N	1	1935	W4141	\N	\N	\N	(Philippines: English title)	b00e22e0a8f68fcd0d87ad5dc5378486
6288	425439	Studio 66 TV	\N	2	2012	S31	\N	\N	\N	(UK) (new title)	665fe464366c8d903ca048e4703de75b
29001	1645615	Un Natale da Charlie Brown	\N	3	1965	N3432	\N	\N	\N	(Italy)	d07b5a16c0471bde3700c6b41e123b4c
47639	1706354	Love for All Seasons	\N	1	2003	L1642	\N	\N	\N	(International: English title) (imdb display title)	0ee3e2e7fb09109275bab99878e3edf2
2863	174091	Les deux font la loi	\N	2	1992	D2153	\N	\N	\N	(France)	c6ec6c1a7c777d1691e0b8190a3b5111
10105	694269	Ninja Scroll: The Series	\N	2	2003	N5264	\N	\N	\N	(USA)	0a06331997809ebf39ac934b45da5e7f
25875	1634135	Quartiere maledetto	\N	1	1939	Q6365	\N	\N	\N	(Italy)	ac9eb6f416d00d1d46364fbe8f0ab06c
9242	631810	I, Clavdivs	\N	2	1976	I2413	\N	\N	\N	(UK) (alternative spelling)	17897bb15a142057bbc460e5ebd4b416
202	11108	Queen of Jordan	\N	2	2006	Q5126	\N	\N	\N	(USA) (alternative title)	730c89c7b8e858ccc0615f507b70155e
20691	1284778	The Biggest Loser: Couples 4	\N	2	2011	B2342	\N	\N	\N	(USA) (eleventh season title)	32bded3a0ab6a7b322c54c05a3945717
28694	1644190	Sailors Waltzing, Flagship Kearsage	\N	1	1902	S4624	\N	\N	\N	(USA) (alternative title)	8b73f2224224bbae4642b68ee19cc7f7
42815	1691806	A Blue Automobile	\N	1	2004	B4351	\N	\N	\N	(International: English title)	b166525c9ccdc416f23ddba13182cdef
19270	1205158	Street Fighter II: Victory	\N	2	1995	S3631	\N	\N	\N	\N	5961e6d9e79118116323dae574d8fa20
37360	1673807	Cannibal! The Musical	\N	1	1996	C5143	\N	\N	\N	(USA) (new title)	578336e5f7602865bc941bfbec35c084
46576	1703641	A2 Racer	\N	1	2004	A626	\N	\N	\N	(Italy)	08334388515f73d26c8fba20cf3ad387
45813	1701599	Z-tzu te kung tui	\N	1	1982	Z3232	\N	\N	\N	(Taiwan)	d54c3443e6e65e1ca44b2c2da30249e3
15357	962172	Ïé Ôåëåõôáßïé åããïíïß	\N	2	1990	\N	\N	\N	\N	(Greece) (original Greek ISO-8859-7 title)	892a25c9e5d471d395f8a8f8f022f2d6
30936	1654256	A Nightmare on Elm Street Part III	\N	1	1987	N2356	\N	\N	\N	(USA) (closing credits title)	354ff095d82ded7f9a66f70e25574ad1
3890	243028	Sex, Lies & Politics	\N	7	\N	S2421	3889	1	2	(USA) (video title)	21882d60194e62a0cf1d72396c6af7a1
13821	873065	Miracle Girl Limit	\N	2	1973	M6242	\N	\N	\N	(International: English title)	ae7bd46465e8c60f394dfa59f769f3f3
36794	1672368	The Wanderers	\N	1	1966	W5362	\N	\N	\N	(International: English title)	af2be7df060e03fdfe420308320f3636
25928	1634205	Johannisfeuer	\N	1	1954	J5216	\N	\N	\N	(Austria)	5a10de070ef88badf3abfd1d517570cd
36256	1671332	Nuda per un pugno di eroi	\N	1	1966	N3165	\N	\N	\N	(Italy)	22947a7480f89c984463b7a3833c6446
47280	1705657	Mao, the Real Man	\N	1	1995	M3645	\N	\N	\N	\N	7300238394d99d7bd730def06df69a57
46292	1702674	Auf Wiedersehen, Franziska!	\N	1	1942	A1362	\N	\N	\N	(Germany) (alternative spelling)	592f8ea95ae0dab8f545695f3832e608
24575	1590233	Kampf gegen die Mafia	\N	2	1987	K5125	\N	\N	\N	(West Germany)	1c1f42b38e0944ced027ba400f221fcd
24514	1585247	Will Quack Quack	\N	2	1984	W42	\N	\N	\N	(USA) (imdb display title)	c361155d1d58ec67df8e0bdaab47e071
38847	1678867	In meinem Herzen bist nur Du	\N	1	1949	I5625	\N	\N	\N	(Austria)	fd140fdff4d05075455e99d8bc41c2b0
16168	1020763	Gioco È Diventato Serio	\N	2	2013	G2315	\N	\N	\N	(Italy) (imdb display title)	0fab4082de27d08ee8a747a1ce30f499
5038	336443	äÅÍÏÎßÔ ÎÁ ÉÍÐÅÒÉÑÔÁ	\N	2	1971	\N	\N	\N	\N	(Bulgaria: Bulgarian title) (original Cyrillic KOI8-R title)	9089c44531cc8fe29a0d849231304f7f
18718	1166484	SM:TV	\N	2	1998	S531	\N	\N	\N	(UK) (short title)	e0dd896433799d06401062054a215be4
30196	1651095	Empress and the Soldier	\N	1	1936	E5162	\N	\N	\N	(informal English title)	02adf20a8eca9573caf80147097d65f5
8329	559798	Halifax f.p: 20	\N	7	\N	H4121	8336	1	20	(Australia) (working title)	1d965b32248e239908229019d6a9599f
46832	1704326	Elle a dit oui	\N	1	1998	E43	\N	\N	\N	(France)	a858372108ae1f681ceaa087f192e92f
24816	1603038	WWE Raw's 15th Anniversary Special	\N	7	\N	W6235	24815	\N	\N	\N	e0d959ee60a1b2b586352bf5bb1b3599
21848	1379860	The New Adventures of Mighty Mouse	\N	2	1980	N3153	\N	\N	\N	(USA) (second season title)	9d104d3c2c44682dd0b5df65d8be2fb0
38605	1678145	Amore non fare la stupida stasera	\N	1	1974	A5651	\N	\N	\N	(Italy)	4df9e93ec07ff5dfccd05a84bf975e6e
14061	882299	The Door of Memory	\N	7	\N	D6156	14138	1	61	(USA)	d9bc894939fe47e64871205d87e504f4
26283	1635482	Eleven Harrowhouse	\N	1	1974	E4156	\N	\N	\N	\N	ca2042a1487d294f4abcbc77cfd87058
6554	458841	Jubilee/Marshall Family Part 1	\N	7	\N	J1456	6557	9	1	\N	78cd5ecf1292ae48bc3cb7845255c26c
8609	581913	Cortes	\N	7	\N	C632	8614	1	4	(Greece) (transliterated ISO-LATIN-1 title)	c72c4cd6be2034f8014d792c9300c69b
1014	70335	America's Most Talented Kids	\N	2	2004	A5625	\N	\N	\N	(USA) (new title)	4f3e81bdbc1c379a810d081a2e47a081
32320	1660451	A Lady with No Name	\N	4	2002	L35	\N	\N	\N	(USA) (alternative title)	0faf20e6614b078d5693c15d0928084d
3724	234198	Challenge	\N	2	1987	C452	\N	\N	\N	(International: English title) (literal English title)	77a011bfee330dd837784427e142d332
45726	1701422	Vacation	\N	1	1992	V235	\N	\N	\N	(International: English title)	e0cd552d1ad832503381e9740c7aa45c
3581	227504	Getter Robo Armageddon	\N	2	2001	G3616	\N	\N	\N	(USA) (DVD title)	c3fbe9d354da0d00a1a8a6d7319b09c2
25589	1633340	Aleksis Kivi	\N	1	1946	A421	\N	\N	\N	(Finland) (working title)	1b0df4d181638d33b2bfea387506aaa0
49667	1712073	Smokey and the Bandit 6	\N	3	1994	S5253	\N	\N	\N	(USA) (informal title)	44ab6fb03af4647f6b1fe1827ee3649b
29333	1647092	Ein Tag beim Rennen	\N	1	1937	T2156	\N	\N	\N	(Germany)	bafdefcf8d35a6a7f79a728b842c89e1
42862	1691886	Massai - Der große Apache	\N	1	1954	M2362	\N	\N	\N	(West Germany)	2e332ac8fb2c9bae19c1ce73068e9691
4714	304985	Dan Oakland	\N	2	1972	D5245	\N	\N	\N	(West Germany)	d62632c309a12781c0899cd909ac41a0
34847	1668592	Afterparty: FVP185	\N	4	2008	A1361	\N	\N	\N	(International: English title) (promotional title)	f1ebd3de2e3b06b4cbf7e8cea7fb9da2
39807	1681989	Pirjo Honkasalo, elokuvaohjaaja	\N	3	2012	P6252	\N	\N	\N	(Finland) (alternative title)	443da388ab5135071221204b617841d2
11256	725910	The Black Leather Notebook	\N	2	2004	B4243	\N	\N	\N	(International: English title) (literal title)	47cf53fa6da6ba875d98f8f1b8f015e0
44637	1697650	Asakusa Daydreams	\N	1	2010	A2365	\N	\N	\N	(International: English title) (imdb display title)	fe3d892cf0447346bcc33b5bd4eb2a2a
7021	483288	Flash Forward	\N	2	2009	F4216	\N	\N	\N	(USA) (alternative spelling)	e4d7e35445b9b5af167df37afdac27b1
4888	326264	Les pilis	\N	2	1973	P42	\N	\N	\N	(Belgium: French title)	8e4a59f163a208eaebb6928f9a1e82de
42614	1691261	Machín: Toda una vida	\N	1	2002	M2535	\N	\N	\N	(Spain) (short title)	27c0ac694d3d4b6a7a1ddf345daffe65
28880	1645142	Militant Suffragette	\N	1	1914	M4353	\N	\N	\N	\N	c81587d6166eed75e2acb36092193f77
35555	1670017	Love	\N	1	1955	L1	\N	\N	\N	(Hong Kong: English title)	ccbfba0fb5873c0801ab3e51c8d16e4e
12429	793763	The Morning Show	\N	2	1983	M652	\N	\N	\N	(USA) (first season title)	6d446f3e32558366ae4f918a74694de2
48956	1710312	Unter der Haut	\N	1	1998	U5363	\N	\N	\N	(Germany)	28bb4137364a4ae5d412fea9c3780ff6
46012	1702030	A Moonlight Serenade; or, The Miser Punished	\N	1	1904	M5423	\N	\N	\N	(USA)	fe97346a806988bd3a477e8c9248c609
2616	163656	Beat the Invisible Enemy!	\N	7	\N	B3512	2631	1	5	(USA)	24641703029bd624096005d4fd4417d5
26145	1634905	10-Yard Fight '85	\N	6	1985	Y6312	\N	\N	\N	(USA) (reissue title)	c5cc081216bec8bddbbd449b5122d24d
26941	1638407	Jules Verne's 20000 Leagues Under the Sea	\N	1	1954	J4216	\N	\N	\N	(USA) (complete title)	11ea43c690bb6e2f53488a6bab20ba88
44650	1697682	Kaidan Asamagatake	\N	1	1914	K3525	\N	\N	\N	(Japan) (alternative title)	7b82ad50225d91eff9f0c8eb765aa37f
8691	586768	When They Cry	\N	2	2006	W5326	\N	\N	\N	(USA)	a34349ff46e4658267c900d3dc5453ab
43462	1693693	Arakallan Mukkal Kallan	\N	1	1974	A6245	\N	\N	\N	(India: Malayalam title) (alternative transliteration)	1079440aa8402188cefb85a95425b181
26058	1634544	Street	\N	1	2011	S363	\N	\N	\N	(USA) (working title)	bed6e8c9e47bcc9b3ba853eeca7c0ab4
44163	1695884	Joe y Margerito	\N	1	1974	J5626	\N	\N	\N	(Spain) (imdb display title)	57b944bba10da8dbffe0e7d9dfd7ff1c
25820	1634032	And for a Roof a Sky Full of Stars	\N	1	1968	A5316	\N	\N	\N	\N	2088cfadcc466c0b7d06716d3963289a
31983	1658891	Seven Graves for Rogan	\N	1	1982	S1526	\N	\N	\N	\N	c542d3f054f2175bc9cb10662b4c8762
14929	931901	CNN NewsNight	\N	2	1983	C5252	\N	\N	\N	(USA) (reissue title)	39e3b4a2b4bbc2bcef6e3e1a54f55b48
22895	1475621	To theatro tou Savvatou	\N	2	1971	T3632	\N	\N	\N	(Greece) (first season title)	2b6391345478d9e4fc39cb483ef74630
39449	1681065	Il vincitore	\N	1	1985	V5236	\N	\N	\N	(Italy)	a0d727b72a9780acc16ba8a094adc5c2
23559	1514934	Don Horror's Son Returns to Demonspace Castle	\N	7	\N	D5625	23564	1	30	(USA)	ae85b1ee0d4e94dcdea7bbb49193e29b
41844	1689095	Kaikki tai ei mitään	\N	1	1994	K2353	\N	\N	\N	(Finland) (working title)	a9779d42659ede2f26513e9209c37984
36703	1672183	The Shoemaker	\N	1	2009	S526	\N	\N	\N	(International: English title) (informal English title)	fed74e385f8d4888c7ccf3f32285b13f
30190	1651069	Una maniera d'amare	\N	1	1962	M5635	\N	\N	\N	(Italy)	fa308360952dfa32dc2536a55412f4c3
44071	1695565	Around the World in 80 Minutes with Douglas Fairbanks	\N	1	1931	A6536	\N	\N	\N	\N	9258094aa6093e234dea1ebb29957b34
21140	1329487	Dino and Cavemouse	\N	2	1980	D5321	\N	\N	\N	(USA) (segment title)	c35fa735501af631b385847c2038dbe4
29287	1646865	No Surrender	\N	1	1995	N2653	\N	\N	\N	(UK) (video title)	d57d42bbacee6643b3ce49d2a2eabcbf
5430	358757	Es bleibt in der Familie	\N	2	1983	E2141	\N	\N	\N	(West Germany) (working title)	5cc8decc3247024ff0120489d4ffa887
40915	1686265	Anchorman - Die Legende von Ron Burgundy	\N	1	2004	A5265	\N	\N	\N	(Germany)	09c31d26d18e19656e6b26769b8ecc03
27607	1640913	37 Geschichten vom Weggehen	\N	1	1997	G2351	\N	\N	\N	(Germany)	3612e5112b698e123550ae20f64142c8
36266	1671355	Ultima 0: Akalabeth	\N	6	1979	U4352	\N	\N	\N	(USA) (alternative title)	73663301e86f7fdd220354659f4b2325
23958	1536297	Sur	\N	2	2013	S6	\N	\N	\N	(working title)	bfa30a6c7ad8c1d9a2715116e56fba86
48226	1708111	Viitta ja vallankumous!	\N	1	1992	V3214	\N	\N	\N	(Finland) (working title)	17fdd6676afbe361427ca523ff94274f
20799	1299032	The Cazalet Chronicle	\N	2	2000	C2432	\N	\N	\N	(UK) (working title)	064cc193e8ec8e46e706e55d1837dd58
38662	1678314	When it Got Dark in Germany	\N	1	1999	W5323	\N	\N	\N	(USA) (informal English alternative title)	c0a937017a690982f48a602405ca1ee2
39664	1681677	US-Hungarian Lifestories: Andras Szekely	\N	3	1995	U2526	\N	\N	\N	\N	5ecfb717a6cf64b183cd55834d25f3cb
22535	1443089	The Visitor	\N	2	1997	V236	\N	\N	\N	(Germany)	7d33468d534b000abb4b6e2f4037fb6a
45452	1700662	Felix the Cat in the Rainbow's End	\N	1	1925	F4232	\N	\N	\N	(USA) (long title)	2ad77fa1e3e018afdd97f3df45a5b618
23151	1497075	Super God Robot Force	\N	2	1984	S1623	\N	\N	\N	\N	c4a859514e7a575e6b04e71db6fd3b29
44185	1695924	Ankunft Dienstag	\N	1	1986	A5251	\N	\N	\N	(West Germany)	6242a663c7a418ce8790de35f1b87ca5
40546	1684546	Eine Familie zum Verlieben	\N	3	1996	F5425	\N	\N	\N	(Germany)	74dac893fc5ea541f54b0837360e08a7
2267	149350	Beyond the break - Vite sull'onda	\N	2	2006	B5316	\N	\N	\N	(Italy)	04de834820d623154b0a4bc12dd36dca
46612	1703784	Auton: Sentinel	\N	4	1998	A3525	\N	\N	\N	(UK) (reissue title)	95c257d2258e8693a3f8ad2b8f6c7d93
34913	1668774	Gegen den Strom	\N	1	2011	G2535	\N	\N	\N	(Germany) (DVD title)	87b11ae6470018ad88180d454b686277
16528	1043463	Prison Break	\N	2	2005	P6251	\N	\N	\N	(Germany)	4f62f99a7f79ca6e52ab194acd5023b9
40038	1682581	Sentimental Love	\N	1	1911	S5353	\N	\N	\N	(UK)	2c3c892dc79e5a5e4e4bdb62fb9eec32
13540	857676	The Melbourne Games	\N	2	1956	M4165	\N	\N	\N	(Australia) (rerun title)	a170d280df787bace2dadc94bf5ba272
33778	1665192	Actrices	\N	1	1997	A2362	\N	\N	\N	(Spain: Castilian title)	da6763387f7730ab7d76e5e475cd0bd3
48048	1707505	Codfish	\N	1	1975	C312	\N	\N	\N	(International: English title) (literal title)	55e0322da89f2be84fdb1f3917b26b34
38124	1676540	Obsédé malgré lui	\N	1	1976	O1235	\N	\N	\N	(France)	59e2ca88ed280d28166da10b9e8a6ab4
48662	1709681	Baghdasar Divorces from His Wife	\N	1	1977	B2326	\N	\N	\N	(International: English title)	3af6ec98b8b801d10a4551a9de66cea6
20643	1280624	L'allegra banda di Nick	\N	2	1972	A4261	\N	\N	\N	(Italy) (imdb display title)	5676fc5e494ce20d428bf745738e227a
41891	1689240	The Unspoken	\N	1	1985	U5212	\N	\N	\N	(India: English title)	ee96b6bc7ade7f992a53423021856078
48263	1708287	La frustata	\N	1	1956	F623	\N	\N	\N	(Italy)	b99cd4883b0c63aef384fc3bef5fab18
4863	323872	De club van Sinterklaas & de streken van Tante Toets	\N	2	2005	C4152	\N	\N	\N	(Netherlands) (sixth season title)	eb37a753c7d832710e10bc8cb72aa93e
12708	818789	The Soupy Sales Show	\N	2	1959	S1242	\N	\N	\N	(USA) (new title)	940f9388aae05a7014a4b7ed921fcc0b
49705	1712147	The Big Bang Theory	\N	1	1995	B2152	\N	\N	\N	(USA) (working title)	9657d3638aac7d03136c5b62519917c1
36002	1670723	Air-Raid: This Is No Drill!	\N	6	2003	A6325	\N	\N	\N	(USA) (video catalogue title)	2375e80d9f2c3fc8d657340cb4bd6bd7
47742	1706558	Babar: le film	\N	1	1989	B1641	\N	\N	\N	(Canada: French title) (video box title)	e2e26040194bca26054c32a345c74f54
34423	1667129	Bis Morgen	\N	1	2011	B2562	\N	\N	\N	(Germany) (festival title)	8a6fcd1af620782335d91020538382c0
33571	1664515	Bitch of Dracula!	\N	1	2011	B3213	\N	\N	\N	(Canada: French title) (informal title)	599a0bfdfd2ee4a7756d935c3b5eac79
45863	1701742	Fixing the Derby Favorite	\N	1	1905	F2523	\N	\N	\N	(USA)	6d12fcb9a4e557335e8bb7aefc10e140
44652	1697691	Schindler's Lift	\N	1	2005	S2534	\N	\N	\N	(International: English title)	ebb01ba7b4098ae7e8905a8a963112c2
22448	1435689	Die Fälle der Rosie O'Neill	\N	2	1990	F4362	\N	\N	\N	(West Germany)	d2ef5518f74cffdcf6abebcb507e5424
35796	1670294	With a Little Help from Myself	\N	1	2008	W3434	\N	\N	\N	(International: English title) (festival title)	939e0f396fa0fa8b3c615b2ce1c640fe
44596	1697505	As Time Goes by: The Making of 'You're a Good Man, Charlie Kane'	\N	1	2002	A2352	\N	\N	\N	(USA) (alternative title)	f7ad665ee63f2964c5605bf72ae49422
24813	1602538	WWE Raw	\N	2	2002	W6	\N	\N	\N	(USA) (new title)	2737faba79db813496d9d437fc63ad92
13248	841333	Mystery Theater	\N	2	1951	M2363	\N	\N	\N	(USA) (alternative title)	0106addf424d3be63562262f95d1c32a
40561	1684676	Dark Night	\N	1	1986	D6252	\N	\N	\N	(International: English title)	bb29cdd6866df08218f1868205d7cd60
12016	778160	The French as Seen by...	\N	2	1988	F6525	\N	\N	\N	(literal English title)	a8d1dac4f6b7726975ba204a90abdbc3
2705	165268	My Father's Hands	\N	7	\N	M1362	2726	1	6	(USA)	b1166668502be97e66ec99014fc97afe
10666	706821	Into the Dawn Skies	\N	7	\N	I5352	10757	1	40	(USA)	229c4c68c53449834c5df96db9c6f42a
21661	1366776	Quasimodo - Der kleine Bucklige und seine großen Abenteuer	\N	2	1996	Q2536	\N	\N	\N	(Germany)	2024921c366ebdf060c84ce9294583a2
19986	1242326	Tao Tao	\N	2	1989	T3	\N	\N	\N	(West Germany)	90f0a3acd4ddfc0bc0e77c451738cc01
36416	1671638	Devil Take This Train to Hell	\N	1	1977	D1432	\N	\N	\N	(International: English title)	b731dfcd648996bcbf73118af7f933df
33161	1663283	The Clemency of Abraham Lincoln	\N	1	1910	C4521	\N	\N	\N	\N	b4cc5135acb6cdff914e9eb70c2fa629
14657	913817	Shadow Star Narutaru	\N	2	2005	S3236	\N	\N	\N	(International: English title) (video title)	b0b93e026cd4bd8f9d626f233649e10c
40185	1682880	Uncle No-Ruz	\N	1	1961	U5245	\N	\N	\N	(International: English title)	fbc9832cee725e076927668e834022cf
34815	1668373	Terremoto a San Francisco	\N	3	1990	T6532	\N	\N	\N	(Italy)	81b4cbf63368f60989641e0c8006f48d
36679	1672120	Beyond the Clouds	\N	1	1996	B5324	\N	\N	\N	(International: English title)	71bbc2d88baddd5d9337b0421038bf04
21335	1338307	Ralph supermaxi eroe	\N	2	1981	R4121	\N	\N	\N	(Italy)	e52db1780f25be01327e20c1a13488ee
35698	1670159	Love Massacre	\N	1	1981	L1526	\N	\N	\N	(International: English title)	43c9d04bb4cb1b0c8a086bb8df05a17f
25681	1633683	Huwag kang lilingon	\N	1	2006	H2524	\N	\N	\N	(Philippines: Tagalog title) (working title)	149179978c43011f6a26f0e049db2a43
18905	1181610	Buschbabies - Im Land der wilden Tiere	\N	2	1992	B2125	\N	\N	\N	(Germany)	67cdc7e8cef22126478c24f13c772882
40246	1683149	Fahr zur Hölle Hollywood	\N	1	1998	F6264	\N	\N	\N	(Germany)	0c19186ffcb7c0486251262717d13bb8
18210	1142061	The Heart of Captain Nemov	\N	2	2009	H6312	\N	\N	\N	(International: English title) (informal English title)	d561ddd56c9068aefc43acb38cc80300
20194	1259734	Tengo todo excepto a ti	\N	2	2008	T5232	\N	\N	\N	(Mexico) (alternative title)	26c1c34bf406c4ce06097ec0a2af5f80
40279	1683248	An American Girl Stands Strong	\N	4	2009	A5625	\N	\N	\N	(UK) (imdb display title)	b70e031aa3ffaf99c7ab522666cf4eb0
25111	1615426	The Hero Yoshihiko and the Key of the Evil Spirit	\N	2	2012	H6253	\N	\N	\N	(International: English title) (imdb display title)	753207d0006b04ab54cb3c8d6b2b7ab0
30556	1652529	Hobart Bosworth in A Man of Peace	\N	1	1928	H1631	\N	\N	\N	(USA) (copyright title)	6a80ed0594be2673214b476735f4b5d7
17373	1091391	Rockos modernes Leben	\N	2	1993	R2536	\N	\N	\N	(Germany)	1881fcf82fd5c8a21943e58226a17a79
41640	1688495	Fear Eats the Soul	\N	1	1974	F6323	\N	\N	\N	\N	42381ae87dedd2f94d591725202e9fd2
18186	1140976	War Correspondent, Hard Struggle!	\N	7	\N	W6262	18199	1	6	(USA)	8366421646aefb3cba93ee549b39ee63
26572	1636360	17 Again - Back to High School	\N	1	2009	A2512	\N	\N	\N	(Germany)	a41907fe0cc22822d0b76c946f440384
34180	1666378	Adoption	\N	1	2009	A3135	\N	\N	\N	(International: English title)	9b0ec323701929e1179f3ec3e4190c8b
23920	1533861	÷ ÐÏÉÓËÁÈ ËÁÐÉÔÁÎÁ çÒÁÎÔÁ	\N	2	1985	\N	\N	\N	\N	(Soviet Union: Russian title) (original Cyrillic KOI8-R title)	b41176d80bd7b6b503a5ae2b2f29bbbc
22006	1398659	Sgt. Bilko	\N	2	2006	S2314	\N	\N	\N	(Australia) (DVD title)	ec9d566710b1dbae42cdd6b7bf5a69ea
34031	1665962	Justice	II	1	1971	J232	\N	\N	\N	(International: English title) (informal literal title)	0e2c003e4ed18716b29dead13d99ce8a
19598	1227289	Strawberry Night	\N	2	2012	S3616	\N	\N	\N	(International: English title) (imdb display title)	870e83a143f1e411031d17449042426c
11430	731039	The School Teacher	\N	2	1993	S2432	\N	\N	\N	(International: English title) (imdb display title)	0e336d90319ccc7bfaf142fc2050365a
39812	1682001	Mátalos y vuelve	\N	1	1969	M3421	\N	\N	\N	(Spain)	9dc6d8f6372f85f993a296169742a7fc
48635	1709571	Wench	\N	1	1949	W52	\N	\N	\N	(USA)	7f748c7ff6f2d138fc84f380c2bedad7
23706	1524394	UnderGRADS	\N	2	2001	U5362	\N	\N	\N	(USA) (promotional title)	6787963e68e9e821187f69f26ef73a6a
4516	293578	The Babylon Project: Crusade	\N	2	1999	B1451	\N	\N	\N	(USA) (working title)	21428db4ccefcb29c517216ad7af75ae
28670	1644023	A Primeira Vez de Carol	\N	4	2006	P6561	\N	\N	\N	(Brazil) (alternative spelling)	b0b79b93b0b5eed8e699688d375d65c9
31801	1658289	Córy szczescia	\N	1	2000	C62	\N	\N	\N	(Poland)	ab775bb0bdc694bf5e183578f4e2e830
46772	1704223	á×ÁÎÔÁÖ	\N	1	1977	\N	\N	\N	\N	(Bulgaria: Bulgarian title) (original Cyrillic KOI8-R title)	bbcf906eafdb1ae46688da56cedd79b7
12201	780403	Venus Junior	\N	7	\N	V5256	12200	1	45	(USA)	4597dcf88810100b6a9e5e01b51296fe
14790	918062	Nazi-Kollaborateure	\N	2	2012	N2416	\N	\N	\N	(Germany) (imdb display title)	107e2cfe3d0e46ced894d1d206646d20
11703	754426	VeggieTales: Larry-Boy & the Angry Eyebrows	\N	2	2002	V2342	\N	\N	\N	(USA) (DVD title)	df4e89017159cc875664c7712b1b5f08
17865	1123778	Satisfaction	\N	2	2006	S3212	\N	\N	\N	(International: English title) (informal title)	b7b85d41686faef69c4301fb58da4dd9
13922	877458	Mo seot kei jyun	\N	2	2005	M2325	\N	\N	\N	(Hong Kong: Cantonese title)	5ad1b527c98361e1bf95a8ff6c090509
15866	997045	Sine novela presents Pasan ko ang daigdig	\N	2	2007	S5141	\N	\N	\N	(Philippines: Tagalog title) (long title)	ab997e0cc49465ad2f31353b7c73a166
45944	1701872	Der Henker von New York	\N	1	1932	H5261	\N	\N	\N	(Austria)	811537ddf2aaed027f795d392cd6c71f
28236	1642894	7 Husbands for Hurmuz	\N	1	2009	H2153	\N	\N	\N	(International: English title)	0a7b185430c68cf488bb327e8118b7fa
39715	1681789	Freunde fürs Leben	\N	1	1958	F6531	\N	\N	\N	(West Germany)	7ee5f0d7210722ed4d7dd56935736fd4
39469	1681117	Happiness	\N	1	2011	H152	\N	\N	\N	(USA) (imdb display title)	df20cd543439de568bdc6da38972fba5
40527	1684495	The Wonderful Baby Incubator	\N	1	1902	W5361	\N	\N	\N	(USA)	7086ae573a21a2f99702504facf4a8aa
5640	371163	Torchwood	\N	2	2005	T623	\N	\N	\N	(UK) (fake working title)	a03c17d49e924bd7ee2bd4b65508e4a9
4470	289078	David Gower's Cricket Monthly	\N	2	1995	D1326	\N	\N	\N	(UK) (complete title)	1b2a71aa6384a4c9acd6137d58d58dae
39770	1681925	Amityville: It's About Time	\N	4	2005	A5314	\N	\N	\N	(USA) (DVD title)	0ee20ca872512ba44f68019245341162
39025	1679335	Hallmark Hall of Fame: Amahl and the Night Visitors (#1.1)	\N	3	1951	H4562	\N	\N	\N	(USA) (anthology series)	79ab13db494e85ae2456335c1de54233
19698	1234541	Super Bikkuriman	\N	2	1992	S1612	\N	\N	\N	(USA) (literal English title)	5f55151aea8f580e9412a0a18c8b2613
2969	182389	L'uomo di Singapore	\N	2	1982	U5325	\N	\N	\N	(Italy) (imdb display title)	d3216db72b9d99649b7142936cc5cae6
31896	1658643	Das dritte Ufer des Flusses	\N	1	1994	D6316	\N	\N	\N	(Germany)	f95c1ed02a8eef5b42a8f5defd29b1ce
42242	1690082	Il silenzio sul mare	\N	1	1992	S4524	\N	\N	\N	(Italy)	044a0de8c3306f0d601218d4f47be09b
9668	656597	Darkness	\N	7	\N	D6252	9667	1	9	(USA) (working title)	69d834b61554c21e7c3b36f5fd692ec8
7877	545943	Gran Hotel	\N	2	2011	G6534	\N	\N	\N	\N	e16db0f970aa6949c52ed85663467ce8
41250	1687419	Olivia's Love	\N	1	2011	O4124	\N	\N	\N	(Philippines: English title) (imdb display title)	8ebf6cb6e9406ccb41f1da65b75a9942
35774	1670224	Oi zok zin	\N	1	2004	Z25	\N	\N	\N	(Hong Kong: Cantonese title)	9c4098b1d7b77e7c14fd89722ed66993
44419	1696753	Stage Struck	\N	1	1932	S3236	\N	\N	\N	(USA) (working title)	8135e92a44957fea3bcc28f7e6bb7ff5
33415	1664152	Im Banne der Eifersucht	\N	1	1951	I5153	\N	\N	\N	(West Germany)	3bff89d33b2780cc16fb81e93e2cb29c
25303	1625433	Sound	\N	2	2002	S53	\N	\N	\N	(International: English title)	3211a7369113d91a2deffa57c54c646e
8913	598568	Hollywood: A Celebration of the American Silent Film	\N	2	1980	H4324	\N	\N	\N	(USA) (video box title)	c90f635c6b65e508a6278cf81520d2f3
30729	1653275	Lonesome Luke, He Loses Out in a Battle for a Fair Jane	\N	1	1915	L5254	\N	\N	\N	(USA) (alternative title)	f16901d59deaf5aab02fa7568a1e4b5d
13218	839664	Burlesque Queen	II	2	2007	B6425	\N	\N	\N	(Philippines: English title) (working title)	3dd7f0c997e3e6ec66d9f9dc993b0192
33292	1663747	Abnormal Check	\N	6	1996	A1565	\N	\N	\N	(International: English title) (imdb display title)	0b5c54e3e4ab33084c963ebb15a386f9
28602	1643845	Die gefahrvolle Wette	\N	1	1918	G1614	\N	\N	\N	(Germany)	5747f482e8f6cecc7e4180ab9914d4fd
7480	509899	Gandang gabi Vice	\N	2	2011	G5352	\N	\N	\N	\N	62c69894e7da0cc7ad59d8b3cdb06ef1
4544	296551	Teodoro e l'invenzione che non va	\N	2	1989	T3645	\N	\N	\N	(Italy)	a9aa6ecdedcb404df106d30038a00687
44597	1697511	Course contre le temps	\N	3	1999	C6253	\N	\N	\N	(Canada: French title)	92fe2c9ad9a23f6fb8b70a383e1863e3
908	59675	Heart and Soul	\N	2	2009	H6353	\N	\N	\N	(Australia)	d01edcee6e14d9c0d3e60fd9d4a4b135
45621	1701162	Atlantic Rendez-vous	\N	3	1989	A3453	\N	\N	\N	(West Germany)	2534875a65a5b969f57f5022c8f78f5d
9451	637001	Night of Flight	\N	7	\N	N2314	9460	1	7	(USA)	30a1852f5339cba97d5bab38ded9ed0d
31815	1658310	The Actress and the Death	\N	1	1995	A2362	\N	\N	\N	\N	837d783b135ebba620e1a1baa3c9fd8d
2066	142023	The White Guard	\N	2	2012	W3263	\N	\N	\N	(International: English title) (informal English title)	61c2dad92716c165cf77df9a58ac5199
13230	839975	Fatal Contamination - Part 1	\N	7	\N	F3425	13235	1	1	(International: English title) (imdb display title)	dde467a087cfc0e967ba82a360412315
9857	676117	Price of Beauty	\N	2	2010	P6213	\N	\N	\N	(USA) (informal short title)	916cc95b1ea5a06f636894f79e0fd879
21523	1356576	The L Word - Wenn Frauen Frauen lieben	\N	2	2004	L6351	\N	\N	\N	(Germany)	2caa43794959ef2464c532f4e07a0a0e
49087	1710579	The Life of a Horsetrader	\N	1	1951	L1623	\N	\N	\N	\N	0f2b14e4b2e79e635cb50cef6446848f
16375	1034864	Pornucopia: Down in the Valley	\N	2	2004	P6521	\N	\N	\N	(USA) (rerun title)	96c99fe7708bdf3a3a149abb0ae8aa7d
22593	1447354	The Wiggles Show	\N	2	2004	W242	\N	\N	\N	(International: English title) (alternative title)	4e13250c68b2730147e0ba6f9c0b01d4
9114	623850	Scott Hunter	\N	2	1977	S2353	\N	\N	\N	(New Zealand: English title)	05ed0a7a31c476ca7357ef4317d2ff41
5536	364317	I-Man - Die Kampfmaschine aus dem All	\N	7	\N	I5325	5591	30	9	(West Germany)	0d1ea97bfc47369da71064067200f14d
27893	1641824	Five Branded Women	\N	1	1960	F1653	\N	\N	\N	(USA) (dubbed version)	cabc1be8abfaef860a4671921191ecaa
25545	1633220	'Halloween' Was Already Taken: A Suburban Fairy-Tale	\N	1	2010	H4524	\N	\N	\N	(USA)	61fbfc826d44c499a0d7c0c829a24d3a
5526	364243	Doppio scambio	\N	7	\N	D1251	5591	31	15	(Italy)	1504ec77b23e6a043e56e5d239b5dd89
27559	1640831	Schuhgröße 36	\N	1	1989	S26	\N	\N	\N	(West Germany) (TV title)	93d2bd1d3af1b6dc69d5cfa9261e4278
22551	1444016	Die Waltons	\N	2	1975	W4352	\N	\N	\N	(West Germany)	7aa4bddda66b1af9accdc24f235034cc
46777	1704233	Before Him All Rome Trembled	\N	1	1947	B1654	\N	\N	\N	(USA)	c95375a7861ea7f165cf8c468079de59
18662	1162017	Six Feet Under - Gestorben wird immer	\N	2	2003	S2135	\N	\N	\N	(Germany)	2199f64717ed1b57a5c3a6dadce6a57d
14623	912564	Old Time Buddy	\N	2	1997	O4351	\N	\N	\N	(International: English title)	18d7f82e14365564fb600cfa3f6ada13
23204	1500168	Trial & Retribution II	\N	2	1998	T6463	\N	\N	\N	(UK) (second season title)	9d923dda92e1747d3ee289176f6a7cbc
3922	249998	Gift	\N	2	2011	G13	\N	\N	\N	(Japan) (working title)	3de4511910e345061ef7d8aab723f888
12450	798675	My Better Half	\N	2	2010	M1364	\N	\N	\N	(Hong Kong: English title)	537f1d800eb260de9ccc5a9f74f6e82c
10484	704399	Mega gegonota	\N	2	1989	M253	\N	\N	\N	(Greece) (alternative title)	d3ad064346d8aeb3922071b1be1c689e
44123	1695729	Guantanamero	\N	1	2007	G5356	\N	\N	\N	(USA)	3a79c65eb6d4dc4647fc4d273750a560
18568	1155360	A Little Princess	\N	2	2009	L3416	\N	\N	\N	(International: English title) (imdb display title)	a57583a638ad0101b5e8643479b1656f
28286	1643021	7 G Brindavan Colony	\N	1	2004	G1653	\N	\N	\N	(India: Telugu title) (dubbed version)	0d1171be8b0cb603f472fbfa11fd3dac
31977	1658863	The Long Ride Home	\N	1	1967	L5263	\N	\N	\N	(UK)	0a959cda16f1400100cd8b1feafeb8b5
18227	1142579	Sesame Street Unpaved	\N	2	1969	S2523	\N	\N	\N	(USA) (syndication title)	9de3cdc5c32b4f0cd9e87b7e405f2e84
19191	1200154	Sekunden entscheiden	\N	2	1969	S2535	\N	\N	\N	(East Germany) (dubbed version)	67282e052b00c08a1b0dc0d54f25be8b
12187	780099	Ein jeglicher wird seinen Lohn empfangen...	\N	2	1985	J2426	\N	\N	\N	(West Germany)	ca7f542cc5c9c774dfc94dce0119813f
15751	987947	A Town Called Panic	\N	2	2000	T5243	\N	\N	\N	(International: English title)	cf6362d49de1f1fcb4ce28cf2bfdf9c2
20883	1308597	Eddies Vater	\N	2	1969	E3213	\N	\N	\N	(West Germany)	1fa8c87eb57e195e158fa3626500b075
3954	252569	The $7000 Question	\N	2	1971	Q235	\N	\N	\N	(Australia) (last season title)	85ad2b05df8fa359ae17dc698c64da14
9966	683441	The Adventures of Jonny Quest	\N	2	1964	A3153	\N	\N	\N	\N	e57fa9eae789aaf2eda469a1a91a1726
33279	1663694	Der Zögling des Emirs	\N	1	1975	Z2452	\N	\N	\N	(East Germany) (first part title)	678a5fa5405be2d5c114aae2e4c71f29
18453	1149817	Both of You, Dance Like You Want to Win!	\N	7	\N	B3135	18456	1	9	(USA)	ec288b53baa4b76ddb4c844fa4694586
12885	828684	Magnum P.I.	\N	2	1980	M251	\N	\N	\N	(Italy)	a3aee55a0c977f40cb61336198a9ecd0
9322	635387	Inspector Montalbano	\N	2	1999	I5212	\N	\N	\N	(Australia) (imdb display title)	c724036f663ff6c67ae6109b3f33e7d6
21981	1397572	Next	\N	2	2010	N23	\N	\N	\N	(USA) (working title)	a21093cfa5ddc958cb15c9d51c843567
13271	842963	Martial Law - Der Karate-Cop	\N	2	1999	M6343	\N	\N	\N	(Germany)	89017740aca98858f1286b24c025fb3f
19805	1237563	Treasure Island	\N	2	1978	T6262	\N	\N	\N	(International: English title)	b013cda53382efd9b5653fb3fe00c4bb
20403	1269851	Die Addams Family	\N	2	1964	A3521	\N	\N	\N	(West Germany)	4c90cc833a4e9aee3e4880e591494952
20809	1299477	Showcase	\N	2	1950	S2	\N	\N	\N	(UK) (new title)	b96ebde92148bb8c73f7b2ed77d6c79a
46207	1702497	Zieh weiter, Pony	\N	1	1960	Z3615	\N	\N	\N	(West Germany)	037cff96072368d44b502393b1a50233
21955	1395648	Der Einzelgänger	\N	2	1970	E5242	\N	\N	\N	(West Germany)	e3f865d5ead8e5db3c18fcff9c43acf2
10230	697010	Forest of Indecision	\N	7	\N	F6231	10231	1	20	(Japan) (literal English title)	321bae827fba68215131580cd432e1b8
3769	234824	Chôjû sentai Liveman	\N	2	1988	C2534	\N	\N	\N	\N	97e75604530827740e235408763d563f
32653	1661717	Eels	\N	1	2006	E42	\N	\N	\N	(International: English title)	33579ff27d622c004e75f103fa1a9a29
30621	1652804	The Wilmar 8	\N	3	1984	W456	\N	\N	\N	(USA) (working title)	49a048df23dc2dc0d53a7a3409b8ae84
9583	649223	Life Is Beautiful	\N	2	2010	L1213	\N	\N	\N	(South Korea) (imdb display title)	62d4368a8361b360a5e5c6d382677270
21340	1338391	The Greatest	\N	2	1998	G6323	\N	\N	\N	\N	8451d69c2602444d7433244be7bb9710
18834	1174994	The Soloists	\N	2	2003	S4232	\N	\N	\N	(International: English title)	2e5530ec06b4f94b56d189fea382eae0
43014	1692231	Our House	\N	1	1989	O62	\N	\N	\N	(International: English title)	bc1cd49f914df8bd1513ac75794c8fcd
24056	1547064	$1,000,000 Video Challenge	\N	2	1990	V3245	\N	\N	\N	\N	c7decdc5922e8981517de0afee1dd2d7
47450	1706087	Byi Rappu Bôizu	\N	6	1992	B612	\N	\N	\N	(Japan) (imdb display title)	6ba994fcbf316c0daccefe8b34d18483
18	826	Teatre català amb Manel Fuentes	\N	2	2004	T3623	\N	\N	\N	(Spain: Catalan title) (working title)	d6c2e709a94bd21d86c0f857fa41be8f
574	42082	Dan Cruickshank's Adventures in Architecture	\N	2	2008	D5262	\N	\N	\N	(Australia)	50f940836bd3ab81e869ac6a662b92b8
19656	1234377	Soul Eater: Repeat Show	\N	2	2010	S4361	\N	\N	\N	(Japan) (rerun title)	3dce88d5d602fa5b463db42cea3746d4
12180	780010	Die Kinder der Shadoks	\N	2	2007	K5363	\N	\N	\N	(Germany) (DVD title)	4850e4a49dbe6da3b03b76722884ca23
4582	298507	The Legend of Custer	\N	2	1967	L2531	\N	\N	\N	(USA) (theatrical title)	aae96bee867bd28dd01294b62fedca23
17227	1085779	Children of the Kingdom	\N	2	2003	C4365	\N	\N	\N	(International: English title)	a371ea3446847e3a762143adf37dfa01
315	22363	Hoppus on Music	\N	2	2010	H1252	\N	\N	\N	(International: English title) (second season title)	754652551f9ab28ce20e0c0285398317
34795	1668221	After Sex - Dopo il sesso	\N	1	2009	A1362	\N	\N	\N	(Italy)	9b112b898e17b8a36d6d7182449546ac
22420	1427528	Time Tunnel	\N	2	1971	T5354	\N	\N	\N	(West Germany)	fdf646871d7f96833c7fabca97aaa0e0
20245	1260214	The Day the Angel Flew	\N	7	\N	D3524	20256	1	8	(USA)	627177a70ae823c9f5a2b9afa4c03b72
49942	1712731	Bo fung ngaan	\N	1	1994	B1525	\N	\N	\N	(Hong Kong: Cantonese title)	082e08fc0afe49dbf46a5a4897ec2a33
\.


--
-- Data for Name: cast_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cast_info (id, person_id, movie_id, person_role_id, note, nr_order, role_id) FROM stdin;
1	1	968504	1	\N	\N	1
2	2	2163857	1	\N	25	1
3	2	2324528	2	\N	22	1
4	3	1851347	\N	\N	12	1
5	4	1681365	3	\N	\N	1
6	4	1717509	1	\N	\N	1
7	4	1911008	1	\N	\N	1
8	4	1915368	1	\N	1	1
9	4	1916360	\N	\N	\N	1
10	4	1916727	1	\N	\N	1
11	4	1950697	1	\N	\N	1
12	4	2113260	4	\N	27	1
13	4	2203212	1	\N	\N	1
14	4	2205557	\N	\N	\N	1
15	4	2211587	5	(voice)	3	1
16	4	2242727	1	\N	\N	1
17	4	2265131	6	(as Too Short)	\N	1
18	4	2436165	\N	\N	\N	1
19	4	2445520	1	\N	\N	1
20	4	2469958	1	\N	\N	1
21	4	2492847	\N	\N	\N	1
22	4	3494	7	\N	\N	1
23	4	2525604	1	(rumored)	\N	1
24	4	73065	1	(as Too Short)	\N	1
25	4	79577	1	(archive footage)	\N	1
26	4	218742	1	\N	\N	1
27	4	285444	1	\N	\N	1
28	4	285446	1	\N	\N	1
29	4	285447	1	\N	\N	1
30	4	285448	1	\N	\N	1
31	4	285450	1	\N	\N	1
32	4	285453	1	\N	\N	1
33	4	285454	1	\N	\N	1
34	4	285455	1	\N	\N	1
35	4	285457	1	\N	\N	1
36	4	285459	1	\N	\N	1
37	4	405004	1	\N	\N	1
38	4	703692	1	\N	\N	1
39	4	703707	1	\N	\N	1
40	4	703713	1	(archive footage)	\N	1
41	4	703715	8	\N	\N	1
42	4	763840	9	\N	\N	1
43	4	874262	10	\N	13	1
44	4	1205916	3	\N	\N	1
45	4	1333296	1	\N	\N	1
46	4	1379117	1	\N	\N	1
47	4	1483769	1	\N	\N	1
48	4	1547201	1	(archive footage)	\N	1
49	5	1898037	11	\N	\N	1
50	5	2153771	12	\N	\N	1
51	5	880737	13	\N	\N	1
52	5	880744	13	\N	\N	1
53	6	2116962	14	\N	\N	1
54	7	1175445	14	\N	\N	1
55	8	470449	14	\N	\N	1
56	9	2284724	15	\N	\N	1
57	9	2337125	14	\N	\N	1
58	9	425178	14	\N	\N	1
59	9	1510049	14	\N	\N	1
60	10	129191	16	\N	8	1
61	11	1089225	1	\N	\N	1
62	12	427978	14	\N	\N	1
63	13	2284724	15	\N	\N	1
64	13	2337124	14	\N	\N	1
65	13	425179	14	\N	\N	1
66	14	2372249	1	\N	\N	1
67	15	2123866	17	\N	\N	1
68	15	2247745	18	\N	\N	1
69	15	2485258	19	\N	\N	1
70	15	641492	1	(as Michael 'Power' Viera)	\N	1
71	15	1229836	20	\N	\N	1
72	15	1366546	21	\N	\N	1
73	15	1366546	22	\N	\N	1
74	16	2407255	23	(uncredited)	\N	1
75	17	1710174	24	\N	28	1
76	18	2139838	25	\N	16	1
77	18	2139838	26	\N	16	1
78	19	1706485	27	(as Buguelo)	\N	1
79	19	1778572	28	\N	7	1
80	19	2251755	1	\N	\N	1
81	19	2458232	27	\N	\N	1
82	20	2492015	1	\N	\N	1
83	21	2146073	29	\N	\N	1
84	22	1715956	30	\N	\N	1
85	22	2389519	31	\N	\N	1
86	23	2522753	32	\N	20	1
87	24	490285	33	\N	\N	1
88	25	1680193	\N	\N	\N	1
89	26	2492015	1	\N	\N	1
90	27	1793157	\N	\N	1	1
91	27	2430754	\N	\N	2	1
92	28	2389519	34	\N	\N	1
93	29	1643709	14	\N	\N	1
94	30	2041550	1	\N	\N	1
95	31	1677442	\N	\N	45	1
96	31	1810457	1	\N	\N	1
97	31	1887948	1	\N	\N	1
98	31	1909439	1	\N	\N	1
99	31	1909455	1	\N	\N	1
100	31	1909457	1	\N	\N	1
101	31	2037694	1	\N	\N	1
102	31	2122020	1	\N	\N	1
103	31	2166474	1	\N	\N	1
104	31	2215679	1	\N	\N	1
105	31	2250583	1	\N	\N	1
106	31	2275728	1	\N	\N	1
107	31	2475885	1	\N	\N	1
108	31	27201	1	\N	\N	1
109	31	50848	1	\N	\N	1
110	31	263084	1	\N	\N	1
111	31	503695	1	\N	\N	1
112	31	908611	1	\N	\N	1
113	31	908617	1	\N	\N	1
114	31	908787	1	\N	\N	1
115	31	908798	1	\N	\N	1
116	31	947035	1	\N	\N	1
117	31	975981	1	\N	\N	1
118	31	997878	1	\N	\N	1
119	31	997879	1	\N	\N	1
120	31	997880	1	\N	\N	1
121	31	998087	1	\N	\N	1
122	31	998088	1	\N	\N	1
123	31	998089	1	\N	\N	1
124	31	1111317	1	\N	\N	1
125	31	1112121	1	\N	\N	1
126	31	1484917	1	\N	\N	1
127	31	1501299	1	\N	\N	1
128	32	1817079	\N	\N	12	1
129	33	1873429	1	\N	\N	1
130	33	2044434	1	\N	\N	1
131	33	2133822	1	\N	\N	1
132	33	2196377	35	\N	12	1
133	33	75814	1	\N	\N	1
134	33	239900	1	\N	\N	1
135	33	410037	1	\N	\N	1
136	33	449666	\N	\N	\N	1
137	33	449668	1	\N	\N	1
138	33	449670	1	\N	\N	1
139	33	449672	1	\N	\N	1
140	33	449673	1	\N	\N	1
141	33	449674	1	\N	\N	1
142	33	449675	1	\N	\N	1
143	33	449676	1	\N	\N	1
144	33	449677	1	\N	\N	1
145	33	449678	1	\N	\N	1
146	33	449679	1	\N	\N	1
147	33	449680	1	\N	\N	1
148	33	449681	1	\N	\N	1
149	33	449682	1	\N	\N	1
150	33	449683	1	\N	\N	1
151	33	449684	1	\N	\N	1
152	33	449685	1	\N	\N	1
153	33	449702	1	\N	\N	1
154	33	449706	1	\N	\N	1
155	33	623227	1	\N	\N	1
156	33	623235	1	\N	\N	1
157	33	623239	1	\N	\N	1
158	33	623240	1	\N	\N	1
159	33	623242	1	\N	\N	1
160	33	946279	1	\N	\N	1
161	33	946287	1	\N	\N	1
162	33	946288	1	\N	\N	1
163	33	946307	1	\N	\N	1
164	33	946313	1	\N	\N	1
165	33	946337	1	\N	\N	1
166	33	946361	1	\N	\N	1
167	33	946379	1	\N	\N	1
168	33	946393	1	\N	\N	1
169	33	946394	1	\N	\N	1
170	33	946402	\N	\N	\N	1
171	33	946405	\N	\N	\N	1
172	33	1057152	\N	\N	\N	1
173	33	1057159	\N	\N	\N	1
174	33	1057160	\N	\N	\N	1
175	33	1057162	\N	\N	\N	1
176	33	1057163	\N	\N	\N	1
177	33	1057164	\N	\N	\N	1
178	33	1057165	\N	\N	\N	1
179	33	1057167	\N	\N	\N	1
180	33	1057168	\N	\N	\N	1
181	33	1057171	\N	\N	\N	1
182	33	1057173	\N	\N	\N	1
183	33	1158701	1	\N	\N	1
184	33	1178939	1	\N	\N	1
185	33	1178940	1	\N	\N	1
186	33	1526500	36	\N	3	1
187	33	1526502	36	\N	3	1
188	33	1526503	36	\N	3	1
189	33	1526505	36	\N	3	1
190	33	1526506	36	\N	3	1
191	33	1526507	36	\N	3	1
192	33	1526508	36	\N	3	1
193	33	1526509	36	\N	3	1
194	33	1526510	36	\N	3	1
195	33	1526511	36	\N	3	1
196	33	1526512	36	\N	3	1
197	33	1526513	36	\N	3	1
198	33	1536916	1	\N	\N	1
199	33	1549244	\N	\N	\N	1
200	33	1628439	1	\N	\N	1
201	34	2084184	37	\N	25	1
202	35	739703	1	\N	\N	1
203	36	1870218	\N	\N	10	1
204	37	2443980	38	\N	24	1
205	38	2082871	39	\N	\N	1
206	39	1809667	40	\N	83	1
207	40	2082871	41	\N	\N	1
208	41	1809667	42	\N	80	1
209	42	2038305	\N	\N	22	1
210	43	2082871	43	\N	\N	1
211	44	2178515	44	\N	20	1
212	45	2084184	45	\N	20	1
213	46	2353120	46	\N	\N	1
214	47	2492015	1	\N	\N	1
215	48	2177983	1	\N	\N	1
216	49	637443	47	\N	\N	1
217	50	2096029	48	\N	21	1
218	51	1876535	49	\N	1	1
219	52	1635385	50	\N	12	1
220	53	2492015	1	\N	\N	1
221	54	1778572	51	\N	\N	1
222	55	1947292	52	\N	\N	1
223	56	1695493	1	\N	\N	1
224	56	1718704	1	\N	\N	1
225	56	1969820	1	\N	47	1
226	56	1992326	53	\N	\N	1
227	56	2326246	1	(archive footage)	\N	1
228	56	2341336	54	\N	22	1
229	56	2348128	1	\N	\N	1
230	56	2348150	55	\N	\N	1
231	56	2361067	1	\N	\N	1
232	56	2361067	56	\N	\N	1
233	56	2494796	1	\N	9	1
234	56	59872	1	\N	\N	1
235	56	59875	1	\N	\N	1
236	56	119997	57	\N	\N	1
237	56	126850	1	\N	\N	1
238	56	159746	1	(archive footage)	\N	1
239	56	277645	58	\N	11	1
240	56	1280986	1	(archive footage) (uncredited)	\N	1
241	56	1460036	1	\N	\N	1
242	57	2480163	59	\N	21	1
243	58	1847059	\N	\N	\N	1
244	59	1839893	60	\N	\N	1
245	59	2161249	61	\N	35	1
246	59	2318870	62	\N	9	1
247	59	2373358	63	(as Johnny Starks)	18	1
248	59	2470892	64	\N	10	1
249	60	1754818	\N	\N	11	1
250	60	2480152	65	\N	4	1
251	61	2234872	66	\N	4	1
252	61	110473	67	\N	2	1
253	62	1994466	1	\N	68	1
254	63	1188454	53	\N	3	1
255	64	413916	1	\N	\N	1
256	65	2158999	\N	\N	\N	1
257	66	1778572	51	\N	\N	1
258	67	1007963	68	\N	\N	1
259	68	1934418	69	(as Monkey)	15	1
260	69	2084184	45	(as 'Morità')	18	1
261	70	1650884	1	\N	\N	1
262	71	2365753	70	\N	\N	1
263	72	312780	1	\N	\N	1
264	72	358023	1	(as Mark'Oh)	\N	1
265	73	416861	1	\N	\N	1
266	74	1925456	71	\N	2	1
267	75	2084184	72	\N	14	1
268	76	2237110	73	\N	57	1
269	77	2039620	\N	\N	\N	1
270	78	1922641	1	(uncredited)	\N	1
271	79	2318788	74	\N	\N	1
272	80	693547	\N	\N	\N	1
273	81	2492015	1	\N	\N	1
274	82	2312496	75	\N	\N	1
275	83	2359325	76	\N	\N	1
276	84	2492015	1	\N	\N	1
277	85	1891604	77	(as the 'Stretch' Cox Troupe)	20	1
278	86	1742292	1	\N	3	1
279	86	324234	\N	\N	\N	1
280	86	327297	1	\N	3	1
281	86	327577	1	\N	3	1
282	86	327820	1	\N	3	1
283	86	327982	78	\N	3	1
284	86	328022	1	(also archive footage)	\N	1
285	86	328393	1	\N	\N	1
286	86	1004295	1	\N	5	1
287	86	1004452	1	\N	4	1
288	86	1004726	1	\N	6	1
289	86	1004977	78	\N	4	1
290	86	1623168	1	\N	2	1
291	87	582630	79	\N	5	1
292	88	2521100	80	\N	2	1
293	89	1809359	81	\N	\N	1
294	89	1810706	82	\N	29	1
295	89	1841776	83	\N	15	1
296	89	1917454	84	\N	6	1
297	89	2445789	85	\N	6	1
298	89	324682	86	\N	\N	1
299	89	327185	87	\N	\N	1
300	89	1129544	88	\N	\N	1
301	90	974711	89	(1993)	\N	1
302	90	982601	90	\N	\N	1
303	91	533737	91	\N	\N	1
304	91	976657	92	\N	\N	1
305	92	2128470	93	(as Drs. Dick 't Hooft)	46	1
306	93	217245	1	\N	1	1
307	93	328494	94	(segment "De Jakhalzen")	\N	1
308	93	1005272	95	\N	5	1
309	94	929128	96	(as Maarten t'Hooft)	15	1
310	95	929128	96	(as Quinten t'Hooft)	14	1
311	96	170288	97	\N	\N	1
312	96	583072	\N	\N	\N	1
313	96	883387	98	\N	11	1
314	96	1137974	99	\N	23	1
315	97	1994103	100	\N	1	1
316	98	535571	1	(voice)	\N	1
317	99	324006	101	\N	14	1
318	100	2458642	102	\N	21	1
319	101	1787465	103	\N	\N	1
320	102	2455898	1	\N	15	1
321	103	2492015	1	\N	\N	1
322	104	1967518	104	\N	\N	1
323	105	2133612	14	\N	\N	1
324	105	2133613	14	\N	\N	1
325	105	659902	14	\N	\N	1
326	105	1174900	14	\N	\N	1
327	106	2065996	105	\N	17	1
328	107	2130945	106	\N	\N	1
329	108	2196227	\N	\N	\N	1
330	109	2447271	107	(uncredited)	\N	1
331	110	1477226	108	\N	\N	1
332	110	1477226	109	\N	\N	1
333	111	251773	110	\N	\N	1
334	112	2291578	1	\N	\N	1
335	113	1633369	\N	\N	\N	1
336	113	1635318	14	(archive footage)	\N	1
337	113	1637619	14	\N	\N	1
338	113	1638384	14	\N	39	1
339	113	1680770	14	\N	\N	1
340	113	1748946	14	\N	\N	1
341	113	2034748	111	\N	\N	1
342	113	2093311	14	\N	\N	1
343	113	2133583	15	\N	\N	1
344	113	2133625	15	\N	5	1
345	113	2133626	14	\N	\N	1
346	113	2151497	15	\N	\N	1
347	113	2152918	14	\N	\N	1
348	113	2296442	112	(archive footage) (uncredited)	\N	1
349	113	2320637	14	\N	\N	1
350	113	2322050	113	\N	\N	1
351	113	2322051	14	\N	\N	1
352	113	2341815	14	\N	\N	1
353	113	2341821	14	\N	\N	1
354	113	2341876	14	\N	\N	1
355	113	2342065	14	\N	\N	1
356	113	2342082	14	\N	\N	1
357	113	2342094	15	\N	\N	1
358	113	2342099	14	\N	\N	1
359	113	2342105	15	\N	\N	1
360	113	2342109	14	\N	\N	1
361	113	2342358	14	\N	26	1
362	113	2342700	15	\N	\N	1
363	113	2418777	114	\N	\N	1
364	113	2486995	\N	\N	\N	1
365	113	140774	14	(archive footage)	\N	1
366	113	832963	\N	\N	\N	1
367	113	832964	\N	\N	\N	1
368	113	833045	\N	\N	\N	1
369	113	1090714	15	\N	1	1
370	113	1124788	115	\N	\N	1
371	113	1411369	14	\N	\N	1
372	113	1411424	14	\N	\N	1
373	113	1411513	14	\N	\N	1
374	113	1411564	14	\N	\N	1
375	113	1411579	14	\N	\N	1
376	113	1411690	14	\N	\N	1
377	113	1411825	14	\N	\N	1
378	113	1411881	14	\N	\N	1
379	113	1411972	14	\N	\N	1
380	113	1433824	115	\N	\N	1
381	113	1433854	115	\N	\N	1
382	113	1434341	115	\N	\N	1
383	113	1434376	14	\N	\N	1
384	113	1434415	115	\N	\N	1
385	113	1434466	115	\N	\N	1
386	113	1495876	115	\N	\N	1
387	113	1547179	116	(archive footage)	\N	1
388	113	1547189	116	(archive footage)	\N	1
389	113	1547190	14	(segment "It's Gonna Be Me")	\N	1
390	113	1547271	116	(archive footage)	\N	1
391	114	1983880	117	\N	\N	1
392	115	1639459	\N	\N	\N	1
393	116	2412725	\N	\N	\N	1
394	117	2015081	118	\N	\N	1
395	118	1790480	\N	\N	\N	1
396	119	2255212	119	\N	\N	1
397	120	2497483	\N	\N	\N	1
398	121	2197101	120	\N	\N	1
399	122	2131811	\N	\N	\N	1
400	123	1728141	121	\N	16	1
401	124	2092646	\N	\N	\N	1
402	125	1736900	\N	\N	\N	1
403	126	2433317	122	\N	\N	1
404	127	1728616	123	\N	\N	1
405	127	2080765	124	\N	\N	1
406	127	2252790	125	\N	\N	1
407	128	715071	126	\N	8	1
408	129	2228122	127	\N	\N	1
409	130	2419421	128	\N	\N	1
410	131	2095484	129	\N	7	1
411	132	1666658	130	\N	\N	1
412	132	2235457	131	\N	\N	1
413	132	2413557	132	\N	\N	1
414	133	2228122	133	\N	\N	1
415	134	2371068	\N	\N	\N	1
416	135	1708931	134	\N	\N	1
417	136	2419421	135	\N	\N	1
418	137	2350778	136	\N	\N	1
419	138	1758488	\N	\N	\N	1
420	139	2257011	\N	\N	\N	1
421	140	2419421	137	\N	\N	1
422	141	2503767	138	\N	\N	1
423	142	2251237	139	\N	\N	1
424	143	2449437	\N	\N	\N	1
425	144	2449437	140	\N	\N	1
426	145	2110618	141	\N	\N	1
427	146	1969569	1	\N	\N	1
428	146	1991389	142	\N	\N	1
429	147	1790851	1	\N	\N	1
430	148	2449437	143	\N	\N	1
431	149	2251237	144	\N	\N	1
432	150	2371797	145	\N	\N	1
433	151	2405514	146	\N	22	1
434	152	2449437	\N	\N	\N	1
435	153	1681471	\N	\N	\N	1
436	154	2426327	\N	\N	\N	1
437	155	1865075	\N	\N	\N	1
438	156	1358396	115	\N	\N	1
439	157	1640925	14	\N	\N	1
440	157	1780361	14	\N	\N	1
441	157	2175624	1	(voice)	\N	1
442	157	248417	1	\N	\N	1
443	157	248568	14	\N	\N	1
444	157	1544620	14	\N	\N	1
445	158	2147574	\N	\N	\N	1
446	159	2214104	\N	\N	\N	1
447	160	129270	16	\N	7	1
448	160	766799	14	\N	\N	1
449	161	1659222	1	(segment "Scenario")	\N	1
450	161	2499204	147	(as Todd-1)	10	1
451	161	117010	\N	\N	\N	1
452	161	462055	\N	\N	\N	1
453	161	1544693	1	\N	\N	1
454	161	1609353	1	\N	\N	1
455	162	714497	14	\N	15	1
456	163	1947534	14	(as 1. Wiener Pawlatschen AG)	7	1
457	164	1785548	1	\N	\N	1
458	164	1859667	1	\N	\N	1
459	164	1873429	1	\N	\N	1
460	164	623228	1	\N	\N	1
461	164	623236	1	\N	\N	1
462	164	623240	1	\N	\N	1
463	164	946238	1	\N	\N	1
464	164	946242	1	\N	\N	1
465	164	946243	1	\N	\N	1
466	164	946248	1	\N	\N	1
467	164	946249	1	\N	\N	1
468	164	946251	1	\N	\N	1
469	164	946252	1	\N	\N	1
470	164	946258	1	\N	\N	1
471	164	946260	1	\N	\N	1
472	164	946263	1	\N	\N	1
473	164	946266	1	\N	\N	1
474	164	946267	1	\N	\N	1
475	164	946274	1	\N	\N	1
476	164	946280	1	\N	\N	1
477	164	946282	1	\N	\N	1
478	164	946300	1	\N	\N	1
479	164	946306	1	\N	\N	1
480	164	946314	1	\N	\N	1
481	164	946420	1	\N	\N	1
482	164	946434	1	\N	\N	1
483	164	946435	1	\N	\N	1
484	164	946436	1	\N	\N	1
485	164	946439	\N	\N	\N	1
486	164	947028	1	\N	\N	1
487	164	947030	1	\N	\N	1
488	164	947035	1	\N	\N	1
489	164	1086631	1	\N	\N	1
490	164	1086632	1	\N	\N	1
491	164	1086633	1	\N	\N	1
492	164	1086634	1	\N	\N	1
493	164	1086635	1	\N	\N	1
494	164	1086636	1	\N	\N	1
495	164	1086637	1	\N	\N	1
496	164	1086639	1	\N	\N	1
497	164	1086640	1	\N	\N	1
498	165	2086617	1	\N	\N	1
499	165	3537	148	\N	\N	1
500	166	1112773	14	\N	10	1
501	166	1124496	115	\N	\N	1
502	166	1124792	115	\N	\N	1
503	166	1430189	14	\N	\N	1
504	166	1432749	14	\N	\N	1
505	166	1448891	14	\N	\N	1
506	166	1590140	15	\N	\N	1
507	167	129349	16	\N	7	1
508	168	1182311	2	\N	\N	1
509	169	1499834	14	\N	87	1
510	170	1630675	1	\N	\N	1
511	171	1789579	1	\N	5	1
512	172	2074045	149	\N	4	1
513	173	2232643	150	\N	\N	1
514	174	1703421	\N	\N	\N	1
515	175	1643417	14	\N	\N	1
516	175	2317745	14	(archive footage)	\N	1
517	175	13211	14	\N	\N	1
518	175	157962	115	\N	\N	1
519	175	1090464	14	\N	\N	1
520	175	1090509	14	\N	\N	1
521	175	1488287	14	(archive footage)	\N	1
522	175	1488896	14	\N	\N	1
523	175	1488933	151	\N	12	1
524	175	1488954	14	\N	16	1
525	175	1488967	14	(archive footage)	10	1
526	175	1489005	14	(archive footage)	3	1
527	175	1489007	14	(archive footage)	4	1
528	175	1489021	14	(archive footage)	4	1
529	175	1489023	14	(archive footage)	8	1
530	176	316657	152	\N	29	1
531	177	1726593	153	\N	2	1
532	177	2407379	154	\N	\N	1
533	177	2422533	155	\N	1	1
534	177	2514631	63	\N	\N	1
535	177	2521247	156	\N	87	1
536	178	1635636	14	\N	1	1
537	179	2278672	1	\N	\N	1
538	180	1825375	14	\N	\N	1
539	180	1864161	\N	\N	\N	1
540	180	2025845	14	\N	9	1
541	181	1499834	14	\N	89	1
542	182	1667564	1	\N	\N	1
543	182	1984782	157	\N	89	1
544	182	2078342	158	(voice)	1	1
545	182	2105481	159	(as Nick Jones)	\N	1
546	183	2491143	1	\N	\N	1
547	184	352400	14	\N	\N	1
548	185	2501172	14	\N	11	1
549	186	1656885	160	(archive footage)	35	1
550	186	1865342	14	\N	29	1
551	186	1124440	14	(uncredited)	\N	1
552	186	1124982	115	\N	\N	1
553	186	1142676	161	(voice)	\N	1
554	186	1142703	161	(voice) (archive footage)	\N	1
555	186	1142705	14	\N	\N	1
556	186	1142786	14	(archive footage)	\N	1
557	187	1452321	162	\N	48	1
558	187	1452322	163	\N	\N	1
559	187	1452323	163	\N	\N	1
560	187	1452325	162	\N	28	1
561	187	1452326	163	(archive footage)	16	1
562	187	1452338	163	\N	\N	1
563	187	1452340	163	\N	\N	1
564	187	1452351	14	\N	\N	1
565	187	1452353	14	(uncredited)	\N	1
566	187	1452355	163	\N	\N	1
567	187	1452356	163	\N	\N	1
568	188	1272760	164	\N	\N	1
569	189	128989	16	\N	7	1
570	190	129296	16	\N	8	1
571	191	1934298	165	(uncredited)	\N	1
572	191	1973231	\N	\N	10	1
573	191	2497617	166	\N	23	1
574	191	12373	14	\N	1	1
575	191	314420	14	\N	\N	1
576	191	1620698	14	\N	\N	1
577	192	1798810	\N	(archive footage) (as Lord Lovat)	\N	1
578	192	1460634	1	(as Lord Lovat)	\N	1
579	192	1534100	1	\N	\N	1
580	193	745253	115	\N	\N	1
581	194	1754423	167	\N	11	1
582	195	2240482	168	\N	\N	1
583	196	1643341	169	\N	\N	1
584	197	1477280	14	\N	\N	1
585	198	1343393	14	\N	\N	1
586	199	1343361	170	\N	\N	1
587	200	2238737	171	\N	\N	1
588	201	761902	115	\N	\N	1
589	202	1721673	172	\N	\N	1
590	203	1935213	14	\N	\N	1
591	204	1935213	14	\N	\N	1
592	205	2092149	173	\N	58	1
593	206	786392	174	\N	\N	1
594	207	1648326	1	\N	\N	1
595	207	1681391	1	\N	\N	1
596	207	1708531	1	(voice)	19	1
597	207	1727627	175	\N	2	1
598	207	1727628	176	\N	2	1
599	207	1741701	1	\N	\N	1
600	207	1742806	177	\N	2	1
601	207	1812845	1	(archive footage)	7	1
602	207	1812940	178	\N	2	1
603	207	1853027	1	\N	\N	1
604	207	1939600	1	(archive footage)	2	1
605	207	1985363	1	\N	2	1
606	207	1997420	1	\N	\N	1
607	207	2005484	1	(voice)	\N	1
608	207	2005484	179	(voice)	\N	1
609	207	2005485	1	(as Shaggy 2 Dope of Insane Clown Posse)	\N	1
610	207	2005486	1	(voice)	\N	1
611	207	2005486	179	(voice)	\N	1
612	207	2222077	1	(segments "Homies" - "Tilt A Whirl" - "We don't die" - "Halls of Illusions" - "Chicken Huntin" - "Another love song" - "How many times?" - "Bowling balls" - "The people" - "Piggy pie" - "Hokus pokus" - "Let"s go all the way" - "Real underground baby")/Full Clip (segments "Duk da fuk down" - "Real underground baby")/Guy Gorfey (segment "Raw deal")/Sugar Bear (segment "Real underground baby")	2	1
613	207	2246298	1	(archive footage)	\N	1
614	207	2283575	1	\N	\N	1
615	207	2320807	1	\N	\N	1
616	207	2356333	1	\N	\N	1
617	207	2377873	1	\N	\N	1
618	207	2405067	1	\N	\N	1
619	207	2408201	1	(archive footage)	\N	1
620	207	2473541	1	(archive footage)	67	1
621	207	2473542	1	(as Shaggy 2 Dope of Insane Clown Posse)	\N	1
622	207	2489931	1	\N	\N	1
623	207	2489941	1	\N	\N	1
624	207	2508124	1	(archive footage)	\N	1
625	207	93657	1	\N	\N	1
626	207	112020	9	\N	\N	1
627	207	140774	1	\N	\N	1
628	207	500995	1	\N	\N	1
629	207	619405	1	(archive footage)	\N	1
630	207	619681	\N	\N	\N	1
631	207	619683	1	\N	\N	1
632	207	620747	1	\N	\N	1
633	207	620748	1	\N	\N	1
634	207	620924	1	\N	\N	1
635	207	621338	1	\N	\N	1
636	207	621445	1	\N	\N	1
637	207	827476	1	(as Insane Clown Posse)	\N	1
638	207	897612	1	(as Insane Clown Posse)	\N	1
639	207	954346	1	\N	\N	1
640	207	1052678	1	\N	\N	1
641	207	1214256	1	(1998-1999)	\N	1
642	207	1267877	1	\N	\N	1
643	207	1346286	1	\N	\N	1
644	207	1346307	1	\N	\N	1
645	207	1346331	1	\N	\N	1
646	207	1391853	180	\N	\N	1
647	207	1565929	1	\N	\N	1
648	207	1565933	1	\N	\N	1
649	207	1565992	1	\N	\N	1
650	207	1566106	1	(1998-1999)	\N	1
651	207	1597385	1	(1998-1999)	\N	1
652	207	1597797	1	\N	\N	1
653	207	1600167	1	(1998-1999)	\N	1
654	207	1602538	1	(1997)	\N	1
655	208	1638903	181	\N	\N	1
656	208	1648326	14	\N	\N	1
657	208	2133614	15	\N	\N	1
658	208	2222077	14	(segment "Real underground baby")	\N	1
659	208	2232305	182	\N	1	1
660	208	79577	14	(archive footage)	\N	1
661	208	523130	14	(archive footage)	\N	1
662	208	629377	\N	(archive footage)	\N	1
663	208	1082408	14	(archive footage)	\N	1
664	209	2092149	173	\N	59	1
665	210	1715869	183	\N	\N	1
666	211	1704769	14	\N	\N	1
667	211	2509852	15	\N	\N	1
668	212	1739545	1	\N	\N	1
669	213	2007904	1	\N	\N	1
670	213	2184023	184	\N	\N	1
671	213	11514	\N	\N	36	1
672	213	100950	1	\N	20	1
673	214	1150014	185	\N	\N	1
674	215	1619039	14	\N	\N	1
675	216	2329301	\N	(as 2-ply)	\N	1
676	216	2431615	\N	(as 2Ply)	12	1
677	217	2150202	186	\N	15	1
678	218	2366229	187	\N	\N	1
679	219	1700918	14	\N	\N	1
680	220	1499854	14	\N	81	1
681	221	954289	1	(1999)	\N	1
682	222	1823128	1	\N	\N	1
683	223	1721673	172	\N	\N	1
684	224	1777692	14	\N	\N	1
685	225	1721673	172	\N	\N	1
686	226	1198819	188	\N	\N	1
687	227	1909474	\N	\N	\N	1
688	228	2459938	189	(as CPM 22)	47	1
689	228	298416	14	\N	\N	1
690	228	451675	14	(as CPM 22)	\N	1
691	229	115989	14	\N	\N	1
692	229	766811	14	\N	\N	1
693	230	2316801	190	\N	\N	1
694	230	85737	14	\N	\N	1
695	230	719564	190	\N	\N	1
696	230	840033	14	\N	\N	1
697	230	1614662	14	\N	\N	1
698	231	2499750	1	\N	\N	1
699	232	2215768	191	\N	28	1
700	232	2215769	14	(uncredited)	\N	1
701	232	2215770	14	(uncredited)	\N	1
702	232	2296527	190	\N	98	1
703	232	2520607	192	\N	60	1
704	233	1642071	1	(segment "Wanksta")	\N	1
705	233	1655268	1	(as Marquise Jackson)	\N	1
706	234	619450	1	\N	\N	1
707	234	620143	1	\N	\N	1
708	235	2345369	15	\N	\N	1
709	236	2304128	193	\N	27	1
710	237	1896078	1	\N	\N	1
711	237	1907382	1	\N	\N	1
712	237	2518946	1	\N	\N	1
713	237	2518947	1	\N	\N	1
714	237	2518948	1	\N	\N	1
715	237	853003	1	\N	\N	1
716	237	1562044	1	\N	\N	1
717	238	154493	115	\N	6	1
718	238	1432970	115	\N	5	1
719	239	2284724	15	\N	\N	1
720	240	2518224	194	\N	\N	1
721	241	2504309	1	\N	\N	1
722	242	1756944	\N	\N	\N	1
723	242	2256678	1	(Mixwell)	\N	1
724	242	2305379	195	\N	\N	1
725	242	2432127	\N	\N	\N	1
726	242	1321347	14	\N	\N	1
727	243	2434648	14	\N	\N	1
728	244	174663	\N	\N	\N	1
729	244	655229	196	\N	\N	1
730	245	1734029	197	\N	5	1
731	245	2050565	197	\N	\N	1
732	245	352351	14	\N	\N	1
733	245	580954	14	\N	\N	1
734	245	1319912	14	\N	\N	1
735	245	1509483	14	\N	\N	1
736	246	1015917	198	(2004-)	\N	1
737	246	1015979	198	\N	\N	1
738	247	2375644	199	\N	\N	1
739	248	2275389	\N	(as Iman Benjamin Karim)	24	1
740	248	1275356	200	\N	130	1
741	249	1831312	201	\N	\N	1
742	250	1638576	114	\N	\N	1
743	250	1640112	14	\N	1	1
744	250	1640113	14	\N	1	1
745	250	1997417	190	\N	\N	1
746	250	2151499	15	\N	\N	1
747	250	2162040	14	(segment "When I'm Gone") (segment "When I'm Gone")	\N	1
748	250	2217346	14	\N	\N	1
749	250	2320641	14	\N	\N	1
750	250	2321991	190	\N	\N	1
751	250	2341889	14	\N	\N	1
752	250	2342191	14	\N	\N	1
753	250	2438638	15	\N	\N	1
754	250	129389	16	\N	6	1
755	250	331903	14	\N	\N	1
756	250	456590	\N	\N	\N	1
757	250	492906	115	\N	\N	1
758	250	677764	115	\N	\N	1
759	250	764279	115	\N	4	1
760	250	774779	1	\N	\N	1
761	250	1359609	115	\N	\N	1
762	250	1431436	115	\N	\N	1
763	250	1432437	115	\N	5	1
764	250	1433981	115	\N	\N	1
765	250	1571369	14	\N	\N	1
766	251	1679307	202	\N	21	1
767	251	1679307	203	\N	21	1
768	251	113538	14	(archive footage)	\N	1
769	251	894697	14	(archive footage)	5	1
770	251	894784	14	(archive footage)	\N	1
771	251	1570281	14	(archive footage)	9	1
772	252	1992644	204	\N	13	1
773	253	577147	205	\N	\N	1
774	254	2145423	14	\N	\N	1
775	255	1831390	14	\N	\N	1
776	256	220346	14	\N	\N	1
777	257	1841669	206	\N	\N	1
778	258	2434760	1	(archive footage)	\N	1
779	258	770240	14	\N	\N	1
780	259	1683169	14	\N	3	1
781	259	1836284	14	(archive footage)	\N	1
782	260	477355	14	\N	\N	1
783	260	702863	14	\N	\N	1
784	260	898067	14	(as Die 3 Z'widern)	\N	1
785	260	898084	14	(as Die 3 Z'widern)	\N	1
786	261	1551045	\N	\N	\N	1
787	262	1452215	207	\N	\N	1
788	263	352451	14	\N	\N	1
789	264	2156734	1	\N	\N	1
790	265	714560	14	\N	3	1
791	266	1638716	\N	\N	\N	1
792	266	1676204	15	\N	\N	1
793	266	1907751	15	\N	\N	1
794	266	2133455	14	\N	\N	1
795	266	2133488	208	\N	2	1
796	266	2133638	14	\N	\N	1
797	266	2215766	209	\N	8	1
798	266	172639	14	\N	\N	1
799	266	613978	14	\N	\N	1
800	266	758139	14	\N	\N	1
801	266	758228	115	\N	5	1
802	266	761972	14	\N	\N	1
803	266	766092	14	\N	\N	1
804	266	893051	210	\N	\N	1
805	266	894694	14	(also archive footage)	\N	1
806	266	894778	14	(also archive footage)	\N	1
807	266	1143131	15	\N	\N	1
808	266	1211605	14	\N	\N	1
809	266	1282176	14	\N	\N	1
810	266	1358529	115	\N	\N	1
811	266	1430397	115	\N	4	1
812	266	1431021	14	\N	\N	1
813	266	1432555	115	(as Thirty Seconds to Mars)	5	1
814	266	1434712	115	\N	\N	1
815	266	1547202	116	(archive footage)	\N	1
816	266	1547216	116	\N	\N	1
817	267	2379819	14	\N	5	1
818	268	2452032	1	\N	\N	1
819	269	2033052	\N	\N	5	1
820	269	2078204	14	\N	\N	1
821	270	1421868	14	\N	\N	1
822	271	1737791	211	\N	28	1
823	272	1015752	207	\N	9	1
824	273	1102569	1	\N	\N	1
825	274	1936353	212	\N	28	1
826	275	2133633	15	\N	\N	1
827	275	2133635	191	(archive footage)	\N	1
828	275	2133694	114	\N	\N	1
829	275	2425391	15	\N	\N	1
830	275	678888	115	\N	2	1
831	275	1432338	115	\N	5	1
832	276	2525259	163	\N	\N	1
833	277	1534094	1	\N	\N	1
834	278	2507109	1	\N	\N	1
835	279	1956526	14	\N	47	1
836	279	1402064	\N	(voice)	\N	1
837	280	1182483	115	\N	\N	1
838	281	1697613	14	\N	\N	1
839	282	352390	14	\N	\N	1
840	283	2366245	213	\N	13	1
841	284	546476	14	(as 4 Holterbuam & Die Mayrhofner)	\N	1
842	285	2048534	\N	\N	24	1
843	286	2378957	211	\N	17	1
844	287	1452136	162	\N	\N	1
845	288	457202	15	\N	\N	1
846	288	1604068	15	\N	\N	1
847	288	1604072	15	\N	\N	1
848	288	1604073	15	\N	\N	1
849	288	1604074	15	\N	\N	1
850	288	1604075	15	\N	\N	1
851	289	1485949	14	\N	\N	1
852	290	263000	14	\N	\N	1
853	290	737367	14	\N	\N	1
854	291	1398437	1	\N	\N	1
855	291	1398438	1	\N	\N	1
856	291	1398439	1	\N	\N	1
857	291	1398450	1	\N	\N	1
858	291	1398454	1	\N	\N	1
859	291	1398455	1	\N	\N	1
860	292	2148738	214	\N	71	1
861	293	1798983	215	\N	15	1
862	293	335535	1	\N	\N	1
863	294	714521	14	\N	5	1
864	294	856175	14	\N	\N	1
865	295	1838190	1	\N	\N	1
866	295	1840315	1	\N	\N	1
867	295	1918782	1	\N	\N	1
868	295	2056416	1	\N	\N	1
869	295	2453983	1	(archive footage)	\N	1
870	295	2502626	216	\N	6	1
871	295	827419	1	\N	\N	1
872	296	2348096	1	\N	\N	1
873	297	92350	217	\N	43	1
874	298	2019197	218	\N	13	1
875	299	1954994	14	\N	\N	1
876	300	1681400	1	\N	\N	1
877	300	1740680	219	\N	\N	1
878	300	2122153	220	\N	30	1
879	300	2163020	1	\N	\N	1
880	300	2176710	\N	\N	\N	1
881	300	2242729	1	\N	8	1
882	300	2340370	1	\N	\N	1
883	300	2411056	221	\N	\N	1
884	300	2431001	222	\N	10	1
885	300	2499142	17	\N	\N	1
886	300	139800	1	\N	\N	1
887	301	1749400	14	\N	\N	1
888	302	765037	115	\N	4	1
889	302	765172	115	\N	\N	1
890	303	871708	14	\N	\N	1
891	303	1168378	14	\N	\N	1
892	303	1235157	14	\N	\N	1
893	303	1478841	14	\N	\N	1
894	303	1490218	14	\N	\N	1
895	304	2434270	\N	\N	\N	1
896	305	1741977	14	\N	\N	1
897	305	2238254	14	\N	\N	1
898	306	291387	14	(as 48th Highlanders Pipe Band)	8	1
899	306	1477434	\N	\N	\N	1
900	307	2016913	\N	\N	16	1
901	308	877118	223	\N	\N	1
902	309	786380	14	\N	\N	1
903	309	1603953	14	\N	\N	1
904	310	1845324	224	\N	\N	1
905	311	2078204	225	\N	\N	1
906	312	1452311	207	\N	20	1
907	312	1452317	162	\N	\N	1
908	312	1452319	162	\N	\N	1
909	312	1452327	162	\N	\N	1
910	312	1452329	162	\N	\N	1
911	313	2325024	14	\N	\N	1
912	314	1417080	14	\N	\N	1
913	314	1452693	14	\N	\N	1
914	315	1950703	14	\N	7	1
915	316	97457	\N	\N	7	1
916	317	1536716	226	\N	\N	1
917	318	475193	14	(as 5angels)	1	1
918	318	475194	14	(as 5angels)	\N	1
919	318	642329	14	\N	\N	1
920	318	1238910	14	\N	\N	1
921	318	1604109	14	\N	\N	1
922	319	2265739	227	\N	\N	1
923	320	2158769	\N	\N	11	1
924	321	1929446	228	\N	\N	1
925	322	2342485	14	\N	\N	1
926	322	1431418	115	\N	\N	1
927	322	1434760	14	\N	\N	1
928	322	1441345	14	\N	\N	1
929	322	1480847	15	\N	\N	1
930	323	2191066	\N	\N	\N	1
931	324	824119	14	\N	\N	1
932	325	714489	14	\N	8	1
933	326	2301243	163	\N	\N	1
934	326	1587931	14	\N	5	1
935	326	1587942	14	\N	5	1
936	327	1547146	53	\N	\N	1
937	327	1547147	9	\N	\N	1
938	327	1547148	9	\N	\N	1
939	327	1547155	229	\N	\N	1
940	327	1547160	53	\N	\N	1
941	328	1547159	53	\N	\N	1
942	329	1038496	14	\N	7	1
943	330	2194671	1	\N	\N	1
944	331	728174	14	\N	7	1
945	332	69964	14	\N	\N	1
946	333	1995910	230	\N	\N	1
947	333	2386019	231	\N	\N	1
948	334	2216820	\N	\N	\N	1
949	335	2205303	232	\N	\N	1
950	336	1944014	14	\N	\N	1
951	336	2247462	233	\N	\N	1
952	336	498482	190	\N	\N	1
953	337	1679307	234	\N	33	1
954	337	1679307	235	\N	33	1
955	337	1679307	236	\N	33	1
956	337	113537	14	(archive footage)	\N	1
957	337	113540	14	(archive footage)	\N	1
958	337	113542	14	\N	\N	1
959	337	577094	14	\N	6	1
960	337	1570281	14	(archive footage)	5	1
961	338	1686343	237	\N	\N	1
962	339	1635364	238	(archive footage)	\N	1
963	339	1635870	239	(as Curtis Jackson)	38	1
964	339	1638519	240	\N	\N	1
965	339	1638530	1	\N	\N	1
966	339	1638800	240	\N	\N	1
967	339	1641058	1	\N	\N	1
968	339	1642065	1	\N	\N	1
969	339	1642066	241	(voice) (as Curtis Jackson)	1	1
970	339	1642067	1	\N	\N	1
971	339	1642068	1	(archive footage)	\N	1
972	339	1642070	1	\N	1	1
973	339	1642071	1	\N	1	1
974	339	1654126	240	\N	\N	1
975	339	1655268	1	\N	\N	1
976	339	1676391	242	(as Curtis '50 cent' Jackson)	1	1
977	339	1681298	1	\N	\N	1
978	339	1716555	1	\N	\N	1
979	339	1718667	1	\N	\N	1
980	339	1718676	243	\N	\N	1
981	339	1718677	1	(archive footage)	\N	1
982	339	1718921	244	(as Curtis Jackson)	1	1
983	339	1719841	1	\N	\N	1
984	339	1723446	1	\N	\N	1
985	339	1723467	1	\N	\N	1
986	339	1731506	1	\N	8	1
987	339	1735818	245	(as Curtis '50 Cent' Jackson)	3	1
988	339	1740621	1	(also archive footage)	2	1
989	339	1743720	1	\N	\N	1
990	339	1746444	246	(1 Brit Award)	15	1
991	339	1756121	247	(voice) (as Curtis Jackson)	22	1
992	339	1763716	248	(as Curtis '50 Cent' Jackson)	3	1
993	339	1811177	249	\N	3	1
994	339	1851184	1	\N	\N	1
995	339	1865764	1	\N	\N	1
996	339	1872807	250	\N	4	1
997	339	1884285	1	\N	\N	1
998	339	1891740	251	(as Curtis Jackson)	5	1
999	339	1898160	1	\N	\N	1
1000	339	1902715	252	(as Curtis '50 Cent' Jackson)	1	1
\.


--
-- Data for Name: char_name; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.char_name (id, name, imdb_tiny_index, imdb_tiny_id, name_pcode_nf, surname_pcode, md5sum) FROM stdin;
6010	U.S.S. Soldier	\N	\N	U2436	S436	ff2690cc3b3b8486ecc17fc597bc9d47
98533	Chris Teigler	\N	\N	C6232	T246	3b77037f2161dae4d2d860a2cf66291b
98721	Frankie Mulholland	\N	\N	F6525	M453	9b43f308c87dbac17adb9f4fc9137c4f
7058	Count Rood	\N	\N	C5363	R3	10c0099f53636b7a10e36ecd2b12b510
99474	Keach	\N	\N	K2	\N	557f7f53be50c1ee5caa2614382ec1e3
80132	Conny De Vooght	\N	\N	C5312	V23	564f5b2db807721f1aca780cd8a36ea8
70533	Dago	\N	\N	D2	\N	51f8743fb04cbe048a83c2c284f04392
58105	Janitor B	\N	\N	J5361	B	e74955b6a44368c7e50adb1c47155442
21899	Man mistaken for alex	\N	\N	M5232	A42	7c73d4f4faa6f1865fa5dc953fda635d
13639	Lineman	\N	\N	L5	\N	d1cfae873323e1bcad512d1955a2ec50
77443	Police Capt. L. Andrews	\N	\N	P4213	A5362	11f79694bb6b9db34072205dcef9f56a
26593	Aniceto Reinaga	\N	\N	A5236	R52	c48fde8ad351488e1d7331decc21e9ad
39507	Bishop Vick	\N	\N	B212	V2	dce8f5f0315d78247d64308e351a8b87
82239	John Cooke	\N	\N	J52	C2	e2741293c2b7bddd5ef4a9b8212c4226
83754	Alphonse Molaere	\N	\N	A4152	M46	206e88e97e3978bfaff0145090903f49
98256	Mario del Valle	\N	\N	M6341	V4	580724a6e4344b7bccc96d88c5ac7b7c
24289	President of Handloom Cooperative Society	\N	\N	P6235	S23	8fc8d140c869eda53d19ee0983d19705
25993	Tony Merino	\N	\N	T565	M65	7536c523b50af622704d083768dc5f3e
50591	Billy Wells	\N	\N	B42	W42	a01f0cb63e5e88e5f989a964d311defc
4612	Valli	\N	\N	V4	\N	c789292b92e12755d3a179d4aab186be
81136	Dead Hero	\N	\N	D36	H6	d71504feaff7b72362f9618a2876be16
98179	Himself - Nominee: Best Director & Best Original Screenplay	\N	\N	H5241	S2651	bf4ab0caac76ef3a1e1c945a064b87f7
35264	Blade	\N	\N	B43	\N	1ea52f26e7e0ce08e462f87f5e35096c
37373	Signor Scaletti	\N	\N	S2562	S243	401dc96a8b6b7a88d83c16f2d2e0ac09
53647	Chief Allen	\N	\N	C145	A45	0225c186ea8b91215d479f0024b41642
48181	Morten	\N	\N	M635	\N	6bc257998218d754b679634e8e30736f
94342	Mortel	\N	\N	M634	\N	5c0d1897a4ef0d5315d6a3d793cb5048
33601	Gärtner	\N	\N	G6356	\N	92a19a6845a0c9de167ee9fca75383c2
37863	Dave Jarrett	\N	\N	D1263	J63	e3f173370152176743d0503a23aced42
70500	Ward Ackerman	\N	\N	W6326	A265	aae318f43c6188388d8ae232bf290883
99440	Stanley Bowers	\N	\N	S3541	B62	a15a7c299b5fa948ff783d21acad7fcf
42636	Rich Dickson	\N	\N	R2325	D25	95a14a04e17b0e4300a400905683221f
75151	Motorcycle Man	\N	\N	M3624	M5	95dac51662dde53612440a8972b61fd4
46041	Sack	\N	\N	S2	\N	3f2a09929a97815b0c7aea3839b088eb
7848	Mr. Shyam Lal	\N	\N	M6254	L4	3d0b894dba771e8a4433cb0bcc5fe74d
73458	Company Dancer	\N	\N	C5153	D526	777904e4085966ae00d84495cc591ce1
78848	Conseiller	\N	\N	C5246	\N	a8a85825e685d0f7b0900bc3cabf3daa
83391	Humbolt the Clown	\N	\N	H5143	C45	8c7cdbd3beff09ee56be7a83d77bfe56
13545	Sgt. Topps	\N	\N	S2312	T12	f46a6b85310f6a190310dad45b48ca69
80564	Angry Associate	\N	\N	A5262	A23	ace7065eaf61a90cbf1424eaac042593
7097	Benny's best man	\N	\N	B5212	M5	1e5cfa37c7e8a6ca270e4b53ba8652be
77770	Jeff Andrews	\N	\N	J1536	A5362	6842dee405f66d0434f73913a8571ef2
8634	Younger Man	\N	\N	Y5265	M5	f33fc7bdd29cc7b25a154889b23df5ac
28977	Lapsi orpokodissa	\N	\N	L1261	O6123	637536492fce7d2e1236c79f8ffc0711
35920	Tomar-Re	\N	\N	T56	\N	4a3dc119ac0b1324615d934a8edc204d
92738	Bassanio	\N	\N	B25	\N	8236574727ffd41239e5729259e5c5f6
89307	Lanoix	\N	\N	L52	\N	da56fb39bf89855ed15bb568c364cf7c
36529	Harvard Student	\N	\N	H6163	S353	9ba6cd0b0678c852a8e723f4486ae831
66492	Adjudant	\N	\N	A3235	\N	a8029897f31f06c11c5db6523c3535c7
3599	Paul Graham	\N	\N	P4265	G65	b5f430e2089ef6b4181c8c5db9c1f051
77562	Sgt. Drake	\N	\N	S2362	D62	662d515bd8a6da73e74ac451eea7710c
23498	Buddy Amaral	\N	\N	B3564	A564	3de167dd2aa4bfe5ae4a3ad04e4531cb
36381	Colon the Clown	\N	\N	C4532	C45	893add6867724c47cef94eef68bd05bb
1614	Sebastián	\N	\N	S1235	\N	40c91ac55bd78297554a38cafa065f07
49960	Narkopolitseinik	\N	\N	N6214	\N	f408645106a848438d81e1577ce94c65
33175	Officer Charles Stacy	\N	\N	O1262	S32	27cdc597bfa4d8f594171cd5e968cf50
1849	Jim Ortega	\N	\N	J5632	O632	93774be049d107b70871c9c9e7ec4332
49395	Himself - New York Mets First Base Coach	\N	\N	H5241	C2	4d6a4be0f30bb554e26582a66b5a7bbe
44907	Man with the train	\N	\N	M5365	T65	371963ffbd478f15794942a1df5492a6
90927	Tônosuke Ibuki	\N	\N	T5212	I12	79a1f24682e0e8075a05161acf2a4148
36725	Agent Type	\N	\N	A2531	T1	aed7840aabfaddc2b9d427a53d36c15f
82908	Paul Springfield P.I.	\N	\N	P4216	P	4d8c3197746849cd953e568ccee3a050
88338	Demon Soldier	\N	\N	D5243	S436	b603331a471ad6a65367a3f7c296489a
71979	2nd Deputy	\N	\N	N313	D13	a8c2e6f6e183b586e11380857a9698de
8192	Orderly	\N	\N	O6364	\N	423ccc3106f9ea26a8473f2eb7f37bac
16661	Andy - Safe Company Foreman	\N	\N	A5321	F65	7453cf350e32f4b660eecd7e391d9e08
65511	Dead Alien	\N	\N	D345	A45	2ae8a999fc428bd8786e69db2c95ff61
20447	Un clochard	\N	\N	U5242	C4263	8e08e814a42198851ac11f48ea363567
96955	Pastry Cook	\N	\N	P2362	C2	406a6e8cc1b6b6ca8612312eae7c88cd
5445	Heiner	\N	\N	H56	\N	750041db7874760997b5f364ea8a57b9
97421	Mike Harris	\N	\N	M262	H62	48b16920e070e2bed2f3861c913eb3d2
19680	Sheriff Brennan	\N	\N	S6165	B65	7d9f56e0155fe920ac91d219af8ba658
3118	Himself - Guest Commentator	\N	\N	H5241	C536	e3a370263ed0c893c560247e70ab570e
96996	Scott Kayle	\N	\N	S2324	K4	1b4ba56b993e68fe6b4be9585cb45e2f
6976	Herne the Hunter	\N	\N	H6535	H536	5738c2dc402ed44e3a302b39b966bcb6
3040	Cuthbert Greenway	\N	\N	C3163	G65	74b95f332714729fce592bac7928327c
10343	Photojournalist	\N	\N	P3265	\N	e1e27a6b79bcd776c7a9b7d3cba39866
28073	The Man of Today	\N	\N	T513	T3	a33dae9c79d10bfe0485a5ffa3220dea
12174	Sir Robert Beste	\N	\N	S6163	B23	466f729e3fa8819ae1ec74db86493d84
98754	Himself - US Deputy Secretary of State	\N	\N	H5241	S3	6a1a79a26c3765d6eb0a09192f083421
82706	Rafael Torrez	\N	\N	R1436	T62	ccc02e76ef2cc07a1893f8db20801190
40653	Featherd	\N	\N	F363	\N	022d77f63b0aa68e49e53acd4b9c7279
150	Kab 101	\N	\N	K1	\N	1271557a3954a37722c72809affb70a2
21585	Jesse Boone	\N	\N	J215	B5	d857a532fa5685bfc52171b5fb905c51
45026	Band leader	\N	\N	B5343	L36	085d087232622d56085e602b3117c85e
20492	Man in Police Station	\N	\N	M5142	S35	2d69373823e8681d11d73da6b0b90827
63321	Dimeglio	\N	\N	D524	\N	0d455973a6fb7c7e748f45896fec9c7c
91994	Vern Walker	\N	\N	V6542	W426	b2ae06a08e6f1b9f255fb4c8e6f5f9b3
16552	Harvey	\N	\N	H61	\N	25c0f70d3b669f0400b5733433b5a2cb
27441	Ylivartija	\N	\N	Y4163	\N	2e959158a4cf3ed8597e3be4fe7c175f
77638	Josh Blaine	\N	\N	J2145	B45	fe689d57ba9bad81c16e30e9f30c9cc7
55003	Playing Child #1	\N	\N	P4524	\N	93a58f40c428690dce19c74ae3950a2c
49267	Relator	\N	\N	R436	\N	6465fa4b34e57eaee302423e9af02fff
59787	Rajiv's Father	\N	\N	R2121	F36	d7878616f7ece795bc336616416d8d3d
37603	Martin Barret	\N	\N	M6351	B63	4c8010ccc406d74a20debb75b701b9bd
37353	Juan Castinado	\N	\N	J5235	C2353	29f1f1f492384dc6577985ec01d316e0
67285	Police Inspector beating Heera & Moti	\N	\N	P4252	M3	8a9a064e2877b0a88de62faf6fc52774
36481	Emmanuel Linum	\N	\N	E545	L5	301872c1ad2b8e6cc5cd43cc0cb07b20
28155	Abdel Samad	\N	\N	A1342	S53	d71f927503e9fd44c0c7659a159d667a
27378	Árbol	\N	\N	R14	\N	a61ee03859e1dc9664d4f6ae90dcd68c
90121	Sulo Riippa	\N	\N	S461	R1	cd44d334ad612d869608393c7e295a62
216	Vernon	\N	\N	V65	\N	b928a50c7e877267d29c7f20d01668fb
94793	Moritz Morris	\N	\N	M6325	M62	6b3064ce166646b06d511ca023aea5cd
14983	Second Usher	\N	\N	S2532	U26	5c45929b946b66c4464b38c98e0cf0ac
95577	Dick Wilkins	\N	\N	D2425	W4252	28c7b88ddf7dafe7427da177654e490b
72123	The Botanist	\N	\N	T1352	B3523	31e823e4eb885ad62b069dbae9e7158b
75226	Nicky Alexiou	\N	\N	N242	A42	7ad939f71ac2bc15f651a408c7586105
24583	Duvel	\N	\N	D14	\N	b028e3bedf4d980da5aca694ce86554e
29238	Tito's Buddy	\N	\N	T3213	B3	d0fd08dc118250b272f3508cba28f6a2
73765	Pladdermus	\N	\N	P4365	\N	0c0d5c5518402d55e8ac03787c1f6dc7
11114	Bar Band	\N	\N	B6153	B53	471b8f72932f38abb7758e94dd43fc02
61520	Barman #1	\N	\N	B65	\N	4fd3f023a2768d801fda8032f16830f8
3182	Gregson	\N	\N	G625	\N	4cbcd262a39f909f081e340777a1d2ed
85224	Uragan	\N	\N	U625	\N	13fead760868bd9a38a0cdc7ef410b2c
12631	Cowpuncher	\N	\N	C1526	\N	62099e6dd4d5c4686fef45aebabcaa46
23341	Sashenka Micharin	\N	\N	S2525	M265	51ed25a5208f826697495c0a3323b66d
22137	Himself - Son of Inventor of Subbeteo	\N	\N	H5241	S13	0c36d072d371c464e0f4d9f412de5e1d
53388	Luke Fulgham	\N	\N	L2142	F425	7d407752529695a9d8b0d1c57e0236e2
54695	Colin Hicks 'CJ'	\N	\N	C452	C2	99b6ce2d84a00849ac1dff8b7146919d
40543	Paco Gil 'Duque'	\N	\N	P2432	D2	a404c79fe4203bc973980fc3cfd13229
19928	Indigo	\N	\N	I532	\N	8b7b9806e715b01b9021912e0f86935f
88216	Friedhofsinspektor	\N	\N	F6312	\N	a4eedf860650a48a00e912623a3eeb3a
80205	Model in Fashion Show	\N	\N	M3451	S	e2bd56d63cc5b5b0f2d95af75fdf59af
37882	Edgardo	\N	\N	E3263	\N	8ea358048f0d7ab2052f87e2cc189755
35209	Jay Leno	\N	\N	J45	L5	c64d9ce21c97e8a95a9843fdd3425b4e
10141	Himself - Surfer	\N	\N	H5241	S616	1b74f646b27a9b939ebf7162d45aac22
73595	Assistant to Mr. Bigfoot	\N	\N	A2353	B213	21f10285720dd115311f3e922dc038b4
33515	Yavakri	\N	\N	Y126	\N	8b3bc8bf9c665d809d37698acd4f266a
96634	Chief EIeio	\N	\N	C1	E	ab77aafcb8fc44322afac4ef5986130d
73564	3rd Elder	\N	\N	R3436	E436	a85431651dcfb8060dca8455bec9ba01
70160	Door Bailiff	\N	\N	D6141	B41	768db5aa1ea68eb0cbd394f8491690cc
65818	Parisian at Cafe Playing Checkers	\N	\N	P6253	C262	da388ade931b2b42dfb85330342560b4
37784	Dramatic Reader	\N	\N	D6532	R36	d5948ef3b4c3e89c5d28825f48bda679
3955	Dr. Maher	\N	\N	D656	M6	cfcbfaa70c1c3b963ad95471aa24b339
98840	Thomas Riemer	\N	\N	T5265	R56	569923c54fddb9ec9775ff236ccb2cc9
74931	Pablo 1987	\N	\N	P14	\N	2eb674d318274d6d160e826d74820fad
73188	Harold Mitchell	\N	\N	H6435	M324	c04e7b3905312e514e416e2b44b487bd
17848	Oberon	\N	\N	O165	\N	f9d0e88ed22cb947b07018fe81d0446d
98319	Oberoi	\N	\N	O16	\N	896c8bf270590bcdd1399878c4cfd2b7
68690	Himself - Astro Physicist	\N	\N	H5241	P23	a80e9b7283f6a52f2fbc858e2d27f2c2
23658	Dr. Haziz	\N	\N	D62	H2	1bba1819b7b09cd8dbdf4a31f4f46973
44977	Mckee's Double	\N	\N	M2314	D14	b43cb45395a2fc5db3a64f5bd352a962
86943	Japanese Sniper	\N	\N	J1525	S516	15e24ba1740a396752eb27b5f8a60548
91417	DRH Gstaad	\N	\N	D623	G23	8c1b08829852baa2e3542067c4307dbd
52135	Baby Paul Bower	\N	\N	B1416	B6	dee2db24fab8ad1bc6cda7f74a0d45fb
92169	Weeping Wall Guard #2	\N	\N	W1524	\N	544069f1686f3c636aeff02a00309ae8
53521	Eric Gregory	\N	\N	E6262	G626	ffa71c31e61966b54898efa0a75aa2cb
88292	Aeroport Mechanic	\N	\N	A6163	M252	cf5cfebf9ccf579e57b3826791bee816
45236	Jolly Jefferson - His Partner	\N	\N	J4216	P6356	0869a25d5d734dc0534814717638f6e1
20088	Gaspard	\N	\N	G2163	\N	8daf96aadf21b930da482dd770fd7b2c
69405	Miles Davis	\N	\N	M4231	D12	aece832db461334bdf98062b9ddc1ab7
63937	Larps Champion	\N	\N	L6125	C515	b0761390cc3b6b28dee424684af87be4
80442	Zika	\N	\N	Z2	\N	65ed20b21e2993fb00dbd21a2fd991b2
25485	Clerre	\N	\N	C46	\N	cd2de4b1ecc2060e6c6469fd813cf145
38103	Filippo Maria	\N	\N	F4156	M6	5b477a7fef82a71627f0ba77ce60f5f0
8751	Correspondent	\N	\N	C6215	\N	2dd84da1afd84efebbab66b389938598
27362	Bates	\N	\N	B32	\N	c1bdcc7d5b47d60286c6c12b9d2e89da
91288	Guardaespaldas Don Marco 1	\N	\N	G6321	\N	ec42cad16353a0bb8aae600ee792f2c5
50345	Himself - Dog owner	\N	\N	H5241	O56	d96c8987554ab1f0d001d4e23739dec3
98601	Touchscreen Map Demonstrator	\N	\N	T2651	D5236	5e371eab15438b4c9282bc300639c93e
17683	Pizza Joint Patron	\N	\N	P2531	P365	635d8b21001e0497427ecf249aa4e995
93852	Machiavel	\N	\N	M214	\N	47b49991ae7074c149909022c9120b77
89562	Mr. Gonzales	\N	\N	M6252	G5242	0aceaa5f203419e6106fa5d244e93a29
83769	Cthulhuphant	\N	\N	C3415	\N	8296add1b52e80a095eea648ee17e5a5
59772	Caged Man #4	\N	\N	C235	\N	484382291a5b943e4a815daf41243081
28884	Luigin apuri alias FBI-agentti	\N	\N	L2516	F1253	d79e2310c72e831f0effddc6f89c0162
38483	Pastor showing DVD	\N	\N	P2362	D13	8d733626f00da23cfe68d160a3c99d56
60222	Mr. Gonzalez	\N	\N	M6252	G5242	e5d6454f17ee6f7d8decdd5f295aab1d
85294	Elliot Block	\N	\N	E4314	B42	564a355954a695dcc7f4f73e5ace0045
95274	Supermarket Manager	\N	\N	S1656	M526	b40103de4f17d23726f5e2663e771cce
94395	Enrique Montenegro	\N	\N	E5625	M5352	f2d10fc3b2063befbdbb90132971790e
7444	Sam's brother	\N	\N	S5216	B636	4974816e579d7af929fc76f283ad39ad
26256	Obispo de la Ordenación	\N	\N	O1213	O6352	4108f20e8841c7354c5e5ac5a4b4881a
81003	Don Paolini	\N	\N	D5145	P45	5efd762a0bf530286dbba3bfa9a98234
51695	John - News Stand Guy	\N	\N	J5235	G	42cc5433681841928664c27744f1dac3
73292	Himself - University of Northern Colorado	\N	\N	H5241	C463	75a274cab4524076ebebae92e8681793
61624	Bobby Makefield	\N	\N	B1521	M2143	d24567cdacd0f6ca8b9590de42e6c8cc
1724	Michael Seco	\N	\N	M242	S2	796cdb1d5aa2297de4efc6b6d09b220c
50036	Shimon	\N	\N	S5	\N	30c06c4b30bf9042475e8ed4ebac6424
65284	Klamotte	\N	\N	K453	\N	5503cf8d81d9258399ef71675a0042dc
81632	Himself - St. Louis Cardinals Center Fielder	\N	\N	H5241	F436	9064a131f10129bd9c3ad3c4c8887ea1
3979	Anwar Wagdy	\N	\N	A5623	W23	d9f0050c35582354bdb74b827324c18d
52276	Marcus Freeman	\N	\N	M6216	F65	d3cf8d6447ea2534b85309668c0461bf
56073	Guarura #1	\N	\N	G6	\N	c6a0e992810a91c0af8f31df0b0ad353
53265	Young Tom Edison	\N	\N	Y5235	E325	01adf3302730a0239f19548fba9a63d0
47965	Company Roc 2	\N	\N	C5156	\N	c031a5e070320cd63635db9915405f14
31575	Black Blast! cast member	\N	\N	B4214	M516	56e86a9b04c6cb9ed6e5021a53cc028e
99883	George One Spot	\N	\N	G6252	S13	25895b5aac90412ad81f43fa476dc1f5
25970	Intendente Onofre Fandiño	\N	\N	I5353	F53	9f277de4f43ce84ba81500e0a8eb1b03
62885	George Jacobs Sr.	\N	\N	G6212	S6	f230e66674075e5e16bce2a9b29018a7
82679	Sgt. Duff	\N	\N	S231	D1	262dfd5ec9bb54b86fe6ad4a578240cc
6971	Schroeder	\N	\N	S2636	\N	3574fc0ca646780283309bcac6b6cc87
1602	Alumn in class	\N	\N	A4524	C42	32476bf8be7154078658d9a0445b09cb
42210	David Brewer	\N	\N	D1316	B6	6d10895aa3f919f51a457730eb43442a
66876	Badawi	\N	\N	B3	\N	8312c6e6c372451c842d8a6be75e68c4
4734	'Robot'	\N	\N	R13	\N	8051f49b0e226a40422539bbacd2d10b
42122	Montague	\N	\N	M532	\N	d9a359bb89bf99ad7d8f03e42b55f4bc
77744	Dr. William Arnold	\N	\N	D6456	A6543	9cf2219ab372d48779b5c07dd45f640e
2505	Asif	\N	\N	A21	\N	f5ed1ae11d9b10782a690cc6d8f5fb22
32368	Himself - Nathan's Team	\N	\N	H5241	T5	51699a99105ba4523038f13c861f6431
78069	Hij	\N	\N	H2	\N	cc0fe2fc51ae2bb10741d080ccd7405d
18531	Edgar F. Evans	\N	\N	E3261	E152	91efe88b76f30ef02335a3f08eda578a
2997	Him	\N	\N	H5	\N	b582f0ddd1c3852810de9cb577293351
89458	Batang Elias de Chavez	\N	\N	B3524	C12	4bdedefa90035e7a5333bdcbb40db60f
36414	Commander #1	\N	\N	C536	\N	62a62b68b30ec274153f9ad5ed76b505
81648	Macio	\N	\N	M2	\N	4959fafb966d47348c32072ce6538d0b
87211	Doohan	\N	\N	D5	\N	8c6534af5df44c6ef2ce5b2e0b329db7
58064	Dr. Panos	\N	\N	D6152	P52	dca023c7e4128aec606052c5c0699717
78190	David Lake	\N	\N	D1342	L2	4f93fb9a8da255c7bf61ce53f00d3a3b
49601	Macid	\N	\N	M23	\N	7da1bb8315422c8f2b7224d1b888c433
40209	Le financier 'humaniste'	\N	\N	L1526	H523	385faf45e5972d3c03726fc2dcec6443
41691	Ryan Conner	\N	\N	R5256	C56	50686b26effc24e176d703db7b58dd5d
27659	Långviks-Erik	\N	\N	L5212	\N	91a5aa2834591d7e1030a8d18de51604
23898	Himself - Cubbyhole Conductor	\N	\N	H5241	C5323	82a1e73b9473cd62c924943f1ed13bf1
47899	Vito Ubrissio	\N	\N	V3162	U162	559260c2a87ab31f9ae39db2b5652b2e
58149	Inconsciente	\N	\N	I5252	\N	ef1f672cea83ebaa55f91e92b78cc494
578	Tony Evans	\N	\N	T5152	E152	3d92b4a74d7599e016f75de7e9dfcd25
6808	Maromo tetería 3	\N	\N	M6536	\N	ceaa105c98f7d0f0f0ed5b6b63ed1d8f
37498	Dr. Blank	\N	\N	D6145	B452	63d5eb81429de9614a42398380519a15
705	Vaska Pepel	\N	\N	V214	P14	786fdcb440ae473cd3c258deec0d2427
62901	Shirpati	\N	\N	S613	\N	2f3dccd0c958d9738351c960fecdb478
60764	Boy Bakal	\N	\N	B124	B24	5d5bf11c4146fc1182bbaee0ea90637c
57116	Mister España 2005	\N	\N	M2362	\N	a5fe2b4926e43df8d243011423da41ee
71445	Sergeant Rainey	\N	\N	S6253	R5	3d4e1e5640decc7fd12a4091d461c8f5
12225	Patrick Hopkins	\N	\N	P3621	H1252	d608ac606382a13eea9a786deeafce54
10533	Daan de Vos	\N	\N	D5312	V2	4e750fda827dfd66ecb64363ff0253d7
39949	Eddie Cool	\N	\N	E324	C4	7622c09f419d0dd4c0ec6aede7168502
44489	Dr. Moyers	\N	\N	D6562	M62	3577c466067dc1df7d0acd358ab0c2e6
76998	Hans Hoffmann	\N	\N	H5215	H15	1b14a7836fc6f6f37588bdacdfaff7ce
13152	Carancho	\N	\N	C652	\N	2796e0f77ca7102e16639ccaf0be5b05
88423	Crowdy	\N	\N	C63	\N	836e5846a030b77395803950d2033c59
96341	Prof. Obayashi	\N	\N	P612	O12	b7edbe4e8880ee6657e457fb2c33b63e
38807	Mr. Leonard	\N	\N	M6456	L563	5edc00dc115f0abfa181016d5b1a3e26
80518	Gang Narc	\N	\N	G5256	N62	c5576b751fc9a9c46ac070247fbc2fb2
58529	Mr. Cheek	\N	\N	M62	C2	47730b29343ba61595645772d131a72c
91464	Alfred III	\N	\N	A4163	I	7420a2a7effa1f0cca4d0754137f0f70
46204	Susie	\N	\N	S2	\N	879c0240e667f40055398f97565d2c65
31104	Male News Anchor	\N	\N	M4525	A526	f59ca1f24a6450668f292bc34659d0c3
83733	Dancing Delegate	\N	\N	D5252	D423	6ce0180168305578d2e1dea44ca3bf76
25279	Nico Escobar	\N	\N	N216	E216	9b64b8838e60ea7f5f59f3f22db1fa12
42924	Ralf Dienert	\N	\N	R4135	D563	b989ec0c2e2bfefb8bb5d8ece587f144
63872	Infinity Attorney	\N	\N	I5153	A365	d6194983703272b4d348b20e69b551f6
86842	Exerciser	\N	\N	E2626	\N	d0e3fa420ff6ee43207e844a51c5db37
65987	Dr. Herbert	\N	\N	D6163	H6163	ac61355b47171dbdaf39bed6f7390cd6
53080	Drugs money sex 24-7	\N	\N	D6252	\N	7d0ddbeca43b30b2194773b36514acd7
98338	Gen. Vicente Rojo	\N	\N	G5125	R2	bc3b10ee73322ff65e11c2ea5a124c25
17067	Man on the Bench	\N	\N	M5315	B52	71320fff3d933fc413596ea6929ea064
60928	David Mestre	\N	\N	D1352	M236	509f7484a4389b3dcbcdf6c11d14d4d8
16062	Leslie, the Steward	\N	\N	L2432	S363	3d8bb008d22a5559c47f589e0a5fa1e4
79549	Colonel Diaz	\N	\N	C4543	D2	f61d73b33083b6a5e1ba7b7efecdc981
92338	Insp. Duffy	\N	\N	I5213	D1	e80cbc5dc9774c9630b37cd068aca81e
2295	Vojnik ABIH - ubija Coru	\N	\N	V2521	C6	260988567bcb70d3d3a1e3cec316eb52
53129	Swaney Rivers	\N	\N	S5616	R162	2d23c0be88d61d3f201b00adb84c7947
33717	Ego	\N	\N	E2	\N	18f44b1a7909f6054afcbaafc0aed75c
63564	Mickey Caldwell	\N	\N	M2434	C434	68f618e5968a195c074621d4aa5fdead
86626	Asian Footballer	\N	\N	A2513	F3146	93c4db4b97958b9eade2e54710497f9c
44840	Senator Barnes	\N	\N	S5361	B652	843c8d83bbd4b547740e653cfeb3d29a
33617	Jasbinder Singh	\N	\N	J2153	S52	2637910529c2cbdda0cb1835d722f75d
8911	Expert Commentator #2	\N	\N	E2163	\N	8c0f99dd6edb33691c768f9e602af075
6382	Nigel	\N	\N	N24	\N	875fecc653a63476df781eb2b09d333d
14349	François - le chauffeur	\N	\N	F6524	C16	f0e1946a6861f1c80f894f10e8e03ff2
75800	Stulle das Wildschwein	\N	\N	S3432	W4325	b21c5df7bd80336a8c4dad609586d702
22202	Bengt Berger	\N	\N	B5231	B626	8993bd6543a0b8ae7d5e839dd38bbc08
61381	Coach Kirby	\N	\N	C261	K61	c8171cbd482cda9d3bbeba0ddb92f94e
24793	Traveller on Train Roof	\N	\N	T6146	R1	b8544f3fa8aee7b5646aa3ae5e2e385f
14665	Commanding Officer at Falcon Field	\N	\N	C5352	F43	5ea63abb974ca470c8e7a67ca3476c68
42886	Maj. Verner	\N	\N	M2165	V656	08217b29cc5e7041d1aea19143c9a650
33464	Genpan Shikiba	\N	\N	G5152	S21	60601c21f4d440b8fa1b7a29da55e618
67867	Kristof	\N	\N	K6231	\N	c2434f4ff5d7b329354092150763bbcb
95069	Chico en carreta	\N	\N	C2526	C63	d8080156b5ae7d6c221229c1c36fcba6
19894	Ibrahims	\N	\N	I1652	\N	9eb21dd4dcbd0c7a0138bc0d7f365587
5788	Randy Colwyn	\N	\N	R5324	C45	17f6bc88c7da97eb08d91f6def9514dc
61057	Pony Smith	\N	\N	P5253	S53	85097f625496fc43a86e344535b45079
2768	Mayor Nick	\N	\N	M652	N2	5889a6d7b1238259dd8578d0f938d1de
248	Tino	\N	\N	T5	\N	73dcc5a88eb5991919c90ee6b9952c3f
19619	Lieutenant Stanislaus Wisniewski	\N	\N	L3532	W252	50ab145e158ffff97724f46828b763a4
32099	Soji Okita	\N	\N	S23	O23	a41860c2948a6c0043c4aea3c69d9937
18615	Philip Angra	\N	\N	P4152	A526	326f78de17ce6c35d78ce8eef5afada2
73279	Himself - Army Black Knights Linebacker	\N	\N	H5241	L5126	b6a84b359a140cff053af0c33163106a
65801	Man #5	\N	\N	M5	\N	437d4996c0c676bd24ff0c01bec85ed7
53686	Gene Fredericks	\N	\N	G5163	F6362	82b3c0f6f4d10da2c8343ec533ccba01
32009	Ahmet Zeybek	\N	\N	A5321	Z12	9621f6d30a0e52074b5a6b602f5f5087
13457	Purnell	\N	\N	P654	\N	9e7f85096acd7a9a7cc45e410cba9e6b
18386	Peter Langley	\N	\N	P3645	L524	2acc51b3771efcee09cbd76032734b24
19495	Wonder Burger ansat	\N	\N	W5361	A523	220dbef80c4d09221d40872401d8b196
21715	Irving Werner	\N	\N	I6152	W656	7873613e84a87da7c1f170055bdc5ed4
11986	Hans Riemann	\N	\N	H5265	R5	3706a193170491c9a678ca865c97cf67
18215	Schmidt - Pawn Shop Owner	\N	\N	S2531	O56	869c8f4680cc9569d6587b7c533d40ac
44109	Joe Riley	\N	\N	J64	R4	0a629b6620fc1fb6f20316c36cf77d5a
98846	Hotelmanager Borge	\N	\N	H3452	B62	e1046b2e3032001ae5388fb485f1603f
80060	Pealer Bell	\N	\N	P4614	B4	77f3ee3bf842fe5c2313ff6a6af8f486
57698	Himself - NL Center Fielder	\N	\N	H5241	F436	1a4e35670294326de1ecbdf329a66011
1901	Cucaracha	\N	\N	C262	\N	992395945bb94152324cc1ebc68068d9
87965	Kommissar Fink	\N	\N	K5261	F52	a9b4ff11bcd6427c7cf0f2d721ddd82d
18104	Clint Meyers	\N	\N	C4535	M62	e8b22b7cee273687ee2bd3e9074daa6d
16523	Agent Dan Sandler	\N	\N	A2535	S5346	bc04be203a821ede0dc3128fb4932300
45248	Herrenguth	\N	\N	H6523	\N	a9d67b13a39614ce059204cff6d3229b
51952	Clone Trooper	\N	\N	C4536	T616	9d031a739f1f058d49a758961aa35013
96811	Cluster Henchman	\N	\N	C4236	H525	728ad1bf182f8884e81a9f9c749ee999
45747	Militia Man #1	\N	\N	M435	\N	00eab43f2e9924f8ae64417e9db20163
92615	Pvt. Carter	\N	\N	P1326	C636	1ead0328a4ba2ff0f72e747c15628009
83210	Iván - Orlofsky szolgája	\N	\N	I1564	S242	b1ef6815c8e078311244748a9d877200
98831	Olivettis Anwalt	\N	\N	O4132	A543	ccca45e76bbd8fb64232406fbf36a326
80798	Michel Durand	\N	\N	M2436	D653	cc56de2f67e4e8c99983c2cd4139aa9c
16026	Eddie Withers	\N	\N	E362	W362	5dcf1378918aec0980cc6d8a82f326d3
46396	Mongol Guard	\N	\N	M5242	G63	d472890f39049278474f4a4c4ca26480
52252	Himself - Academy President & Presenter: Replacement-Acdemy Award to Gene Kelly	\N	\N	H5241	K4	9c8b2b2870a278d900a7b4062ba1a7e5
41707	Delbridge White	\N	\N	D4163	W3	38eedc5a6124a63f76ba7dbb59aacc74
50775	Little Gray Squirrel	\N	\N	L3426	S264	89a106e87c816e8f0f24bdb8ffe0a302
98988	Tommy Botch	\N	\N	T5132	B32	eb797165d76a047748810a224832855e
84674	Scotty Riggs	\N	\N	S2362	R2	3805eee72f20c348f7a25f45aa4ceeb1
90140	Zordon	\N	\N	Z635	\N	a83949fa4679ab2f3f4f67ad5962df9d
53221	Darth Maul	\N	\N	D6354	M4	6723d50c676e8edbaf291b9ed64076e3
10372	Daddy	\N	\N	D3	\N	b1238bf94cd25f28266970965553be9f
96940	Rania	\N	\N	R5	\N	3a2fda08afe1a4fc2e894905da9fde9f
92814	U.N. Security Officer	\N	\N	U5263	O126	a3d99316d2971d9e967e9ceaf49f5438
99150	David Cameron	\N	\N	D1325	C565	b1779da46ba3ab99913a6e2641bd9dbd
85308	Silvio Berlusconi	\N	\N	S4164	B6425	d4710d88b55819dd06f52b204a068404
95045	Cando Salonga	\N	\N	C5324	S452	56340e06058211f498f521c00799b14d
12817	SOCO	\N	\N	S2	\N	9e46b57817a4c06736dadc3d671d4d23
68580	Politimester	\N	\N	P4352	\N	61e05e70252c0b595d39105d7589a6d3
79617	Buddy Arnstein	\N	\N	B3652	A6523	98d4108d96106347defdb8851d4a1aa4
16905	Cigar aficionado ringside	\N	\N	C2612	R523	b4635dd0e7a604df263f4fde8e162c30
46978	Dr. Crowley	\N	\N	D6264	C64	5e54b510ce537d9cec0a41dd139a29eb
13617	Hash Brown	\N	\N	H2165	B65	97f5d81c01d25a8754d7aac0e43fbcfc
66036	The Whip	\N	\N	T1	W1	979429ee73e22a17ba6f773968af1de7
90144	Unsui Baishôken	\N	\N	U5212	B25	415e1197876639bf4b8e05f7b5041b5f
16501	Dr. Richard White	\N	\N	D6263	W3	dc0b288d2be784a00ea4b4ebae2214ac
40091	Nate Evers	\N	\N	N3162	E162	4366eca802fa57a431d99837b239fe51
48805	D.I. Adel	\N	\N	D34	A34	fa6923d3cc9e8e4e3e9d44344dbfbeb3
68066	Irish Angus	\N	\N	I6252	A52	0d9f6239dc38fff88a4f6099f3eb8cde
97219	Mark Gillen	\N	\N	M6245	G45	2f04db59082691a44dac133ff18105a6
93706	La voix de Dieu l'invisible	\N	\N	L1234	L5121	fb80ef7a8d5b8d610d3aa55bed919bf4
87391	Apache Dancer	\N	\N	A1235	D526	6d47052e4575db77328d684192a01509
80058	Boy on street 2009	\N	\N	B5236	\N	da1751da904c738966df65215cccd26a
20331	Counter #2	\N	\N	C536	\N	a44ddbe7144c312da8c6efa21a6fe3a3
65631	Chicago	\N	\N	C2	\N	9cfa1e69f507d007a516eb3e9f5074e2
19166	Young Man on Bus	\N	\N	Y5251	B2	fd549c207f5849db141650d64462a317
64156	Mr. Hillaby	\N	\N	M641	H41	12c8a1e7dfccc3faa1a52b6b5482357d
29406	Tó Zé	\N	\N	T2	Z	1e471ed47efd79c3fd0131783ae7d98f
88430	Ryecheck	\N	\N	R2	\N	0030e277e45ada129c183d8f156b3455
43138	José Carlos del Pino	\N	\N	J2642	P5	e02e0999bae9ebc56df35e715baeef09
70446	Defendant #1	\N	\N	D1535	\N	c34e41c6e3cfe3d02f33d3311f8ca88d
24105	Lt. Joe Mallory	\N	\N	L3254	M46	49d6c36e7a9f7042880990729ccafb0c
91514	Baron de Méridor	\N	\N	B6535	M636	04a8ce2ac7053e0a327955f70775c7da
7738	Theo	\N	\N	T	\N	648c4b84114609edf619be0de4e27fad
21281	Corroder	\N	\N	C636	\N	c0351685d0f065bcc329f332a6442650
90182	Britney	\N	\N	B635	\N	77af74f3d3e435c0ea418456f820ccfc
38315	Matt Ritter	\N	\N	M3636	R36	c827f671395376f2d2fa0e766c0859c8
23674	Grandpa Sadaqatmal	\N	\N	G6531	S3235	a275ecb1f66864a22a0fc712551576c1
74019	En kommunalarbetare	\N	\N	E5254	K5461	eecf62689bc159d9139e207e43231488
38394	Lilso Lagard	\N	\N	L4242	L263	fa469ec7002d5166cf55f36f29980503
87155	Donarudoson	\N	\N	D5632	\N	936a7d9f2b3ce513ac3a2fc74c8f7b18
14105	Kaura - Tribal Sub-Chief	\N	\N	K6361	S121	313cf68b018a794d6a82e9c9b9e06954
54704	Deutscher Skiläufer	\N	\N	D3262	S2416	12b0da696558436f12fbc59812ce2b3f
63430	Tótó	\N	\N	T3	\N	e99bbdff7983611b04b8d4016dba219d
95962	Bicuri	\N	\N	B26	\N	f4771ab226abf1c291b003d649f9abf6
20982	Dragonfly hoe	\N	\N	D6251	H	9209b7f7bcb8b5d3014cef8310b73b8b
31125	Père de Moussa	\N	\N	P6352	M2	c5a4f1b5649c737a5582832143cd422d
11106	TV House Spectator	\N	\N	T1212	S1236	adcb4317a0ab881a75d8eb3560fa70e1
61473	Bill Graves	\N	\N	B4261	G612	d3ffa43e7120b16f049f3fada1440315
61016	Asif Hussain	\N	\N	A2125	H25	0ab429d515348937eeee75b2f8739c45
37850	Bill Watson	\N	\N	B4325	W325	34a392415554ca7b7f8dcdcb9e8e68ab
17596	Sports Announcer	\N	\N	S1632	A526	23cd46ad8b190c8fde52618e5c22c9f8
50247	Rouquin	\N	\N	R25	\N	e9916a3ba480259a7dbf2d97450084f0
98035	Grüne Polizei 2	\N	\N	G6514	\N	4f6239ae1af33643eeb3378fbcd3f4c2
63509	Henry Longstreet	\N	\N	H5645	L5236	c9f51fabdc859cf958bd5d1803cff632
65813	Brooklyn Neighbor - Local Street Pedestrian	\N	\N	B6245	P3236	7867e4821be536a28c1c087f1bb65f6f
67768	Crime Scene Witness	\N	\N	C6525	W352	c22c3346b8011dcb27aa7df83b62b1f7
18878	Fletcher, the Chaplain	\N	\N	F4326	C145	12bb0b66f1378fae15d9475235e87087
23642	Kodok	\N	\N	K32	\N	c83defbec18ab1deec1ec9c00c91caab
36290	Raoul Rodriguez	\N	\N	R4636	R362	4150accd5a84f1a2aa7a40868c9b0422
42525	German Storm Trooper	\N	\N	G6523	T616	adc2e752133a4f1bfcb5487d0443af55
35756	Ayudante Dr. Atlas	\N	\N	A3536	A342	43840535b5b7ac199cbbaf18a39db6af
97924	Guy at Airport	\N	\N	G3616	A6163	38f25e4066831093588f5bc82894cfde
70565	Alex Boy	\N	\N	A421	B	ebbd30d8f252886172527c9c29ac86fb
36705	Benito Cocos	\N	\N	B532	C2	87f7c676ec32788e84842ca49e780516
99874	Simon McNeal	\N	\N	S5254	M254	5537a8b40bc0e3e274f31b2cf4801de8
30209	Himself - 1st Overall Pick	\N	\N	H5241	P2	c507848573cfdefd696c691a652be619
93357	Dr. Potter	\N	\N	D6136	P36	705e82b738e440d9db3f2037fd6a635d
68033	Bomb Squad Member	\N	\N	B5123	M516	97c81ae3cf18969ed25a50a04196fd3e
94473	Dr. Moyer	\N	\N	D656	M6	fe5e9905e00e0521625b1b90903f6960
90629	Drzavni kancelar Sovaz	\N	\N	D6215	S12	1ef7f4982d8dbdf658bd27b93e84de15
16415	Romeo the Clown	\N	\N	R5324	C45	cc997b7970cd5ad173d124e04b91c1d9
78370	Sindaco	\N	\N	S532	\N	771b65601d3bdef95d91297d05f7ce83
51475	Prosecuter	\N	\N	P6236	\N	10539ec10325f8f5463224093b0cef1f
96223	Austin Aries	\N	\N	A2356	A62	4ca41fed549a5c2dae6e36b4931148f6
54823	Neil Fass	\N	\N	N412	F2	7b44df23d933132dea3586b3841fd2c6
84686	Pomocnik masinovodje	\N	\N	P5252	M2513	6d67e108882dbb1242bdfa47edac6305
29962	Detective Nishizawa	\N	\N	D3231	N2	f06434aee757800b7a04246107ee0dea
12230	Vince Frasca	\N	\N	V5216	F62	b38dfdcf5c117e05e8863b303af64dd5
19586	Mr. Hamilton	\N	\N	M6543	H5435	18e8777bd46bfce8e3071f9c44994e53
19382	Jacques, ingénieur son	\N	\N	J2525	S5	12650878f04717781671a23a00e701e4
7790	Jacobson	\N	\N	J2125	\N	b00aac350dde4519da183682afead144
45157	Dr. Subites	\N	\N	D6213	S132	f3a333ecfed3b7dcf34a334511d373d2
61931	Ryuichi Shimomura	\N	\N	R256	S56	ed177c46244592bfd6d4bd5633d62c5d
4428	Abbu's Passenger	\N	\N	A1212	P2526	54a77dee511ad24f0c55f2b02f8cdb5e
79434	Sammy Yoder	\N	\N	S536	Y36	1ad16c5ac3f116882499522163aeb291
62252	Cunha	\N	\N	C5	\N	02196a3ba1122963781738c239e75332
55173	Fruit Thief	\N	\N	F631	T1	3459cd81897b401b37b18b8487eff68e
63532	Diamond Jim Guffy	\N	\N	D5325	G1	41a833a2bf17c177a6df0342365ab567
96549	Tahei Maruko	\N	\N	T562	M62	a49594f5b6da993b1a3a538ade097704
4401	Daryl	\N	\N	D64	\N	75c73135db9b1545fc6773db59734130
24145	Dr. Matt Hastings	\N	\N	D6532	H2352	a0f9c47c7b8b2ee8ba5e0c10fb3f8a30
82216	Patron at Hall #1	\N	\N	P3653	\N	917d022fd2fcc968d8d0389e68209a21
9941	Checkpoint Soldier	\N	\N	C2153	S436	abae538731f8074c0331cdfa86186d5a
77103	Johnny Cleaver	\N	\N	J5241	C416	d233256ab8b62407422908c4bd16e0a3
73119	Mason Nobel	\N	\N	M2514	N14	8bfb62031c3eeece676577186ba3ea25
41903	Himself - Marine Biologist	\N	\N	H5241	B423	4db347d143ef342e839d1b0ff286362b
90933	Onitora	\N	\N	O536	\N	312e69652c7353ca42813218ae8cef6d
61157	Elvis Impersonator	\N	\N	E4125	I5162	42f4db180c60c6b445f25c1c77e95542
29543	Norman Bromley	\N	\N	N6516	B654	82656028349edf0e82babe72d8105d6b
54360	Himself - Presenter: New York Tribute	\N	\N	H5241	T613	5e057a76447d75b67cd80c1dd43c5ce7
51841	Dan Marshall	\N	\N	D5624	M624	b46bd0a58be21773047c8fe7836165f9
76636	Mayor Robert Chisholm	\N	\N	M6163	C245	66b7b85e8a22664453b9c24b6de528fe
57229	Mike Esperanza	\N	\N	M2165	E2165	670f2566081a76c4502a00d8cc6385cd
13695	Band Musician	\N	\N	B5352	M25	6152bd41100dffe1c0b63d149c9c4d00
20660	Jemarcus Kessler	\N	\N	J5624	K246	3cca2660d3ed81af87d49172e0b1d5c7
25841	Loner kid	\N	\N	L5623	K3	ba90e5b26e2c4008aa292d373eedeefd
17915	Lieutenant Clarence McKenzie	\N	\N	L3532	M252	dabf9b42dfdec66eb689558bc105b497
85731	Alexis 'Ariel' Platonidis	\N	\N	A4264	P4353	26346e82277f3a7e8505d5a70bfb43ca
33656	Serge Klarsfeld	\N	\N	S6246	K4621	cc674f38f68b2bc1e02abb54302621f7
53186	Marty Allen	\N	\N	M6345	A45	da7a65940f7dd445e5196801a70b48c3
5393	Upscale Business Client	\N	\N	U1241	C453	d8797d9db7203bf67a659882d1817980
15738	Third Referee	\N	\N	T6361	R16	980f1f47131e3a60c70c61f27f27ebc0
82925	Sim Portfield	\N	\N	S5163	P6314	7f4fd39e5d3e1a7b1b85b6be3af46dd6
74784	Bando I	\N	\N	B53	I	ddcbe224f43ffb89b17a9ae576fc0b4b
28188	Mini Mart Owner	\N	\N	M5635	O56	c1fae76fc637b6c9997da97a82fc316b
40621	Himself - Bass musician	\N	\N	H5241	M25	7990bb0c865238ba31648e36b6ee014a
88517	Carl Moll	\N	\N	C6454	M4	6ec125a36c74e6d32526f3ce4679a0ef
12520	Don Balthazar Lopez, Ehemann	\N	\N	D5143	E5	4f0e838277631ee1084a8dd2c25a4075
88913	Peter Webb	\N	\N	P361	W1	01a78520f48622c69930b5e555fcb2d7
35280	Jason Bagwell	\N	\N	J2512	B24	c51bd5c7904c4f7c6166c825eacbca43
12253	Katherine Wentworth's Attorney	\N	\N	K3653	A365	bb2bb1dfe1dac600787053d70c5e8e8b
29637	Noel Ross	\N	\N	N462	R2	3414812e1dcf90601ed299c239b2d5ab
663	Dancer	\N	\N	D526	\N	a4e7ab18a8d310e0e2f6d8a9d17f20f5
91218	Karunan	\N	\N	K65	\N	a8906cbd5e0dfa6a99e503f566c8953e
49510	Senatore	\N	\N	S536	\N	18f8b48b361022970adeafc78bdd071f
92976	Jaba	\N	\N	J1	\N	59409f2a54f35f700642eee81fa1351a
63925	Himself - Citizen Dick	\N	\N	H5241	D2	f2bb70903568ed901c926bfa7614f014
76070	Pirate 1, First Mate, Bartender, Third Mate	\N	\N	P6316	M3	a65a345bb03be25f6fa5fef2a9927e83
13487	Roma's Hoodlum	\N	\N	R5234	H345	3ac28843cf642f98f36cca09aba4b091
85310	Vieux 2 Café Ange	\N	\N	V2152	A52	a2495258963ae6c5df1c20ad4fbefc1e
52223	Mr. Newberry	\N	\N	M6516	N16	f3bbbce6bfa68a199e45ef3d847933b7
88790	Judge Gates	\N	\N	J3232	G32	b0c11d6e6381871ab786f2011aa80236
78402	Sfakostathis	\N	\N	S1232	\N	6ecfa98a29095e91bc89e124b2b3dbb1
87735	John Radford	\N	\N	J5631	R3163	175e59a2b40de04f35fcf8127ca0b25c
13937	Anderson	\N	\N	A5362	\N	b32b1b822dd59451b17b08f97fdfe81e
57840	Jim - Taxicab Driver	\N	\N	J5321	D616	6fbd491c8e09de670d0cfb5c702130ac
15674	Real Howard Foster	\N	\N	R4631	F236	8829ec46f0ab2a9b1fb2a2a89ca2e558
55585	Le President de La Republique	\N	\N	L1623	R142	6a4d97c4944b897d1a6cbdf9643ec429
79950	Georges Banlier	\N	\N	G6215	B546	d4ce02780ad08f96a8f9766d26bec8dc
97166	Poyraz murat	\N	\N	P6256	M63	5a4ba2d7c0399d858397f7dd2cd61479
40146	Congressman Arcado	\N	\N	C5262	A623	e8a129c31b149eb48669e854021bfd8c
94804	Dixi Dolant	\N	\N	D2345	D453	189a0079b5600603181dd82718e2614a
2879	Ambulance Driver	\N	\N	A5145	D616	c168c104b53a221c4b31d19aa6d8b6ce
24171	Dr. Edwards	\N	\N	D6363	E3632	a714180ab9a0518d267d77f64759ea21
91570	The Musician	\N	\N	T525	M25	ed1121f29daaa54c1c75662bf2a76093
95155	Garçon fête foraine	\N	\N	G6513	F65	dceec80d1c726cfc1ec5b703199db43a
21272	Gung-Ho	\N	\N	G52	\N	a9add37e42950a9c7f8294d277780542
58312	Darius I	\N	\N	D62	I	163cac72b844d5ca7865ce7d5c0b8dba
85532	Al Machias	\N	\N	A452	M2	60a8cc07bb3a271e53b0b6e250a541aa
30415	Alexander Trist	\N	\N	A4253	T623	11f0da93191d8e55594330bc8b0187ec
57632	Abanonu	\N	\N	A15	\N	2731a21ee497ba52fa4d548daa8ecf76
47713	Lothar Gansel	\N	\N	L3625	G524	628758df76512f147ff99fec1c4fa1ba
25312	Matt Batterson	\N	\N	M3136	B3625	017660f6d2e33bd277bc8b83efd5d04a
94035	Train Worker	\N	\N	T6562	W626	820b5e82b876769d076e6eae27080d37
98631	Family Car Driver	\N	\N	F5426	D616	1afe876da529fbe888a8db453a409749
40375	Marco Mendoza	\N	\N	M6253	M532	f1f7e1b2cfb0efabce84bd126620ec98
52358	Side Show Barker	\N	\N	S3216	B626	519ce2db099f1d1e21606c3da87db0da
18350	Young Fred	\N	\N	Y5216	F63	aa7188defc6fe0425595ae10bbe2add7
10223	Himself - Eyewitness	\N	\N	H5241	E352	0125b6670ca834fe577c16d364f2f1e4
94402	Djamori	\N	\N	D256	\N	3af3ea9dcaf5e27c597402ca699b5efc
60158	Big Latin Guy	\N	\N	B2435	G	ff0f2f068f33856fc2548792c6aafab1
37638	Vincent Slattery	\N	\N	V5253	S436	34dd24350c4dd32c3b6f7025bc84856d
254	Jamal Aiken	\N	\N	J5425	A25	0216191bfc59386c183650a22dca4055
28228	Land lady's son	\N	\N	L5343	S5	590fe5adb83da2bebec0e2352a8c9088
55074	Mickey Grogan	\N	\N	M2625	G625	1f64246d3eebe752609165cf047669b3
2520	Shihab	\N	\N	S1	\N	e019032a0101075a9f7d46aac2bac297
88384	Demolition Man	\N	\N	D5435	M5	9296e96b63eef194889e414bf92b48e6
87448	Mariano Losada	\N	\N	M6542	L23	943e474c8714c6b7515376fe80acd2eb
77161	Atticus Benedict	\N	\N	A3215	B5323	abd8e2f451f4388e664f5f010e3e5bd7
77689	Detective Owens	\N	\N	D3231	O52	9a1b1e9966a94eb9a61976a8695e17e0
14774	Mr. Bruck	\N	\N	M6162	B62	3b90171dab2624b98a61bcdfc62b1c4c
49097	Fadela	\N	\N	F34	\N	0b5d6998b57625cc19f3c0ce621de5f2
62061	Medico legale	\N	\N	M3242	L24	6eb3ac1cf5eb8a01c760f988e937ced1
11450	Bar Gambler 3	\N	\N	B6251	\N	344d7b2ab165899fd540894d62afb6bb
96369	Patrick Zala	\N	\N	P3624	Z4	8966c8e5d3a80cb6d5de695480d59809
53084	Samuel Hall	\N	\N	S54	H4	8d3a6414703cd05289a8ff09a9260404
37165	Lt. Sforza	\N	\N	L3216	S162	0b60e4ca898e1b1879b2f376c9e70c50
66590	Inspector Erdlatz	\N	\N	I5212	E6343	fdfaad44932f8f578175faa7637ff8c1
16212	Hawkeye	\N	\N	H2	\N	618f709d7fd14196e90a68cfefa884e8
11049	Sanju	\N	\N	S52	\N	8c98b64d58780b75cfdea4b1cb815741
92384	The Bishop Alelfhun	\N	\N	T1214	A415	a452b9e9c4c6ff1bd06ede652f3aa0e5
26034	Simón Blanco	\N	\N	S5145	B452	12a1d74831c41f5add2a9d9ef52a5524
34709	Kopla	\N	\N	K14	\N	9f9c934d8a7029c4bba8c3343a33c384
72695	Professor Jenkins	\N	\N	P6126	J5252	9698051316ec65eed2723cb6c2084425
47426	Kraki	\N	\N	K62	\N	2bf75f81439eb66081c4e9d5b3092cad
10500	Commissario Scialoja	\N	\N	C5262	S242	56816c9b3a496111dfaaa2b216fa7db4
68866	Vogel - Dresser	\N	\N	V2436	D626	6a06e0a232531d6e921a4bf027b1fafb
46247	Sailoor 3	\N	\N	S46	\N	7168c76346eccf236583cc8ce5e10043
15823	1st Footman	\N	\N	S3135	F35	2e9a51ebb81c15aeb73d6e01b34ee696
22353	Joe DIBello	\N	\N	J314	D14	e3c73bc00216218a9bdbe2bfd7168709
47353	Man in 1780 Sequence	\N	\N	M5252	S252	147291613d0fee2fb781aeaac7ad3504
15955	Frank Olsen	\N	\N	F6524	O425	91907b94140b192852f9d2e5d2276a5d
74552	Tony's Henchman	\N	\N	T5252	H525	6d9fed34596ae8c9617bcfa8da054747
86490	Nankim	\N	\N	N525	\N	f78c223db892285fe7c3b9c2b6b8a3f4
6860	Christen Christensen	\N	\N	C6235	\N	d0617647fb4cc08e0dcbf4285b623684
76522	Officer Fromansky	\N	\N	O1261	F652	1cefadbe7cd0c2995e70c8a6c478689c
43122	Bolet Abello	\N	\N	B4314	A14	996244f5fa1985da29679e34e979f81c
36798	Man in Market Place	\N	\N	M5623	P42	05a7e8f007076fe4cebad06fc9bf0b88
7103	Joris	\N	\N	J62	\N	dbbbf01e88f5a5a29574870a32d147b8
36677	Dr. Fred Junker	\N	\N	D6163	J526	03fe1ee572a3e7e1a8db2dfd47798225
43864	Chautard	\N	\N	C363	\N	cfbdf74d8b77453571c14179f7ee5f7e
46019	Henry F. Winterbottom	\N	\N	H5615	W5361	36ac9483e8a8694580bf56fc66065ad6
78705	Kapitein van de rijkswacht	\N	\N	K1351	R23	99e7aff9aeca5357934226be7f9e4379
19842	Dr. Rahm	\N	\N	D65	R5	6bfabf9a849708da4ae98e2d4655d344
58001	Officer William	\N	\N	O1264	W45	e71f75229b5521dae52b36a333ce3bf6
16666	A Painter	\N	\N	A1536	P536	daf0a7b7ebf9a2ca264bc027086777d3
80342	Studio Hand	\N	\N	S353	H53	b39455355ffa882a33867aa8aded128d
28866	Toivo Moisio, \\Topi	\N	\N	T1523	T1	2d91c45a115bf5657f9a41f169c580cb
72152	Ville Vallgren	\N	\N	V4142	V4265	bb233497fc750af71e3f6a8fb1668971
68593	Brudgom i 1910	\N	\N	B6325	\N	0cb2ea2addefd2232304168c50ad06b5
50378	Computer Sparring Partner	\N	\N	C5136	P6356	34344cf2c9cf7b366d91030113c73632
70441	Kohlberg	\N	\N	K4162	\N	540b59b61f07d8218ac8a390e56e286e
89415	Norman 'Oman' Fidel Gonzales	\N	\N	N6513	G5242	aeb5cfe73249fe91e0ae98fb91bcc6ac
19849	Jack - the Super	\N	\N	J2321	S16	1068a170086d5f03db9b8886947dc53f
76472	Paul Oakland	\N	\N	P4245	O2453	8923cb7d606b60f6141e59c47fc766e0
94171	Cluster Gunman	\N	\N	C4236	G5	839d40aba14cf3823339557541dea1c2
77552	Frank, Bakery Foreman	\N	\N	F6521	F65	738954cf802c1ee5db8b05c84add651a
42646	Volney Davis	\N	\N	V4531	D12	1616832f2766b35386dca494c385371b
556	Donovan	\N	\N	D515	\N	dda986adac80c4de1fbbadebf8b451c5
92275	Marc Painchaud	\N	\N	M6215	P523	c4ac2b8f696a798bbdebc828cf95b295
82426	Construction - Worker	\N	\N	C5236	W626	17f8234078a25f8d4429551cbe342b85
35763	Kloster	\N	\N	K4236	\N	b2bd99b0d9c1a5b8ca535d7e5ddf2895
67505	New York Anchor	\N	\N	N6252	A526	7a1855bef2bde1a5aa29661c6ad5a86c
92229	Evil Spanish Lieutenant	\N	\N	E1421	L353	ce59402375f0fd7418813ecc4506612e
90153	Torakichi Awa	\N	\N	T62	A	972cac40b016d2f1d04d5d948138cf75
93065	Man at Church	\N	\N	M5326	C62	6cfca265b8701694a184d9af9c861821
58574	Lord Arthur Savile	\N	\N	L6363	S14	eaf9effca0abf0780bc8606e073cce5e
12614	Frontiersman	\N	\N	F6536	\N	c9e314c5efaefcef2e9e7ada055c96b8
24981	Donnie's Mother	\N	\N	D5253	M36	d7777e90d35a9043c1ecced3ace75ae3
34602	Mehmet Ali 'Memoli'	\N	\N	M5345	M54	a8f768d5fb187941c81899cc96128220
12531	Don Curliss	\N	\N	D5264	C642	061266f5f2e042ef9f755e8a8f9ba289
42682	Camera man	\N	\N	C565	M5	a4e0d3d59b86e8aa6e69b7b6261b7eb5
57659	Pierce McClintock	\N	\N	P6252	M2453	5ffe6a895fa07e411b740850773fc394
96156	Jeune dans la rue Marseille	\N	\N	J5352	M624	88374ccd4c53d7c0a28424d7fbfa9832
82111	Basov	\N	\N	B21	\N	6858e89a5d9a5c8ae85149361a78a352
90839	Lucas George	\N	\N	L262	G62	370824ef1e52025220b9bbdc9dc3a0cf
31347	Neighbor One	\N	\N	N2165	O5	f35750d4ab67c831ad9b4652ef3da68e
66166	Black Michael	\N	\N	B4252	M24	66247c9ef5b795ca942c7a1547cd10d9
7067	Sir Henry Mordaunt	\N	\N	S6565	M6353	facbbe80a80a50eab9a98f6dd7d4af98
88109	Zenész	\N	\N	Z52	\N	25cdc164a722c0c0bd852df2a50793b9
70625	The Sweetheart	\N	\N	T2363	S363	f797b8fda0d4b62bc4b9ada9c2c0edb5
62329	Funcionário #4	\N	\N	F5256	\N	b0e3b1fb4ff72ac41133f055aad4fb32
62328	Funcionário #5	\N	\N	F5256	\N	f964fb0faea264bb2c605f2e0dda4f5e
10955	Spoken Word Poet	\N	\N	S1256	P3	5196cfcb0987429f024250a597ecb69e
96239	Dirjo	\N	\N	D62	\N	d442f168d253fb95415870d274a20c75
16130	Henchman Joe	\N	\N	H5252	J	f5f574412340383f9d06a200ab7ec54a
51724	Robbery Victim	\N	\N	R1612	V235	eaeeeac0eacd8f15c7fd9e9d1aa6c19b
25044	Himself - Physicist	\N	\N	H5241	P23	1f88c9812620aa3f159c802504f86b59
23040	Dr. Biscow	\N	\N	D612	B2	94655ce98342f53228b46fcc7c5524af
41866	Second death row guard	\N	\N	S2536	G63	0562624325e1825ac38ee37e55367d81
89395	Atty. Barredo	\N	\N	A3163	B63	2fd4f394c6153d4bb96b5ff44cda1e31
60217	Dr. Cherian	\N	\N	D6265	C65	26fc21944ead54de676ffd24993e5826
16249	Stage Passenger	\N	\N	S3212	P2526	693bb1ce6278f6d928bf73043ce105dc
13994	April's Brother	\N	\N	A1642	B636	e765e8c4f4d920c49ffe149cf4ab7891
22096	Presentator	\N	\N	P6253	\N	1e0164e8554fe40b90542de109400715
86424	2nd Worker	\N	\N	N3626	W626	5c57350274a1b44aff22a1e042a224f0
19310	Kenner	\N	\N	K56	\N	5d7d2a9ec76ab476aa87fde52c655c08
9607	Foster's Guests	\N	\N	F2362	G232	f9b4b1bb46e7bf86588fb94303277dc9
15643	Amerikanischer Soldat	\N	\N	A5625	S43	54bb9032536b4d86ae9fbc63bc97a501
48352	Mr. Nasser	\N	\N	M6526	N26	80bdbcb43c53782e7fa3e88317c342ec
63724	Patron in Coffee Shop	\N	\N	P3652	S1	42c08d0294714095bf079f1b5f733e5d
1226	Jacob Campbell	\N	\N	J2125	C514	7dac2ed7ee6acd9054b1f87f07737680
99241	Michael Biddle	\N	\N	M2413	B34	f5a9c86fc813d2356d9ca649817cfd2b
9156	Participante do concurso de fantasia	\N	\N	P6321	F532	8d8a90f08ecde880fc537991023732e8
86691	Seisuke	\N	\N	S2	\N	af5edfb09fa1450aeaa9c670a5516896
61748	Rafael Torres	\N	\N	R1436	T62	e1558f58597f086b07b0bf45ced50e30
54545	Maj. Brandt	\N	\N	M2165	B653	cd6fb684c18be3802816bb4657cd7af8
46803	Heraklides, Roman	\N	\N	H6243	R5	1a588251a6e2b802ec5e77e5c3e8f0d9
28172	Cuban Taxi Driver	\N	\N	C1532	D616	dba60a0c471b8dab9c4b040c9254c4f6
83124	Leibbrant's trainer	\N	\N	L1653	T656	f6f16019573c9d968df028dad6ed9a74
98108	El Mayor	\N	\N	E456	M6	7d7d89320de263bf09ff2e9616697a2f
10426	Verges	\N	\N	V62	\N	88443d84f841946dc2f82453cb46128d
48278	Verger	\N	\N	V626	\N	c3d021ddbf0ad4b9ac11fe20d8d8f0d9
46049	Professor Millhouse	\N	\N	P6126	M42	e514dd6d5d9278f55bf19e1b644a92da
69023	Door Zombie	\N	\N	D6251	Z51	0613d29be38407724f84d0b56b38e3e8
68342	Junger Adeliger, Albrechts Freund and Hexe #5	\N	\N	J5263	\N	b61c9db1f8a028fd91b7e06be01d388e
18620	Earthly Vampire	\N	\N	E6341	V516	26f1a348f8bd98c45d18e24817744b95
37486	Ein Offizier	\N	\N	E5126	O126	2b6e0e64dd972485a59264b6844c8214
92029	La tierce	\N	\N	L362	T62	7dd39699a75be63ab70a5d3d7b4c8f38
65574	Bruce Singer	\N	\N	B6252	S526	cc8bc60e6f0b17c0a3632a9e563758ad
900	Arthur Shaw	\N	\N	A6362	S	0d8ad0c2529fd8106f2bb4464bc029bd
80008	Lo sposino	\N	\N	L2125	S125	ede4c77e7f7e9a1cbbbf3a96ba51e1d1
18238	Hickey	\N	\N	H2	\N	267a89e0b31795bcef0db4339d800d2c
17135	Henry D. Hyde	\N	\N	H563	H3	bd439a1732be8ccfa185bf31efe5cab5
46077	Supervisor Phil	\N	\N	S1612	P4	3cc35a2b4973fe71fd219a3ffda564e0
80219	Officer Widener	\N	\N	O1263	W356	e69b76f00d7bf15268bfcaede20048af
18687	Congressman Mack	\N	\N	C5262	M2	4b5ee5631b72586a8eac35bf2048523d
99811	Pale White British Guy	\N	\N	P4316	G	b01747c6979b8fad572c3791fa7b4cd7
864	Detective 'Bull' Sykes	\N	\N	D3231	S2	97218a09257a213b43a85b59b5dbbbdd
84118	Mr. Cooney	\N	\N	M625	C5	8bcc01148da59571a961830b78c9c98a
75359	Evgeni	\N	\N	E125	\N	f714c9e5ec5a7f13a465b0e01c801045
1271	Oscar	\N	\N	O26	\N	48a0572e6e7cfc81b428b18da87cf613
71653	Lenny Banks	\N	\N	L5152	B52	0fe28984a110a481dfffad76e492a4e6
91148	Suelaespuma	\N	\N	S4215	\N	1fe4186aa489e911f6fea64379a2e598
27092	Himself - Guest Comic	\N	\N	H5241	C52	73e6ca43be8b046e6f4d0fc52deb598d
18993	Evgeny	\N	\N	E125	\N	74f5ff454add5793e85c2e75709e75cb
38781	Jim O'Neal	\N	\N	J54	O54	cdf7af7e14f107c803a5c4c679a9353c
36295	Beaver Policeman	\N	\N	B1614	P425	eb9e4ae244adc3a4a5f76527f1ca05cb
41645	Shugo	\N	\N	S2	\N	81b8f436973b3d73a4b6773d6d3a177d
37002	Soysoy	\N	\N	S2	\N	058ed3ab9a12e4cd54fa9189bcd231e3
60173	Claudinês Alvarenga	\N	\N	C4352	A4165	47671189a9d7f5ec5827a4e675268a22
23533	Himself - Presenter: Cecil B. DeMille Award	\N	\N	H5241	A63	a33940d14d5048b5950d7d7610540eb2
16280	Himself - Dallas Cowboys Left Tackle	\N	\N	H5241	T24	5000b2add0a1f3714b3991c5b879d3c1
33469	Quickie	\N	\N	Q2	\N	57508463dc24b06406288d82ede02d3d
43109	Kung Fu Hit Man	\N	\N	K5213	M5	f5eb56252022772d3d88a56fe619eb43
28309	Dr Boban	\N	\N	D615	B15	5119c95eb936269f37b9b2558f0ee9d7
443	Voice of Tasia	\N	\N	V2132	T2	6d032e176c78c12fd3019ea2bdb21537
829	Brenda	\N	\N	B653	\N	51c75f94a84470f6ae7d4e511ea2597f
13069	Policía #1	\N	\N	P42	\N	6c9148a3a2bed0fd91ea6cfedaa9d9ec
56434	Policía #4	\N	\N	P42	\N	4151130a59b73443a7076db4bdf59131
92503	Homme couple 2	\N	\N	H5214	\N	15e707a8a04e4071d5e97e708385646f
4339	Gangster Lui	\N	\N	G5236	L	e4b7f35ef4fcee89db5bc800dfc23789
1451	Ellingsen	\N	\N	E4525	\N	02d58197ce3eac2c5f5e3ad14a4e7791
86069	Framer	\N	\N	F656	\N	0df10fc145be1e5c3fe6535066b7d7f8
69103	Swedish	\N	\N	S32	\N	41171a0fcd362ce98b5f0f11398713b6
31706	Mathéo	\N	\N	M3	\N	2eb9ba676677383f40fe1edb2e71bf53
29614	Dr. Mason Collella	\N	\N	D6525	C4	ed679e1892df5d621968ee1cac144524
40153	Daniel Whistler	\N	\N	D5423	W2346	f1541c5146875d39e895ffc2577688e1
30673	Sir Geoffrey Pomfret	\N	\N	S6216	P5163	8a9f2352a874b4551cb488f6a49d8a2b
68601	Sufflør Sørensen	\N	\N	S1462	S6525	cf99386dfb3c4c55a562b5fed3a46914
86545	Omer Jarrah	\N	\N	O5626	J6	c4b8f78729773c6fed611d8f9c1fda1e
48670	Armaan Sinha	\N	\N	A6525	S5	2323cae8582e0daf5f3916964ade02a4
57257	Don Lucio	\N	\N	D542	L2	4c7467b5991a5c07e7264e30ce5607fd
32454	Saja	\N	\N	S2	\N	5048cf8d53c092a2ff7dd29dc268d97c
94743	Dr. Shiller	\N	\N	D6246	S46	5a4149b6ba5eeb4d5e8da50d4ab4419a
12885	Pacheo	\N	\N	P2	\N	ffaf9bd7c82d793754f64497f2347fdf
94911	Jimmy Dayton	\N	\N	J535	D35	9af51ae901c13de3383124028480d3eb
36830	Cetto La Qualunque	\N	\N	C3424	Q452	11563f84f0813187ee518aee60c96fd7
49208	General Zaki	\N	\N	G5642	Z2	9e076be16568186f9d4106dc03b811cc
68039	RL7	\N	\N	R4	\N	06490edc79fa09e0b1b9ec9a00c2a6f5
1219	Bar Patron	\N	\N	B6136	P365	6b8def23c4524ed79172d646428f4bc8
18249	Walt Daggett	\N	\N	W4323	D23	37428d2501568bdd5df135edb78b39a8
23523	Rudy Duncan	\N	\N	R3525	D525	4b02fbd76ff74246d79aaa61ae5fc167
99065	Sgt. Nillson	\N	\N	S2354	N425	0c771d84c56a05644f41030ef2627785
61666	Enrique Valle	\N	\N	E5621	V4	4e5685af2cdedfa032b9663b84ee7c06
59592	Carl Williams	\N	\N	C6452	W452	45b09965f9ebb0f00e06f160e0ed967b
78525	Bahnschutz	\N	\N	B5232	\N	40962b017d0a21526e0b7aa962910b33
17227	Gen. Kiggell	\N	\N	G524	K24	7f5baf2b54284c60d670e8b317897bbe
21139	Pig Driver	\N	\N	P2361	D616	a462c4f8561ad28488e80518b1dcf4ae
98945	Bajoran Bureaucrat	\N	\N	B2651	B6263	2ae062805d01dc6e0ce86f9c3c4082f1
18705	Director #2	\N	\N	D6236	\N	9cab23b60343e4905c03f18ceb2564de
40633	Bronko Negro	\N	\N	B6525	N26	882055a8bb630a914cb3d13e4140b516
85303	Mike O'Donnell	\N	\N	M2354	O354	8ce26e37c4ad1775d4b6791b9a7994fd
72413	One of the Hollywood Jitterbugs	\N	\N	O5134	J3612	2e9230f71d5ff7bff9e6b9faaa64d9a6
490	Jernbanearbejder	\N	\N	J6515	\N	d99bea9b56ff0ac41911cc187ce13f7a
63184	Jason Sorrell	\N	\N	J2526	S64	f88605c4657b8956bdf55f0f352a5469
89788	Jimboy	\N	\N	J51	\N	15127b4348355edff161d23b479a4163
27747	Gustav Lindberg	\N	\N	G2314	L5316	334af41069d2d6e26f07af4b1cc81737
88300	Ariton	\N	\N	A635	\N	1d157aa4d882e2783f055b5a4610c585
7856	Guruji	\N	\N	G62	\N	1967c38464291ecee60b0cf790d891cf
72171	FBI Field Agent	\N	\N	F1432	A253	6bd073b88f7110b72003171d7fe1b2d3
55511	Dr. Fransiscus	\N	\N	D6165	F652	33a11262fc0b1ff566b0e2151ec74c56
53209	Stewie	\N	\N	S3	\N	b4eed5a89f11670e6c411cab8aa2b5a7
39593	John Micklin	\N	\N	J5245	M245	dc9384c8422bdb8a86df4e799f36f3c4
78925	Calle	\N	\N	C4	\N	e4913845c0623c6fac379335b3ed12dd
50813	Himself - Milwaukee Brewers Catcher	\N	\N	H5241	C326	649c3ca2bb4aae41dbffe14cc15ca28e
83194	Abdel, volain musulman	\N	\N	A1341	M245	30e3996907deecf9e7c2eec947149ddf
16094	Diner Who Gets Indigestion	\N	\N	D5623	I5323	131db8121cb170f4083dd419f7a9d344
24964	Dave Markham	\N	\N	D1562	M625	52349d9b0af8e6b98be717c4add7b92d
68290	Jozsef Jaszi	\N	\N	J212	J2	ef3a484f6217a0e936740ae01bcb10b9
6060	Bait Show Owner	\N	\N	B3256	O56	2ba3c47cc3a1cbcc41f18be7250234ff
19523	Captain #1	\N	\N	C135	\N	926ce525c14867d609d807eeb51b0d31
92077	Frate Francesco	\N	\N	F6316	F652	682114e6a07fc8241c25a4e5ac1c0a6b
1131	Right Fielder	\N	\N	R2314	F436	ecfdde5725e78b359ac6b207e9634baf
67623	Monglat	\N	\N	M5243	\N	33bc023bfbcbf8bbeab6a26c3a2774eb
6461	Figurants	\N	\N	F2653	\N	3c776a721f5ba249f490547d95542fc8
88432	Glen dennis	\N	\N	G4535	D52	240152d8dd0c7bf79fc6ea1ad3ab6b4e
416	Et spøkelse	\N	\N	E3212	S1242	bef7b7f192f1a02a997b5669ada7dfb3
36008	Boy in airport	\N	\N	B5616	A6163	b7c10ff9a69535d43a838b7d360d7fcc
22023	Little Girl 1	\N	\N	L3426	\N	284ad9772912dde77686764afdd519da
44568	Michael Miller	\N	\N	M2454	M46	217d4667b5ae747fcb927d00f7f4b8d3
31037	Pan Ferdinandi	\N	\N	P5163	F6353	0b55317056556662dbefd3213df8ef66
26214	Figurante	\N	\N	F2653	\N	9d0dee77fdc87761102f3c3634fb0192
78454	Timmy Cummings	\N	\N	T5252	C52	ecfdc5f4d95cf266cf2ef0adca861d99
66154	Benavidez, le patron du bistrot	\N	\N	B5132	B2363	be5ef87c7d19fe6595e69c9ffc81ffd2
7233	Shopkeeper	\N	\N	S1216	\N	c5e04823df20dae75a3b7c1af0731499
60658	Tom John	\N	\N	T525	J5	3062e161bd26fa7e39edff630181a5d7
93356	Foreman of the Jury	\N	\N	F6513	J6	f422bc2ecef5d62996a2a684ad697268
83271	Man ordering 'Santa Claus'	\N	\N	M5636	C42	0b13a81198f84cf18d150a3b7fdadb66
73027	Alex Holmes	\N	\N	A4245	H452	012ad2c0c2d1aa16152ff4555c6e0db3
13148	Valdez	\N	\N	V432	\N	4180a67bfc07f45de25fc7dad457c556
80866	John Merrick	\N	\N	J562	M62	ad8b78582926cbd587e982fee7c4953a
92093	Colombiano	\N	\N	C4515	\N	f80e36de4461f00bda2f3b22633867fd
41812	Phil Latio	\N	\N	P43	L3	c40781c72d80360d31460f5329670310
15410	Older Brother	\N	\N	O4361	B636	1ea1065c476959a411d400b4f582b0d0
2646	The Banker	\N	\N	T1526	B526	adfd64c6722d671a551786e11033768b
59157	Ambro Trader	\N	\N	A5163	T636	7a2b257992100caae83d14a21493289d
27209	David Ashe	\N	\N	D132	A2	1d329b4bcb7d1af57e14db737d238001
71927	Master of Caius	\N	\N	M2361	C2	cb01c8bcd4e67232bb05b0767bb83fcb
33500	Ilyas Yilmaz	\N	\N	I4245	Y452	92ed984be42423a00ecba38b938559fe
70481	Francis Sheehy Skeffington	\N	\N	F6521	S2152	39ec1ddfacd7e2db957a7ac742f54e13
70353	Neikrong	\N	\N	N2652	\N	2de5bb9a646b7da86240b0ebb70c9517
15836	Maxwell Smart	\N	\N	M2425	S563	b82b49113467763d456e0515ea215937
84	Diederick van Haerlem	\N	\N	D3621	H645	69e3db61d031f27d347c1a2c1297e7be
63794	Il controllore di volo	\N	\N	I4253	V4	aa5c5047e1ab96243edeb7b8f07e4f97
80143	Markos	\N	\N	M62	\N	a7a74a15180531807c6d049e3d1817f8
5735	Warren Doyle	\N	\N	W6534	D4	bc1b74cff29b17c71e925407bde936d0
29960	Endo	\N	\N	E53	\N	b38374740c5a20c730791614d09e8462
47652	Lead Golfer	\N	\N	L3241	G416	d9551abd0268cfdb0c30deeb81499219
86495	Anup király	\N	\N	A5126	K64	fade9b58be5267ce9e5129d5118876c9
31847	Akira Takano	\N	\N	A2632	T25	aac2f4d58447d42a3fa82bd92f80e3c9
78851	Himself - Aelita's Father	\N	\N	H5241	F36	520f153c83da2c962de36b27e1e72a75
25572	Captain Brennan	\N	\N	C1351	B65	9c2acf404bb318f27cad23adc49e4613
22238	Albert Lysvik	\N	\N	A4163	L212	a5f5dc9955b3744a8582ed20b82e788f
71275	Plough boy	\N	\N	P421	B	5f0271bac634df02ebd5c72934c8f794
23233	Von Richthoffen	\N	\N	V5623	R2315	b3bf026b8adf8f9fa1117d5b5a7a0b06
92663	Walter Light	\N	\N	W4364	L23	65a0931cee7da9eb6187c2554701b660
60307	Santiago Robles	\N	\N	S5326	R142	fdf204a3faf95618f6db1e67fa54963b
73514	Gambler Ghoul	\N	\N	G5146	G4	f8521df4ac11871eff58aab1874e236e
96214	Udi Tzirlyn	\N	\N	U3264	T2645	5113697e1bfaf7cbd435f3461d546e6b
49602	Atabek	\N	\N	A312	\N	dbdaa320de1abebf4bbf9791ddc800c4
50782	Himself - jockey	\N	\N	H5241	J2	de4950c309e88b66a4e366398274a041
94028	Mr. João	\N	\N	M62	J	6d4228676b14e5df05d7fa167f87688d
35189	Yaren	\N	\N	Y65	\N	6fb0ebc3b23c927184376723f7466c3d
50970	Himself - Author 'Thread of Deceit'	\N	\N	H5241	D23	5a0a0483be8627790f59218180df93e7
45516	Jaye	\N	\N	J	\N	2c52dec74716ecfc20dc027b8cffaa72
68653	Himself - De Nattergale's Ex-Manager	\N	\N	H5241	E2526	22452df04708e409ef17dce6050c290f
49507	Jean Dechamps	\N	\N	J5325	D2512	44c36d1682d1ff23ef3f9bd74146140e
57652	Sam Polvino	\N	\N	S5141	P415	426077c6b495923fa3e1b893b571306f
8737	Otets Ivana	\N	\N	O3215	I15	8ef0e8bde65e3cfe0b1787ec6a8e5656
12381	Lucien Trumbo	\N	\N	L2536	T651	09627eea51485756c2563ba622925edd
45529	Himself - Roastmaster	\N	\N	H5241	R2352	5b4a03754245defe8c674a1c8286f7a0
41210	Felipe Landín	\N	\N	F4145	L535	798dcf8582c224b030c778c838fddd3e
9476	Laurent Marquet	\N	\N	L6535	M623	c36b483605c4fb52819fdbb579745478
64004	Omar Billah	\N	\N	O5614	B4	420fd23d21554ed59573da158d46580f
34019	Himself - Auteur, Geeft Lezingen in Gevangenis	\N	\N	H5241	G1525	dfe90755a17de4a197130d26b1e03a70
97848	Bjørn Ruud	\N	\N	B2656	R3	5d619a001e735e707777c9a193056337
15412	D-Ray Drummond	\N	\N	D6365	D653	533917ed859426b1a75d67544b248350
2687	Bible Study Guy	\N	\N	B1423	G	18565b86f0cac62bebaf16912eb6dd47
63390	Iskolaszolga	\N	\N	I2424	\N	149155e82c3c79495f596a209e59af48
54847	Röde Börje	\N	\N	R3162	B62	8612945868524a4e77ff405140e36d5a
9713	Le voisin	\N	\N	L125	V25	a5145a2cbf4eba99405a1127d8e50597
61645	Taleb	\N	\N	T41	\N	6fd8f8cea133c6736685457e5fbe68a5
29947	Fukuda	\N	\N	F23	\N	43c62c066ecfbe1b9a96029799532697
97892	Cheesy Fingers	\N	\N	C2152	F5262	0316497ea6ce421019a5b89b3d95048e
67978	Chicken customer	\N	\N	C2523	C2356	1a60b500b96ddee2e876fb134544fc96
3306	Simon Burley	\N	\N	S5164	B64	5c3f9c03892ae8c2b9b7401d75e08cf6
85190	Primul bäiat vesel	\N	\N	P6541	V24	7e6d57ceeaa8a55ea74444e49d6fb26f
84325	Proving Spectator	\N	\N	P6152	S1236	35b8a870547bfe5d9c08a701476e5d41
37828	Howard Reynolds	\N	\N	H6365	R5432	6f091938a632c5baeed8d0e5e266ac5c
62246	Ricardo Moura Bastos	\N	\N	R2635	B232	fd6a5f317e31a52cccaef7dd2a93ca79
44729	Johnny Cage	\N	\N	J52	C2	eb1985494a8b411750bf5e5b6478097a
6500	Businessman at Fight	\N	\N	B2525	F23	1dbf5b0517cc47fa3ac113ef7a745734
1437	Robert Westerlie	\N	\N	R1632	W2364	5f79aa70509959f414449530fcb1122a
4766	Isami Kondo	\N	\N	I2525	K53	2d3f38452f8dc272ae1e57efface8b1e
2107	Orso, the desertor	\N	\N	O6232	D2636	1f6692198cd503b61e3aeca3b83b2338
40665	Zellor	\N	\N	Z46	\N	ec3493edad8dc9bfe33c1a199f6f1289
44064	Himself - Trombone	\N	\N	H5241	T6515	c6f0e5a68c4560b3a3f421b31a91053a
17146	Father Francis Ryan	\N	\N	F3616	R5	eb1b61d307b22d32b39f777e1548be7f
30487	Detective in Garda Station	\N	\N	D3231	S35	0d8715c0af180b79d71f33aa7cf050d7
89396	Francine's Father	\N	\N	F6525	F36	437780c1c3b46791b18dd1f487a518e1
2852	Himself - Founder at Zilver Innovation	\N	\N	H5241	I5135	789e3c29a0974ccd90d112688b3cfb54
20542	Le gagnant	\N	\N	L253	G253	e4f14291fa7add58f73e9e412824fac6
52457	Melbourne	\N	\N	M4165	\N	7c885b9c7c703a77befcabeea54944d5
96212	Ido	\N	\N	I3	\N	c5a448bee702572eecd8f5cb81576e85
72280	Ronnie Gittridge	\N	\N	R5236	G3632	56277ffaad71d51f5598f7de0fddde63
72937	Schakelton	\N	\N	S2435	\N	847506c181ba52314d1bf972975634f3
36530	Mayor Virgilio Robles	\N	\N	M6162	R142	36f698adb28c70da020c7fac0fb79e4c
96838	Khalife	\N	\N	K41	\N	8eb36941a8b5a1858b996ed397b715b8
70825	Frank Doty	\N	\N	F6523	D3	5564afe40e0381491327229aad41d48e
74374	Lawrence Merrill II	\N	\N	L6525	I	0c92f06cc943eca09fd2251191f0b66c
49735	Jehiel	\N	\N	J4	\N	c4372642baf6af3ed2d16fdd62a811a5
17254	Bus driver	\N	\N	B2361	D616	90fa635ba94c6ce1a80057da50aa8050
52953	D.C. Kray	\N	\N	D26	K6	53f758303351c2ff40bcea52f8b20be3
97961	Damián Valdivieso	\N	\N	D5143	V4312	1498cbd45b6e9a7e1744f47610d4d241
85281	Carrone	\N	\N	C65	\N	e1a32a872e74c31471f0e78087aad004
33611	Tolba	\N	\N	T41	\N	e0088f214e00cf1d13f86b8350b2cb65
51401	S.O.G. #3	\N	\N	S2	\N	962b5f2a1ccb3b5d35b053233a16321c
85584	Agent Vasquez	\N	\N	A2531	V2	e63dc2224736d23d5888c069c81ab42f
42159	Henry Holbrook	\N	\N	H5641	H4162	7860bc5019d22dbce418710ce3098fb8
80324	Judge - Himself	\N	\N	J3252	H5241	6fd68e1c248a93779b0b5f4ff124e828
23548	Himself - Senaste FIlm	\N	\N	H5241	F45	2444b03944a41906b3336517c29a2943
30690	The Bachelor	\N	\N	T1246	B246	33415aac3e1af64634ba6292e751ac10
86412	Chico paciente de Laura y Javier	\N	\N	C2125	J16	c5958dbc523125b20ec0f4fa50a167c9
60851	Menino Maluquinho aos 30 anos	\N	\N	M5425	A52	0186f89a10886d2f6747e3fe62f838b9
69926	Sam [Ch. 1]	\N	\N	S52	\N	f5d9c162149f7d783fbdc696985c5355
37381	The doorman	\N	\N	T365	D65	30792f2dd8f52a9ac130f904b7fdcb0a
73136	Crowther	\N	\N	C636	\N	87d9a9b446942d09cd77ee0a82c91835
16966	Dr. Hugh Annersley	\N	\N	D6256	A5624	bd15898ec895fd51193df65d3e6abaf1
30629	Himself - Investigator	\N	\N	H5241	I5123	e935768bdb999ca85e73775568c5d026
36872	Parking Lot Attendant	\N	\N	P6252	A3535	0559739893c31fb05ea48721821c67f1
38635	Robert Lewis	\N	\N	R1634	L2	0f3118e56f2fba3156275132f5128043
20452	Le médecin légiste	\N	\N	L5325	L23	3ef9903afdbe7b8e2dc50ae784db6511
85955	Eliot Bardsley	\N	\N	E4316	B6324	45319d075d2510fc046a49444b03c869
40871	Home 2	\N	\N	H5	\N	67822da02a86effadbeb559f0bcff397
56792	Man vid roulettbordet i Monte Carlo	\N	\N	M5136	C64	6d888d7f91088d0f07a752e2482ae661
22278	Pjotr Assinimow	\N	\N	P2362	A25	1f5ec521f884bdad87aee42336097812
54021	Himself - Baltimore Ravens Running Back	\N	\N	H5241	B2	25444d9f41b6ed25f95dbd195f7012a1
50324	King Richard II	\N	\N	K5262	I	77480f5537dec0828b1b22e5c1c0714c
11789	Professor Trentwood	\N	\N	P6126	T653	f346ac7e817c0eb82f7c9049ed0e4b32
41555	Tom Hart	\N	\N	T563	H63	3245b0c93c218cbc17dcad5bb0db5af7
12949	Ofelia	\N	\N	O14	\N	def15562b4398d04dbcc5bba7f6c5054
65201	John Thornton	\N	\N	J5365	T6535	5468e60eaf2e2084f7ebedf015d676e6
2766	Leona's father	\N	\N	L5213	F36	9bcf9e9770cce0918dc61eac849b1cbd
7323	Blaubart	\N	\N	B4163	\N	14fe0a5d136970e64310c3b4dffcc679
7032	Ron's Solicitor	\N	\N	R5242	S4236	f8928effa173f2fd4063cea4a4c76a1a
25286	Mandirigma ni Rajah Mangubat	\N	\N	M5362	M5213	56c05ec339ca455694e5d34754948b92
22126	Lars Bläckhorn	\N	\N	L6214	B4265	3985ecda85483a6d0763a3438c9b1663
95170	Joo Si	\N	\N	J2	S	a18efed3606a0f6bad4b5052a08bfd91
64634	Armando Amezaga	\N	\N	A6535	A52	09678b2297bfcf398ac0d4ec5c8d9b9e
93552	Un gardien de prison	\N	\N	U5263	P625	236469cb7b1913d8c66be3b53ec201c7
84465	The Passenger	\N	\N	T1252	P2526	72b4dd0994c888ac76f59a915a5d5c29
32531	Karthik Narayan	\N	\N	K6325	N65	2ec8b293bd8ce6a963b7971b2e71dcaa
9853	Ed Fiore	\N	\N	E316	F6	ab0b7ff9af4f89b8d9cd8e1bd0dab03f
53288	Sodom Citizen	\N	\N	S3523	C325	7b74dacd3dba09827d8d899cecc57d60
55982	Hellman	\N	\N	H45	\N	52479cd93b5d890b33575e978e467c5a
97203	Çakir	\N	\N	A26	\N	11abdd70a1ebc99539de5f308db44c90
71963	Hoon 1	\N	\N	H5	\N	795acad78036891e2a7ca037398b9c2e
37538	Fighting boy	\N	\N	F2352	B	eff09009ed343569ace7271da7fb668f
7206	Sahak	\N	\N	S2	\N	9401ccd8c8aa045ed6b2ec5df8b10fe7
19669	Förolämpad bilförare	\N	\N	F6451	B416	bcb69a03aa398c6688a9a3ed448bef02
70930	Katrina	\N	\N	K365	\N	dd35bebeed59b4118700c0f8c953bdb1
89533	Phillipinischer Matrose #3	\N	\N	P4152	\N	3e473c17818d1f5fd1d57b4d9e17ed15
71019	Adam Roundtree	\N	\N	A3565	R536	c367df4a180436a0fa4f515639b5ed1e
60415	Silvio	\N	\N	S41	\N	38624498699195d17c616d622fb801f0
47789	TV Reporter Henry Alfaro	\N	\N	T1616	A416	10470fc4b16257db5f4346945a264940
66731	Bob Foulon	\N	\N	B145	F45	550cd038ece15f65ed56c8f707bb2d7c
13796	Silvia	\N	\N	S41	\N	68c8f7c3f433b3682d1363312fbacec6
39070	Agent Rosenblüth	\N	\N	A2536	R2514	5350da9aa0ef9030c1163894988f9aa3
1693	Bill Dahmer	\N	\N	B4356	D56	673a04a9c0d2f7fbc3a8e949052df142
83180	Himself - Rescue Ink	\N	\N	H5241	I52	bc18764f6d96fb4bd49761a7f659288a
75691	Lead singer	\N	\N	L3252	S526	42fb01e6ebf4f388251f5ebd8ebd6b41
55817	Jed Collins	\N	\N	J3245	C452	86f8076092c7da468e58478bcb115a13
79527	Marcel Broussard	\N	\N	M6241	B6263	26aa23588def7a1a6396033b95f26fd2
38273	Valerio - l'ami de Piacchi	\N	\N	V4645	P2	19ce09d497edfc617f71c417b6b00b78
52109	Native Drug Seller	\N	\N	N3136	S46	09b4a5d82e7930f9cb8b903ca2fa3125
5799	Le Baron	\N	\N	L165	B65	d6b0182e6f30de0d8c0c685480d36109
55230	Baron Delande	\N	\N	B6534	D453	a3cf0987e67f43fa54bb32875a9262db
52673	Reg Hurst	\N	\N	R2623	H623	0ab29497cf7e54533b79b1616d63787d
4495	300	\N	\N	\N	\N	94f6d7e04a4d452035300f18b984988c
74655	Bottyán	\N	\N	B35	\N	4cc078d4b44768cd2e526b122fa21348
63268	Dr. Finn	\N	\N	D615	F5	d93d0f0a10d98058fb6d5a9d128416cf
81255	Tony Verdeshi	\N	\N	T5163	V632	0c7c7d9d33d23beba9a77096d923362a
50960	Det. Melitti	\N	\N	D3543	M43	c0fa250c8aaeec342a94b5afc2090162
33301	Catbot	\N	\N	C313	\N	61f29214aaee2e4fbc935b3b3763d08c
25696	Mc	\N	\N	M2	\N	ac81adaad0b2a7d6077edd5c319a6048
42602	Kevin Harrison	\N	\N	K1562	H625	f71f81ee3fc134ac32614b64acb023e1
4264	Mo	\N	\N	M	\N	c08df9bb5fb44242a6291b1eee5d09ad
83618	Zweli Kamalo	\N	\N	Z4254	K54	2b25403f4be49944166ae46ff5ef6a4c
45827	1st Customs officer	\N	\N	S3235	O126	d971127ece545ac52ebf9106e1294fdb
40544	Marido de Violeta	\N	\N	M6314	V43	9d3761d8ee8493b6cca8e6d92b209a3e
28921	Ari-Pekka 'AP' Isola	\N	\N	A6121	I24	220ab847c84a5db46d5dc5937b91845e
13120	Gang member	\N	\N	G5251	M516	7295225e852ff8e03a96433da1ce9835
63386	Õrnagy	\N	\N	R52	\N	29a0fe4663d78129bcd17e23bf52a6de
82916	Patron du magasin	\N	\N	P3653	M25	3361ebf43a8472c94e05bdd794fa7b9e
30096	Mullet Boy	\N	\N	M431	B	f05f198209ad70b5d4f2b746bdcfa68c
45498	SouthPark	\N	\N	S3162	\N	d06a731d38a300f5d2538371216628dc
45076	Michael Jackson	\N	\N	M2425	J25	b1d113e11165894fd12c94f2d46eb485
12907	DeSalvo	\N	\N	D241	\N	db7a180a0eda1fa44ae8a8ca0a19fa92
48011	Party Detective	\N	\N	P6323	D3231	df83e9168b05efa8a6f83d70832fa343
2297	Main Character	\N	\N	M5262	C6236	29fafc294d114c242ace8380e4360234
3647	Guard One	\N	\N	G635	O5	a1e764c36dbc8e56659da8def8b43820
16447	MC	\N	\N	M2	\N	92a54b358b4cf53cca4095e4697e1004
70119	Ronald Morgan	\N	\N	R5435	M625	dc330968d4faeba0f1ebf43bf37bcffc
28190	MO	\N	\N	M	\N	eb0459bfce4185888ecf61fb07987581
76677	Ralph Peterson	\N	\N	R4136	P3625	30be5ec7101fdf64a9cd8396ae5d05a1
96278	Müsteri	\N	\N	M236	\N	b07068e1599dbd9159c37546471cbde5
41021	Himself - Winner: Favourite All - Around Male Entertainer and Accepting Favourite TV Comedy	\N	\N	H5241	C53	cd4de461a4694db698f496c972970ac9
66930	Eaash Sharma	\N	\N	E265	S65	4fcb857dd63c70ad039bdb94d0e6e10a
2527	Mirza	\N	\N	M62	\N	69767ef463c93a67989ae0a47642deec
35926	Sylth Vester	\N	\N	S4312	V236	f0ece671979f87ce6fcd959bec57955a
52666	MP	\N	\N	M1	\N	c90a918b859bd1e56cf99af6246b128e
21136	Flack	\N	\N	F42	\N	55a761a62674ffac68343d659c7c4fd1
83926	Flaco	\N	\N	F42	\N	93ee696d7bbb50241d2f589b04d5678f
34176	Himself - Advisor to Saddam Hussein	\N	\N	H5241	H25	e8ffae2910f7fabc506955c8e7c51b55
33431	Make-up artist	\N	\N	M2163	A6323	e580e9fc2d40a46963f498ee044b5307
24453	Dean Young	\N	\N	D52	Y52	2e315b4bff3a0b29959df2d33afc9654
5819	Jaytee	\N	\N	J3	\N	1eb3ade92da0b5e426f0e691d8f8371b
52863	Dave 'Mouse Ear' Smith	\N	\N	D1526	S53	dadd7314dcfb8feea3a2f43c4fc73c86
65030	Le duc d'Anjou	\N	\N	L3235	D52	01f7d5f31511db0b4159f6a9f9ec6d02
29010	Prince Charming #1	\N	\N	P6526	\N	2d7bb2ed305e744c1e6ea0559915d5b1
15324	Steve Bassett	\N	\N	S3123	B23	585788d99c70240706e42d5d278d683c
29081	Actor Audtitioning	\N	\N	A2363	A352	d4e3860309ccce2ef67691647604080b
27264	Fred Shalimar	\N	\N	F6324	S456	7f7b4f98ac91b91d2f6b23166283538e
40642	Fray Pedro	\N	\N	F6136	P36	cc6c95f09095d2e8bc2c8c2494d522e6
58207	Mr. Vernier	\N	\N	M6165	V656	c7f94e2513a26367958b6e5121ab6a3c
78616	Gerardo Murúa	\N	\N	G6356	M6	0cec60bf0a1601571587836fc54da312
31433	The Bug Killing Child	\N	\N	T1245	C43	3faa406d3bcdfce99c5dbb40324d5980
3676	Davidson	\N	\N	D1325	\N	3d7485486e07487a43f99cffe0a0b696
754	Kairamo	\N	\N	K65	\N	03f8819f540d668882fb2b0e11b97617
18031	August	\N	\N	A23	\N	41ba70891fb6f39327d8ccb9b1dafb84
25597	Patrick Pesto	\N	\N	P3621	P23	a6c90cde5799ebea1a9b3a7011273784
95620	Salomón	\N	\N	S45	\N	baca9de21b27caa14ef53353492194cb
14249	Dr. Erazo	\N	\N	D62	E62	63e7351280e84ef47ea4ecab22307f8f
79555	Detective Morley	\N	\N	D3231	M64	8edff9bc905753d87c83a56ea37466ba
60492	Louise's Lover	\N	\N	L2416	L16	4e71eb24227022680fbabd335a899613
51028	Neurological Expert	\N	\N	N6424	E2163	f24d2f14e310f3ba3c1267219cd059c8
24371	Chulo	\N	\N	C4	\N	2e18ffc88ac766e1cf091009118da091
47175	Homem gordo	\N	\N	H5263	G63	8bd5d8e3c5b1d712e2bb90252380d3a3
67391	Member of the Political Council - Islamic Salvation Front - Algeria 1993	\N	\N	M5161	\N	20fb63c6a4ccc640f11d3c73dff39c20
249	Thigo	\N	\N	T2	\N	dca58ceeb2109d3b16f2881fbfd6b3f5
43009	Encargado Pensión	\N	\N	E5262	P525	a289c129da256384fd61aa1ca2339003
45108	Bather	\N	\N	B36	\N	9b679064b82bd08ed3004bfb67896790
60209	Bathes	\N	\N	B32	\N	a539e10824153861d0bc6ff8fa4a2c20
61158	Friend of Marabou	\N	\N	F6531	M61	e6f92f4a32b2a6a3a948255a6b30a46c
26610	Mr. Pine	\N	\N	M615	P5	341d3e6398149bdfb1e44f59b4be3cf7
36680	Victor Müller	\N	\N	V2365	M46	b83665ae724139459739576c6b41e612
91094	Tiliches	\N	\N	T42	\N	fda4a6020dad3407d5907f2cbcf3ea0a
90994	Belfry keeper	\N	\N	B4162	K16	f5abf44e8ce5d9d8d3e4c643ae8e6b52
16744	Dr. Everett V. Scott - A Rival Scientist	\N	\N	D6163	S2532	43e277d4ca506591108b6129974049ec
11951	Bad Luck	\N	\N	B342	L2	fb9292cd5f8445759a17b38296214896
71008	Strong Arm Man	\N	\N	S3652	M5	b3dc6dcdb7a927eaba9cdcb6f82066df
36604	Herr Baumann	\N	\N	H615	B5	df17459f7145c5b2f268ca73d5685d3d
46556	Henchman Waco	\N	\N	H5252	W2	8afecae9609e8d4c3508b54f919c280f
12762	Police official	\N	\N	P4212	O124	88e6c81df33422992c5235950867f996
5892	Detective Ward	\N	\N	D3231	W63	9385d5a74c9665e0b7ee80e0c77eca62
80460	Markeza	\N	\N	M62	\N	3e75622c53250d8a04f5e01a6a2d326a
92951	Rabid Officer	\N	\N	R1312	O126	340ce6c1ec4c7b0316f670c19491cd8d
19325	Billy Bar	\N	\N	B416	B6	68d0fc983ea60199a3d1cd261b276a42
12014	Bijan	\N	\N	B25	\N	a121256c68aa8f553e3150d8b31471e0
96410	Otto Remick	\N	\N	O3652	R52	4bbe03d4965fbee14c3e058f1f5a8abb
29601	Marty Davis	\N	\N	M6312	D12	e04d53b233c2acadd2a6aa051451df13
29982	Shiga	\N	\N	S2	\N	189a2f89d12e8da7178dc63e7a00f339
78772	The Proprietor	\N	\N	T1616	P6163	86fd08728685a62dcacc8d4b664de9d7
63459	Humanoide	\N	\N	H53	\N	17b28e1d5fddeaff976397a1901c3685
90617	Skeledzija	\N	\N	S2432	\N	28b9be09f02d74aadaae1c1647f98996
23646	Youssif Al-Samer	\N	\N	Y2142	A4256	ad24eec238b52b3fde6d158d0090e86d
55766	Det. Lowenstein	\N	\N	D3452	L5235	a3c8694cbc70147de2f4d633ca8794f2
91076	Kimura	\N	\N	K56	\N	caac080f80ad5c0b933f98e5466c311c
40478	DJ Skrollok	\N	\N	D2642	S2642	bae06d577a25daba560e581ec63d9db2
21445	Orange Hat Kid	\N	\N	O6523	K3	777932913ad20084d4b8c81ffefe3caa
30804	Fantastic Max	\N	\N	F5323	M2	2105380d7a32ac76d4ac8382b1982c69
52706	Equipe Du Film	\N	\N	E2131	F45	7b1443ccc99bf59dab9b33638b1977f4
47351	Sergeant Hall	\N	\N	S6253	H4	6d545195910d6ecb9bc41b052e16bb75
72663	Himself - Winner: Special Achievement Award for Sound Effects Editing	\N	\N	H5241	E352	b43a37e4864edfbe67e41c90a3b0d389
11361	Business Manager	\N	\N	B2525	M526	e089b9d49d070ef304c031837ed3440e
26134	Renzo Malatesta	\N	\N	R5254	M4323	864f0d73556e89c2ffe0aa46828f38bc
72203	Louis Botha	\N	\N	L213	B3	7e87f1388eabdce1c7faf1cbb72dadda
42367	Trick of the Night	\N	\N	T6213	N23	bfd5f98386975e1d8918316fe168f293
41257	Model Agent	\N	\N	M3425	A253	03614e78e8fa3e1e326ab53d13a96d74
47932	Giulo Manfredi	\N	\N	G4516	M5163	763f6753627686c0d46013c007de4e04
70955	Dean Mitchell	\N	\N	D5324	M324	bed8a5416d1cc50eed413142864c8174
86685	5 nen 3 kumi Tannin	\N	\N	N5253	T5	170d875c1a87a0a85f31561673dd054f
13293	Frankie Dean	\N	\N	F6523	D5	f3617b187dd0d8dcc4283a5032af64dd
96669	Jorge Cavali	\N	\N	J6214	C14	b2219a68bdabdbba8703b9f9c38e4fa5
5241	Commissaire Corbeau	\N	\N	C5262	C61	cdf22ef390880c42f3f1f7d63c8f414c
79215	Bad butler	\N	\N	B3134	B346	a81576abc1afe0be5fc72e4f0ee7eaa8
39914	Breakdancing Pirate	\N	\N	B6235	P63	eb792c768a08cbbc449e06c135768942
17102	Himself - Darts Champion	\N	\N	H5241	C515	2d2af9105ccf64e3ab2f48ed50dc9c28
78233	College Kid 1	\N	\N	C423	\N	125d2edbd69dd779a05c0d6ec1183317
8933	Nate Glazier	\N	\N	N3242	G426	db78a64c73ad9b50d9fe5aaf471a982f
27180	Young Vinny	\N	\N	Y5215	V5	496ff18efa615c89d57fb9a4cdbed4c4
28802	Kauko	\N	\N	K2	\N	67f889014a114978c17adf0151c69265
99968	Pete Pryor	\N	\N	P316	P6	4a5a8044eeb749cdcd70be47f2cfd20b
52592	Jeff F.	\N	\N	J1	F	0bca760da8c22082f4ba6ba531d847c0
54386	Buffet Chef #1	\N	\N	B1321	\N	e7605c8a174f5340448c5ee183cef900
39416	Wetter	\N	\N	W36	\N	8328b1967c631787cc0a72ff17114b3c
69549	Eliab	\N	\N	E41	\N	5c89711e5db74bd0c6e63b3c12bf8f41
17656	Bowie	\N	\N	B	\N	40f99715cae8218184a6b1adccdbb1e3
20911	Yuri Petrov	\N	\N	Y6136	P361	969510fd235377e6a115cd044d4cdda6
34955	Un fils Follenfant	\N	\N	U5142	F4515	ddd7b25146f5a1005682f5c2bc06fb65
67880	Gunder Forrest	\N	\N	G5361	F623	6c4d8d847a22d51ecb9956e661a12294
85445	Jack Bond	\N	\N	J2153	B53	244398cc7786bc6de3c8e13c5fe24550
14000	Pastor Edgar	\N	\N	P2363	E326	3fe107e7b08c1f245f3b2acc8338513f
20510	Elias	\N	\N	E42	\N	c65fd113c5b2977fe36bd41da8a9da67
45850	Navin	\N	\N	N15	\N	2aee64ec33fc0aed3820694a13d4cdbb
47602	Klein-Isidor	\N	\N	K4523	\N	547b68d9aa28ce3e668746bbe07b9b8c
11331	Herbert Tögel	\N	\N	H6163	T24	82654b3cc0e0ef03ffc3473db2904760
48509	Himself - Test Driver, Pirelli	\N	\N	H5241	P64	0d0e91c615672539ea0efd95cda36a0b
94417	The Other Man	\N	\N	T365	M5	2a5de8045ed1dae1f9c9c7040d776a5d
86775	Veit	\N	\N	V3	\N	ffadc129f279d183df44fe4d48af76d1
4996	Jackie Wang	\N	\N	J252	W52	ada42f77823384ecdbebb9333df972d8
71021	Frank Allison	\N	\N	F6524	A425	e2be850d13c4066fac2d44def81d5989
95975	Agente Duran	\N	\N	A2536	D65	68edbdafc47fd8091abb73eb01dbc3fa
13286	Samuel Busey	\N	\N	S5412	B2	1f2989b9f0354f840a921735bd3438df
93951	Jeff Cohen	\N	\N	J125	C5	fcfa6b599219f9129878a50edd7502d7
72680	Max - Orderly	\N	\N	M2636	O6364	3b2ff8c0c0396646cd7e5233ff95731b
54008	Lady at Bus Stop	\N	\N	L3123	S31	562db0c1ac6b2715162865647dddd8a0
24057	Hamada's Father	\N	\N	H5321	F36	fbedb0e9e640a7e0f2078cf5f8dc5dc6
48835	Senior citizen	\N	\N	S5623	C325	11e6ba8778d2fa93d15eb797fe3f9fa4
65533	Señor Elegante	\N	\N	S6425	E4253	6b56e33c7a2568296ab14dddf73b398d
50263	Fame Dancer	\N	\N	F5352	D526	6ee4e702ab3af170dd59c9848d58e7ac
97908	Arrigo	\N	\N	A62	\N	f1d7e76f16b5735f646098b6b125a2e7
71791	Marshall Osmont	\N	\N	M6242	O253	aaaab4e2bf9dcb716d38439cd88f8013
89543	Director Reyes	\N	\N	D6236	R2	b65691399f9143be26d8df730932e92b
53546	Lloyd Bettinger	\N	\N	L4313	B3526	76f5b0f5ab429a8bc97f00ee9538ba49
8758	Strip Bar Partron #2	\N	\N	S3616	\N	247e8c0e5d61bc1820dced26605e60f8
30486	Aleks	\N	\N	A42	\N	1e4acc66dbb2a6a737c3ee602f5d00c8
60679	Tin. Reyes	\N	\N	T562	R2	6badb4dbb003f956258c17d3ce4b788b
71786	Himself - Restoration Specialist	\N	\N	H5241	S1242	7b5af317d088be531e99fb7d197dd858
3151	Gordon	\N	\N	G635	\N	394726f37fbe77d819e2346e9abf5757
33070	Big Soldier	\N	\N	B2436	S436	801d0ddd6868c383d0daf59a556aa795
81549	Táxista #1	\N	\N	T23	\N	4a244e849f2653e7c2b42c2eaeb11ae2
60935	Táxista #2	\N	\N	T23	\N	d29d9163faa2ae4d0e4976b75db97bb7
33182	Aloysius Claybank	\N	\N	A4241	C4152	8cdb50f27edde176af1c035efdb46b60
90492	The Crew	\N	\N	T26	C6	d0007b78f262d57e9cc7057fef32c48d
1349	Sotilas	\N	\N	S342	\N	d9c1b7969abcf88dddabc4ecaedfdaac
\.


--
-- Data for Name: comp_cast_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comp_cast_type (id, kind) FROM stdin;
1	cast
2	crew
3	complete
4	complete+verified
\.


--
-- Data for Name: company_name; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company_name (id, name, country_code, imdb_tiny_id, name_pcode_nf, name_pcode_sf, md5sum) FROM stdin;
34634	Comfilm.de	[de]	\N	C5145	C5145	103fec65d8a8129bfea07e4a98dfa0e5
63635	Dusty Nose Productions	[us]	\N	D2352	D2352	7a9718e93925d720de807fe027665fbe
35051	WTTW National Productions	[us]	\N	W3535	W3535	002eb2b89338ca14386743e11e7a425f
23380	Film House	[us]	\N	F452	F452	20c818c9a457fa6e902ff4b0d406525e
31373	AVI Group	[us]	\N	A1261	A1261	d90465c48c1e51f556562ad903aacdfa
6024	GodZone Ministry	[us]	\N	G3252	G3252	fcb66476f8f75f6cc075e3a362167a01
33177	Elvira Merchandizing	[us]	\N	E4165	E4165	3c2c30e6bf6589748445621378c6eb67
66924	G.P. Films	[gb]	\N	G1452	G1452	c538eda8ca2e7eeacd4350df5e80372b
61979	Sax Editore	[it]	\N	S236	S2363	6afc5715399d8a111c596732f4743ea9
9189	Visual Edge Entertainment	[us]	\N	V2432	V2432	95249ba76b6cdaa7fb710ce20ed09436
8495	AXN White	[es]	\N	A253	A2532	a9f8cf126bab47938f41facbaea8d74d
27332	Black Widow Media	[us]	\N	B4235	B4235	76b77c9ffe6d1884e44fa692eaa5dece
23574	Pier Six Productions	[us]	\N	P6216	P6216	79399675ad84c4fdd7f250eb67f49544
68847	PR Productions	[fi]	\N	P6163	P6163	9ac1d06c825a7ca26b7b6c15bf2df9df
34224	The Mummy Strikes	[us]	\N	T5236	T5236	d3b6cfc15976a9c4baebbb7b1db16bd8
56896	Little Wonder Productions	[gb]	\N	L3453	L3453	ea681428ec203208b98a9709500ad04b
45375	Buena Vista International Film Production France	[fr]	\N	B5123	B5123	3d877610178dde125da5afd28f2439a5
56215	Estonian Film Foundation	[ee]	\N	E2351	E2351	69ac55342ead3ea6bb0bb0c88d203182
47174	Sree Ram Debji Art	[in]	\N	S6531	S6531	11f0c51655cbc778933ff752a93c77ee
20219	Marion Knott Studios	[us]	\N	M6525	M6525	e0b34c9f1d46ee5cd3d823a4a685e980
62337	EastAsiaSoft	[hk]	\N	E2321	E2321	7a841323cb9fcfd38b39979a1f375592
30818	Channel 2020	[gb]	\N	C54	C5421	eefa3cd3941d2de68d2199799bda169d
54737	Sweet Home Video	[gr]	\N	S3513	S3513	446f76a146c9b8a13bb05bf75b308924
22487	Perspective Films	[fr]	\N	P6212	P6212	6764fb2fe7c6639c5f8f8a801368d09e
64482	Velocity Productions Ltd.	\N	\N	V4231	\N	4136154e1668158576fc95ce4fbb3f9a
81	TV Setouchi	[jp]	\N	T1232	T1232	a3790d467165d58c25f00f6c1be553ac
3912	Comedy Central Africa	[za]	\N	C5325	C5325	7bbf41408eaf2df73aa534d032b3f7ad
31083	Randfilms	[be]	\N	R5314	R5314	28c6342ba98aa759b7276f614f6fc1ea
15542	The Enterainment Factory	[ie]	\N	T5365	T5365	f8af7d14d5fae908b13b333802f0395e
16392	Latina Ars	[it]	\N	L3562	L3562	c36f8baea7b7a0012ebbe36cda608886
64328	Apocalipse Vídeo	[br]	\N	A1241	A1241	50336ce612f1e97c4147adcfda6c298d
45163	Ken Kennedy Productions	\N	\N	K5253	\N	7ffb6e43affc49b10e9beb9e8bc0ccc2
65596	Zison Enterprises Inc.	[us]	\N	Z2536	Z2536	27c187cece29ccc2849a4c0df46b7969
18031	Dick Wadd Fetish	[us]	\N	D2313	D2313	6bca80dc1d9813e39427976f934f43bf
63844	Thousand Faces Productions, A	[in]	\N	T2531	T2531	2c0f55d914f4f54770ef1c211d9065f6
43485	Century Vision	[us]	\N	C5361	C5361	8a87df099d3d217533b172029b311e86
27006	Dinafilme	[br]	\N	D5145	D5145	da4e1c061d35cbf88b1610e076ddc4f9
8595	Minds Eye Entertainment	[ca]	\N	M5325	M5325	0adc3925992f1334f47ac082cde7afd8
636	Universal Music Group	[us]	\N	U5162	U5162	29bae73a6c4eb9de9b04ad09e531dc35
28949	Starlite Films	[us]	\N	S3643	S3643	ca74b5b21c3dd359e05ff4e8dd82f331
96	Telefé International	[ar]	\N	T4153	T4153	23c7ae38c2b264e90afc15c90a700719
47091	TimeGate Studios	[us]	\N	T5232	T5232	dfd16f42e2d8cfc465fb5101ac7dd50e
28671	Cinemex Films S.A. de C.V.	[mx]	\N	C5214	C5214	f0d8426818c5097a3652a1d9540b3417
38591	Mirror Films	\N	\N	M6145	\N	22b0873b0410fd823204ff1ee0aa0dab
63340	Greyart	[us]	\N	G63	G632	ffa22d61cb8a6b08008d9c6a39afeee5
3230	TBS News Bird	[jp]	\N	T1252	T1252	56355123543504d5240d820bbb79bece
1617	Dr. Mustachio Produtions	[us]	\N	D6523	D6523	c5dc7acc68b05b4e84d69bb243e526cd
44962	Vitronic	[ch]	\N	V3652	V3652	d5688008b03a0d2296d556c199d7bc72
5009	Nuevo Mundo Television	[ca]	\N	N1534	N1534	4ce1f829b25029eca74a22ccc9e00f71
40359	Aleksandrija Film	[rs]	\N	A4253	A4253	229d0e73b51aa0dbf8e6115392a417ab
3586	CBS DVD	[us]	\N	C1231	C1231	1a421115fa59fd4213ed6d945d24941b
4550	Trans-International Films	[us]	\N	T6525	T6525	4b63a08a347f1ddde64b9c0c6f742d9b
53102	Twisted Pixel Games	[us]	\N	T2312	T2312	8224be2ee6d6de66db24697eff6b0e43
47370	Fondation de France	[fr]	\N	F5353	F5353	9a106ee585ccd20d08b0798dfe0705a3
44721	Gold Circle Films	[us]	\N	G4326	G4326	4cca151d444cc1b800a8a2164fbdf3bb
60516	Budsam Distributing Company	[us]	\N	B3253	B3253	3575cd8f64a9e673bf3cddb0a79a88ff
51180	Artificial Illusions Film	[de]	\N	A6312	A6312	330377febf0e3f5500ff8720f0548f47
58315	Compass Records	[us]	\N	C5126	C5126	e773b7e49f91d914b83f7d99cd022c62
28588	Chronos-Film	\N	\N	C6521	\N	381de484f0976bf7dc69522d422a5be8
24782	Public Service	[se]	\N	P1426	P1426	8859fe35b398199282348fd04ffd0fe8
64760	Films Chritiane Kieffer	[fr]	\N	F4526	F4526	3d7dd1a6ba415d72754fa189b64b0a18
39874	MOME Animation	[hu]	\N	M535	M535	b98e8bd8e6230884229182e8e8473340
11305	Exhibitors Mutual Distributing Company	[us]	\N	E2136	E2136	b63dce54a2d78a891df4b57277d323d1
14157	Kingsley-International Pictures	[us]	\N	K5245	K5245	2ec7ea22b6805ddd9d37a6f8f6cfaa2a
29563	École de cinéma - Genève	[ch]	\N	C4325	C4325	b3509eb889071742f65a6c3f3cd8c295
60139	Mimetic Media	[us]	\N	M5325	M5325	3c5d3b643196358f175b14b7f7cf656c
27698	Curious Film	[au]	\N	C6214	C6214	8f195dfcbb8992e37d45d7ed9d862227
39754	Caesar Film	[de]	\N	C2614	C2614	3ea730751c0dd8bdd21646cfc332ae3e
4776	PolyScope BV	[nl]	\N	P421	P4215	81791fa2b27b875302720f8c942cc5f6
65736	Camp Cousellor Films	[us]	\N	C5124	C5124	27925035800bc4caa28f0431228ee16c
66520	Plymouth Film Corp.	\N	\N	P4531	\N	d28a977f8109f6a790d3ea3cdd193290
5350	7TV	[ru]	\N	T1	T16	7ebdba630019ff12fc89b7dd27b158de
48232	Pierre Braunberger	[fr]	\N	P6165	P6165	3f2bfe88d4b4da638e69f74478da1754
41712	Film Gallery	\N	\N	F4524	\N	918a85390c8b40d72a781bd032460321
24616	Allround	[de]	\N	A4653	A4653	c11875197a262644287f76167c9748d7
53634	Aura Pictures	[kr]	\N	A6123	A6123	2761970ee10c192fc223b13701cf5457
53587	Grahalakshmi Productions	[in]	\N	G6425	G6425	e6d8b57306b3bf77705122fa2c0d627c
25436	Fox Video Games Inc.	[us]	\N	F2132	F2132	62b260fb8e5411fab9fd0ebe5e346f66
55385	South American Pictures	[us]	\N	S3562	S3562	5dad52b44258c668a17c300efda09793
24788	Stein Film	[de]	\N	S3514	S3514	0c42dd51d85d5d2c420421be1cff0d7e
13518	University of Oklahoma	[us]	\N	U5162	U5162	126fd1b4284bafa99c56ef57716465c4
16644	Stichting Entertainmentretail Promotion	[nl]	\N	S3235	S3235	7391a327101a46d5bdb7496494769858
63038	Filmimies	[fi]	\N	F452	F4521	8c5451ac5685fb14cfe8bae0de4f589a
4827	TV3	[my]	\N	T1	T15	34a97ae8a0478684db32928443bbabbd
55157	Green Fairy Pictures	[us]	\N	G6516	G6516	20120f18f153da9c08af67df0b6b1a7e
4447	AOL Online Video	[us]	\N	A4545	A4545	b3c1d0cae3cf6e8e0e7deee66d9b958f
19421	Goldsmiths' College	[gb]	\N	G4325	G4325	e0072a6b900bd3dea03359ce3c18a70b
45414	Blockhouse TV	[gb]	\N	B4231	B4231	4aa3de4ca98cc3d44e4e754ef743eb06
66629	Rochelle Films	\N	\N	R2414	\N	6bca5af7a3eb1782b8a5ded843d8c2b3
61007	Bognor Film Productions	[gb]	\N	B2561	B2561	fc1a9e0c63b44ca466d3f426c0b26a57
15436	Paramount Vantage	[us]	\N	P6531	P6531	bade826792ec6af57c9488d83a58e920
11957	Prodimag	[es]	\N	P6352	P6352	4881ac395ddab7918ef2a5c8624cc2f6
47455	Charada	\N	\N	C63	\N	79dc78eb8d8aeaab799fd4c1b435f53a
22223	Gremlin Industries	[us]	\N	G6545	G6545	45ef79d7f9fa1893a976d92aa96e1630
39419	Bunker Lab	[it]	\N	B5264	B5264	bd010173ad1ef606e1dce200579e7b0d
41850	Never Land Films S.L.	[es]	\N	N1645	N1645	2d5b4c587ba357f29590f290a12740c5
53429	Ill Willed Productions	[us]	\N	I4316	I4316	a6b2a8015c9f698305a946ae245d6c44
68045	Guangdong Shining Star Culture Communication	[cn]	\N	G5235	G5235	783622a9a83e059d48fbae2bf1f9be46
34959	Big Pictures Film Production New Zealand	[nz]	\N	B2123	B2123	63077aa6704ab95fedfb22f9bea4fd02
10821	TEN Sports	[in]	\N	T5216	T5216	d55ea1cebf59917c06d1c47233a06fb5
60753	California State Water Resources Control Board	[us]	\N	C4165	C4165	0256e44e11d11da689b3f6658a7ce526
32879	Cineora	[fr]	\N	C56	C5616	6e2b4ea26b82e36a56e73e981136ec40
19881	Seven Arrows Multimedia	[us]	\N	S1562	S1562	9bdcbad0e60d2705fd51784f6cd6a744
63171	Cornerhouse Publications	[gb]	\N	C6562	C6562	b9182b45b96cbd5d7df93526dd1bb771
29726	Stirling Gold	\N	\N	S3645	\N	84c2b68c063295c5182cf3ff796675dc
63460	Advertiser Pictures	[jp]	\N	A3163	A3163	90c338becce2dc33bc109488f35985d9
48561	USGS	[us]	\N	U2	U2	13d75bb76e0c78adee007dd8038c9953
5532	Chukyo Television Broadcasting	[jp]	\N	C2341	C2341	24f8571643b4aaa2d11851a6e893c777
42503	Oopic Films	[gb]	\N	O1214	O1214	de10f40c768e61f874a598388d62c7d5
57503	Small Talk	[jp]	\N	S5434	S5434	037e6ac2d8a46e5712f3f8cd0f10530e
27796	Billingsgate	\N	\N	B4523	\N	def394d0d22748779b5088f74d7425b1
56165	Eduardo Campoy P.C.	[es]	\N	E3632	E3632	e1fc6faa9ebc91b57187c776a2d6ba49
64944	Contagious Media Productions LLC	[us]	\N	C5325	C5325	a6ab3a7e25fc36179e64a2d2f6d205e8
8937	Daily Echo	[gb]	\N	D42	D421	cd167589d5d7096fd7ccfaf82856685e
19779	BAS Film Productions Inc.	[ph]	\N	B2145	B2145	cda92a95f03a8eba7e12149988c08f09
64449	Fictionville Studio	[us]	\N	F2351	F2351	ad19731e61bc67d4063bd1ba751a30ee
64401	Imperium	[us]	\N	I5165	I5165	74981a73b00ff993bb2d5bd13b382c4a
7909	Titan Broadcasting	[us]	\N	T3516	T3516	f70fae7aca24d6d4cf0b39c123d3f3fd
63180	E.M.I. Films	[us]	\N	E5145	E5145	f617c567816ace229f1654cef896d37c
24120	Sexycora	[de]	\N	S26	S263	6cd9c38c966001a5dfcc385fb89e6352
58865	Boardumb Films Productions	[us]	\N	B6351	B6351	b95d96c87f81ee3d791b21f364a32888
19748	Parallel Films	[us]	\N	P6414	P6414	94d39492b2752209761e4ca2425fbd18
21514	Total Media Agency	[jp]	\N	T3453	T3453	e655366b12c1e5a33c2e836bdfd4ae8a
59210	Jost Hering Filmproduktion	[de]	\N	J2365	J2365	aaa8412215821bfc3fc8c6324edd1a4d
18738	Panckhurst Productions Pty. Ltd.	[au]	\N	P5262	P5262	35406bd317ff6927b1459b4893bd3b81
32824	SchröderMedia HandelsgmbH	[at]	\N	S2636	S2636	abef1778452a3dc3c2fd77af10348014
11353	Warner Bros. Entertainment	[ca]	\N	W6561	W6561	666230427e5eb60060b18241429ea469
32428	7Even Entertainment	[us]	\N	E1536	E1536	9ec7455e1a386e6b8bfbed91751f3ada
25379	Showtime Networks	[fi]	\N	S3536	S3536	4a63ec75bd8dcd24fd977ce65f278139
41609	Watermelon Seed Productions	[cn]	\N	W3654	W3654	301a8f47f0ca5dd4390f72389e150112
70055	The Angels On Track Foundation	[us]	\N	T5242	T5242	c1b053fefaf4ae60944e012f863f81b0
48736	Lumbermen's Mutual Casualty Co.	[us]	\N	L5165	L5165	ae6151ca4b8127d48a0e2e29c02bfaa7
36891	Rain Dogs Cine	[uy]	\N	R5325	R5325	c134af21f44e1d4262112f53f2a70592
8814	Jetix	[il]	\N	J32	J324	6049f58ff12f017e03f3adba1c466e5b
11983	Mars Production	[tr]	\N	M6216	M6216	8f6250ca1af01deff826b291df4052b1
22719	That's a Boy Productions	[us]	\N	T3216	T3216	d41a0eca8b58c91a44f962de796f8236
67243	LBP Stunts Chicago	[us]	\N	L1235	L1235	4feca25107981b58e18261d442e1ccde
44059	Promark Productions	[us]	\N	P6562	P6562	9ff0075eb29aeb0d8685f597e9b8ea15
32855	Cambridge Film & Television Productions	[gb]	\N	C5163	C5163	d1f213b452bae8c5e526d01a1ce9dcdc
31961	P J Entertainment	[us]	\N	P2536	P2536	76ed85b4e51eed6d26922d4795291b1b
35555	Kitchenfilm	[it]	\N	K3251	K3251	9204755b47ca50df3c8c5bfc4ebc3477
2273	Blackboard Entertainment	[us]	\N	B4216	B4216	5db31d5b59caf7e29ac172a7e11454ed
49978	Devin Entertainment	\N	\N	D1536	\N	f9d25766775ff8f59d35c1495b2595d8
4728	4 Kids Entertainment	[us]	\N	K3253	K3253	67ffe2955f1de03bd3339314c2a49774
3590	Cut To The Chase Productions	[us]	\N	C3216	C3216	4cc5016a6ef6447bacfe010b8805f713
14600	Camerado	[us]	\N	C563	C5632	ebfefdcea6a762ee2d39ca6c0889bfdd
8962	WFLD	[us]	\N	W143	W1432	db3132f0a6b43e0993568f74f2002d70
40947	Wonderland Films	\N	\N	W5364	\N	e8b913f0bd6ee75906277f7ede36c0c7
66447	It Factor	[us]	\N	I3123	I3123	b6a00eb1ede94a4aba13490f54004223
45320	Diamond Entertainment	[us]	\N	D5353	D5353	e3e8c63236969fa06a37a27f7abcc0b5
20066	01 Rai Cinema	[it]	\N	R25	R253	70069a6ffb3215997e2c70ccac2bf1c0
66500	Crusade Films	[us]	\N	C6231	C6231	b92f0c7882849a7db2d4123c6393bc3c
29513	Cheeracise	[us]	\N	C62	C62	ea86033b766871a44ea523508f6f7f5b
49252	CotLu Films	[us]	\N	C3414	C3414	37a5e623c962345a10849d66790f3a77
33757	Ellerslie	[us]	\N	E4624	E4624	fb45dc179edc88abdde98db3b99d25c8
69242	Polydor/PolyGram Music	\N	\N	P4361	\N	889e39831602fcefe7e09958d99eccf4
16016	United American Video (UAV)	[nl]	\N	U5356	U5356	81c869d17bf19d1c8ae5e8e32efb1dc4
5797	Parallel 28 Equipe	[us]	\N	P6421	P6421	8659fbf951493838427061f8ead8b18b
59739	Pavalar Creations	[in]	\N	P1462	P1462	295911bd2539834fc9e03b73a962443b
22780	Compañía Española de Propaganda, Industria y Cinematografía S.A. (CEPICSA)	[es]	\N	C5121	C5121	8bb210445249112dd9919022fa27ccda
4024	Canamedia	\N	\N	C53	\N	684da2b99a602e082e2a58bd9325a2c4
52909	Antibes Inc.	[us]	\N	A5312	A5312	767633d744939ee6f8b75ecdb2476a18
38145	Felder Pomus Entertainment	[us]	\N	F4361	F4361	35a0981de0dc67ea8d927eb6b81daff3
51994	A Peninsula	[es]	\N	A1524	A1524	bbf85cced1139cde1b23ba0ce92b92bc
34717	Zhong Ying Yin Xiang Chu Ban She	[cn]	\N	Z5252	Z5252	886b465c9b5348e48f9b4ee919bd3bbd
30165	Centro Cultural Consolidado	[ve]	\N	C5362	C5362	4ed0531df315098298eecf755358acc4
45150	Television International, London	[gb]	\N	T4125	T4125	89dd997e3f93e3f0b639f928abd43099
16786	Rheinische Film GmbH	[de]	\N	R5214	R5214	7c0ff874fd6c07d4d3b3e0a2e48b0ca9
40912	Ro*co Films International	[us]	\N	R2145	R2145	9aa8e044da234d714729c376fd3e924f
11706	Kokuei Company	[jp]	\N	K2515	K2515	1499b77c2e671319c13f23ad3ebfdc40
914	Christian Community of God's Delight	[us]	\N	C6235	C6235	4b24060d444b5e6669ad6e1c7073097d
38955	MK2 Vidéo	[fr]	\N	M213	M2131	380efc6431610c3e33481c5c90755de1
50396	Broadstar Entertainment	\N	\N	B6323	\N	991a48d16c9ab035a0af0eabc075041f
49541	ENTV Algérie	[dz]	\N	E5314	E5314	d3064b0204e09b0069e1d0b7523f4952
7221	7 Diamond Productions	[us]	\N	D5316	D5316	9d90674cf68a265ab3500b6d6d9eb55a
54609	Filmhaus Bavaria GmbH	[de]	\N	F4521	F4521	f2218db4ec61c95418fc33137f8efbc7
53792	Beyond the Box	[us]	\N	B5312	B5312	b053c6cbf8cba158b100ec936539e664
1354	RTP Videos	[pt]	\N	R3132	R3132	e8f54defab145c14d6d0125a4b292d5e
36469	Kitchenware Records	[gb]	\N	K3256	K3256	de247d7021d8dbf67b0ed115c831ea0d
15738	blueprint.tv	[gb]	\N	B4165	B4165	de213f09570abecff38bd86bc4daf731
34946	Green Light Films	[is]	\N	G6542	G6542	09fb50955b68f17629bcbbbb26b15c0f
64905	Video Publishing Vrijbuiter (VPV)	[nl]	\N	V3142	V3142	92b71eb6af7437bd1506cd9875a2b207
41236	Odd Lot International	[us]	\N	O3435	O3435	d5b8ef3c42489bf063679f372baaca19
32779	Pandora Video	[nl]	\N	P5361	P5361	7c22d2c07f570123ed6c185e97952617
69952	TV Productions	[us]	\N	T1632	T1632	df9bf7a6eb8c307a47afb7be8b57b43c
21850	Shkilnyi Production	[us]	\N	S2451	S2451	e8bc99a747f5b370ebb7886fb0e63101
70031	GCO Pictures	[us]	\N	G2123	G2123	5eba25ff40388372d1c23578ead69d66
17833	RKO Radio Pictures Near East	[eg]	\N	R2631	R2631	3d9628096b3bcd224bcae2d36907ba0f
33247	Notafilm	[us]	\N	N3145	N3145	55bf0ee56f1350c741d7752609de6aa3
51501	Line Produce Films	\N	\N	L5163	\N	ccb01250a0b68bf50f682cfaa684f03d
67125	Strangeways Productions	[ca]	\N	S3652	S3652	207f844fd42bd7ed231c0290d0106bff
22820	Aviation Videos Ltd.	[ca]	\N	A1351	A1351	d45c262b3ee52d1f618110a8cf3781aa
3991	CreaTV San Jose	[us]	\N	C6312	C6312	1db5f15f37225e231fc43649f524696d
35462	Michael Bloom Entertainment	[us]	\N	M2414	M2414	a65df733e2ce43c81bed01efb6400511
9494	Universal Music Group	[fr]	\N	U5162	U5162	27a021b35d657d202c2220641eec1adf
38987	TMW FILM	[gb]	\N	T5145	T5145	2adab1e93ae4a2b367516acbd4fcee2c
51470	SPO Entertainment	[jp]	\N	S1536	S1536	2e305200739f224e9b710459664dfbb1
69266	DPTV Media	[us]	\N	D1315	D1315	42af3f6ed7dfd117829b5820a5ba8d23
31818	Sherlock Films	[es]	\N	S6421	S6421	fc0441671593f500399946163455e43c
19510	48 Hour Film Festival	[us]	\N	H6145	H6145	1cde6c42d79d5462ced0c88b1f6b7a47
32719	Adhoc Film & Fernsehproduktion	[de]	\N	A3214	A3214	d9c39d2f1fc5641ce71962b0114192fb
58836	Muir Movie	[us]	\N	M651	M6512	f640e7af8a1dcd8f205fa97a85e01b7e
64742	Jotz Productions	[au]	\N	J3216	J3216	7c9564885f0a3c95fb2855944322e73d
55166	8x Entertainment	[us]	\N	X5363	X5363	a8dc57eff1260dbf9fb11c0aa15249ec
36601	Kvikmyndaskóli Íslands	[is]	\N	K1253	K1253	cc1e2ff7004f3392eeac420520cb91fd
48543	BSU Films	[ph]	\N	B2145	B2145	4e19a4e27f57317777f7d6c833791f2f
63711	3rd Day Production	[us]	\N	R3163	R3163	1888d903b7713c475fff437827bcbff3
27329	Scrnland	[us]	\N	S2654	S2654	49a6b137c062888c3e257fdc24230d8c
5133	Canter on Congress as Indiana University	[us]	\N	C5365	C5365	3280e3cfa634c7e122a3814c7033ca94
46312	Mosi Movie Makers	[gb]	\N	M2515	M2515	06cf79c0e69f9269201361cda4c79a5c
1338	CHASE	[ph]	\N	C2	C21	d3d2a1a8a10f2910945239c0d35d6641
43990	McAbee Pictures	\N	\N	M2123	\N	385673f1415e8864ac92e98b22b7b9f9
65499	Grayhat Productions	[us]	\N	G6316	G6316	c513e3e485cd9d7ed9c58c6df9c9159a
1622	Esquire Magazine	[us]	\N	E2652	E2652	a880ddc672b3e7666143e5542b75cc7e
64205	R&G Video	[us]	\N	R213	R2132	741284c6dcfbe8df8ca6e9975f1e93db
46157	dK'Tronics	[us]	\N	D2365	D2365	821480289f433d1fe998216d93f970d7
8690	Cannell Entertainment	[us]	\N	C5453	C5453	5c6d1924ce2155fac0bea1f934a94ccb
39864	AKM Communications	[in]	\N	A2525	A2525	f820c38d38c9ebcc88c9865ea5a54bf6
294	Pandastorm Pictures	[de]	\N	P5323	P5323	4d2dea7b79d4dbff2b6acac533535814
59613	No No, Thank You Productions	[us]	\N	N5352	N5352	0cbcc5e6865905b16cc777946a92b5eb
53160	Todo Piola Audiovisual	[ar]	\N	T3143	T3143	a985c16818bf7ccea167e1c3c1de3e4f
43119	Concorde Cinema Group	\N	\N	C5263	\N	934df17c20aad559a2cc9b1b89880517
5595	Wisconsin Public Television	[us]	\N	W2525	W2525	9ce4baedc08732a41a550d03c908ca7a
38790	Cinema Video	[us]	\N	C513	C5132	f7e1d985bf3cf96c18a9c12c07d2457a
23171	WHD Entertainment	[jp]	\N	W3536	W3536	0a9e401079075274f097754dd8b30611
62242	Hoyts Theatre	[au]	\N	H3236	H3236	5fde09a54347bc480470779e9740a96d
29135	Anthony-Borgese Communications	\N	\N	A5351	\N	4e15e74fcb7c6cf9bb5f71e644bc4ef9
40823	UnitShifter Entertainment	[us]	\N	U5321	U5321	afe7aa1a4db6a8d9a01a40be2ac29e05
46735	Silver Spoon	[kr]	\N	S4162	S4162	3cc5b1a54498aff530522713e2590756
58421	Don Featherstone Productions	[au]	\N	D5136	D5136	d7d6eca7fe72b307a2b3337dcf9dba0b
66238	Lube Dynamics	[us]	\N	L1352	L1352	4f78575d8d1915f53b9f900168244214
288	France 3 (FR 3)	[fr]	\N	F6521	F6521	ea1c7e66035569e9dde5ab49690ec097
34277	Knoop Film	[de]	\N	K5145	K5145	d1a8ef48c2d67ac639e53f2ef2c842ae
15212	Curzon Film World	[gb]	\N	C6251	C6251	21a1216a3a44e9150ee06b20f8d576d5
29831	Hole in One Video	\N	\N	H4513	\N	81453047b915e470bd4f2acd0bee5434
3509	KWHY	[us]	\N	K	K2	5202a9b04cdf5bba18c4dd713185a987
64949	EuroProModel	[ua]	\N	E6165	E6165	1284b92662f60065f3c84955953718f3
21584	Vega 7 Entertainment	[us]	\N	V2536	V2536	a4229940dfc27e1d4068f77639dcd832
63139	Michael Burnett Productions Inc.	[us]	\N	M2416	M2416	b9f27f6f67a8f9bc3f5a97c79626759b
15121	trigon-film	[ch]	\N	T6251	T6251	34ca376f1c757770c7991580d7e3fe85
9747	English Channel	\N	\N	E5242	\N	f09f9a4a83c5f0ae71ac45004ef3a07d
37515	Antonelli Studios	[us]	\N	A5354	A5354	ef0dcb98aa951b4fcba60f9dd1c094e0
57255	Kinoko Films	[fr]	\N	K5214	K5214	933efb479c4e7e18507165a0619206f3
59745	Soul Boat Production	[jp]	\N	S4131	S4131	4a0f3226fa2c377d90f3be0cc93c4496
8155	WTXF Philadelphia	[us]	\N	W3214	W3214	e58d31c4915f824fbe751916bc62ddee
14507	Giant Leap Productions	[gb]	\N	G5341	G5341	91e81fba68bf11fe34972f4545212246
2307	BOTB Comedy	[us]	\N	B3125	B3125	d5b59a94673f9d66bed009c35f2a0792
60351	Molymusk	[gb]	\N	M452	M4521	101a80283795efbaf9de24c33f9500ac
13370	Nix Flix	[us]	\N	N2142	N2142	56b4a85c23d2a31cfc3f758b47a61709
19701	Zootrope Films	[fr]	\N	Z3614	Z3614	1c7ac914caf094fc79f19781aeaf362f
44850	SPV Records	[de]	\N	S1626	S1626	5848b6c85e717cfd4ae1ad59b2106758
21980	Redline Music Distribution	[us]	\N	R3452	R3452	c1a3f4d3e438f1f5d977c88b95721519
24980	Walt Disney Studios Home Entertainment	[ch]	\N	W4325	W4325	a1c3a277a531a6eb7c63559327a20b5b
4844	Cross the Line Films	[us]	\N	C6234	C6234	e951595bddb34e6e410048ec0ec320a3
15563	RKO Radio Pictures Chilena	[cl]	\N	R2631	R2631	48ff72aa9b9a3df42a2fb4a0915017d7
36088	Movie Maniacs Comedy	[gb]	\N	M1525	M1525	4771b3d7a98a12f51f08323158246ff5
51695	Pyramid Films International	[in]	\N	P6531	P6531	af6a72e042e4a72fc6c6359fc5e8b321
1788	Box Distribution	[fr]	\N	B2323	B2323	3404edf3035eb1fed50c25f8de2e9ff1
24408	Focus Features International	[us]	\N	F2136	F2136	fdd9f49506475ec00bc12890bea339a3
16178	Paranaguá Cinematográfica	[br]	\N	P6525	P6525	2883b1b7c3deb59b43ee6fe46e12fb14
18227	Le Pacte	[fr]	\N	L123	L1231	16d0abefac1fead8a6bb99fdcf09c833
22177	CFM	\N	\N	C15	\N	bfe140c4efb899074d939feed9616279
63539	Constellation Films	[us]	\N	C5234	C5234	70e35b9a5fc7ce31b6da42640bf7a803
33259	Tomorrow Film Corporation	\N	\N	T5614	\N	48dd7368f7e6fb197d96fc84cd2dec0a
5459	Space Truffles Entertainment	[us]	\N	S1236	S1236	8b397bbc6edd929cf8d05d272af7adb2
33050	Accattone Distribution	[fr]	\N	A2353	A2353	96adb80f6b76c9990e2d1909082e807b
35837	Broken Window Guys	[ie]	\N	B6253	B6253	b4a644ea58fbe249d8049068ad30c6be
17246	Aysha Productions	[ca]	\N	A2163	A2163	0dccc8530331d506f7a0a2eb4025b2cc
12329	Vito Video	[de]	\N	V313	V313	2f0b24db89da93b7ea63dff52f91efb8
56461	Victory	[gb]	\N	V236	V2362	9608daf0ea3bf233619761b94aabfce2
17325	Norimage Films	[fr]	\N	N6521	N6521	4c118d07e4f4d3654844b0bea838b4e3
31614	Independent Networks	[us]	\N	I5315	I5315	7f731a102111930a276948d56b24bc91
31793	SNK/Playmore USA	[us]	\N	S5214	S5214	d127a302de6e849afd0bef4bff7709c7
40889	Willing Suspension Films	[us]	\N	W4521	W4521	5846846991c9631d49fe8f6c2746878d
5064	CBC-TV	[ca]	\N	C1231	C1231	a3acf9f644aa03bbe7f3597fd14b6282
23247	Msn glo	[us]	\N	M2524	M2524	4398c25c72f511887cf9187984948e6b
68846	Global Action Group	[ru]	\N	G4142	G4142	ed6be4b581dd8fd959bfe89685840806
10327	Animazing Entertainment	[us]	\N	A5252	A5252	0dca0a218a7c2b8a5d1ddddb99ffc4f7
34161	Multicines Colombia S.L.	\N	\N	M4325	\N	513c84eaf20a05d5081bb629e156321c
2481	Sci Fi Pulse	[us]	\N	S2142	S2142	b77a7b4afd295b3c2d738878d8869279
65056	Righteous Insanity	[us]	\N	R2325	R2325	6e0c12ec902d8ef3d87efecca28d21c0
65644	Andros Films	[us]	\N	A5362	A5362	cef27325e4d6bf8ea0f4f61a26b80fc1
6168	Ciak Studio '88	[it]	\N	C23	C23	84d7a16327eb1c587f1c0cf58a6404ee
41389	Davidson & Associates	[us]	\N	D1325	D1325	e7a978f340b704b4fdeb7751cd5a9b9c
13868	London College Of Printing	[gb]	\N	L5352	L5352	f86ea632a2a8b651cb1ed7416da9b244
49316	Lego Media	[dk]	\N	L253	L2532	ec9d8d7a9004a112bae37eeaa713f720
58768	American Metropolitan	\N	\N	A5625	\N	fa53798d0257e9b78424b106a242e523
67443	Stichting Zig/Zag Culturele Producties	[nl]	\N	S3235	S3235	2787ed48752152636577deeefc97ce60
8852	Western International Communications Ltd.	[us]	\N	W2365	W2365	5256b581103feeff4b392b68a066e254
64568	School of the Art Institute of Chicago, The	[us]	\N	S2413	S2413	6425f996fc87c4db5d71aae039514718
50097	Intu Films	[us]	\N	I5314	I5314	b1a9c05fb3be76bd403ff223f92f437c
65265	Vansan Productions	\N	\N	V5251	\N	e225677f44802105dd0b89ecdc958549
17945	Al-Nasr Films	[eg]	\N	A4526	A4526	12964d027557e32ce84666f264caca06
31479	Arista Films	[us]	\N	A6231	A6231	118925ccf29740e5474f1099ba2227da
673	SubTV	[fi]	\N	S131	S131	29b188cc83ac476eaf324b3949b53efd
32569	White Rabbit Home Video	[us]	\N	W3613	W3613	ea06c6de7591f5d378fa1540635ecf39
40524	Essence Film	[de]	\N	E2521	E2521	bf6be1169bbcb1b759bc827e36eacde2
21489	Sun Electronics	\N	\N	S5423	\N	db6ec84b1b99f5ab26094ea13fb0488a
7751	Penguin Films	\N	\N	P5251	\N	c1d2343591f1249f8a3bd4b761fedf25
69474	Raisani Productions	[us]	\N	R2516	R2516	164115fe6d0d441fc0114743d42a40d0
9220	Jump! Creative	[us]	\N	J5126	J5126	ecca89795345ef61438640d4f8dbdc86
54943	Sovkino	[suhh]	\N	S125	S1252	e1e03785ce3ce14cded2d3157dbc6b02
22636	Cines Unidos	[ve]	\N	C5253	C5253	754b281ca7c615d47e1c0a2e7d50fab7
4695	TeleToon Network	[ca]	\N	T4353	T4353	1cd2b0dbacaa27da0b072ebbeaecc092
3485	Brooklyn Independent Telelvision	[us]	\N	B6245	B6245	eb7c218094442d85c0a579689b2eb5b0
47122	Han Media Culture	[th]	\N	H5324	H5324	a4248c4b400b00acd8dfbd1a76521aa1
53724	All Right Film Distribution	[dk]	\N	A4623	A4623	48bf0ac9ab89aefcd5c30d48a76b3b69
57483	Bioscop Film	[hu]	\N	B2145	B2145	4a3ebda995008c4dd5cf344e173a67ea
4412	V Squared Media & Entertainment	[mt]	\N	V2635	V2635	8f25e1e18b9ff73a9c69606acdcd9bf5
52841	Dirty Cheap Creative	[tr]	\N	D6321	D6321	97c09826ab08cf83c97f67414bb773d1
39800	Videophon	[de]	\N	V315	V3153	ff8ab4c68112f7858ae4bbdd5232f814
33966	Pressburger Films	\N	\N	P6216	\N	799c1ac75711240966b175035efc6ff9
60389	DAMP	[us]	\N	D51	D512	9e3ec56f2ac03c2c17f3cae8214164be
44276	Habay Film	[it]	\N	H145	H1453	814801a1057bbe131d7b2d7b492b596f
55431	Tsukuda Original	[jp]	\N	T2362	T2362	868a6e698c4d947a2e264fd6220c8a74
41979	Bunkasha	[jp]	\N	B52	B521	32e04d8becaa67febb6b94807f0c9dec
20716	Argen Video	[us]	\N	A6251	A6251	8ddeba36a67c2b464edd0bff67bfc585
45074	Link Rights	[jp]	\N	L5262	L5262	4202416847b101331186e235a0afc271
3986	IMG Entertainment	[gb]	\N	I5253	I5253	92f1814cb2c602156f3c9e4c30a4f8d9
70687	Zombie-warrior.de	[de]	\N	Z5163	Z5163	6f5f695d7bd08122f1c8ece2814ae2cd
40324	Noesis Interactive	[us]	\N	N2536	N2536	842bcec0b95c1ca9dcc0633436b645e8
5884	Chicken Bear Productions	[us]	\N	C2516	C2516	b41d32e401d4d3dd93a17a61bd71fe0e
56499	McDermott Productions II	[us]	\N	M2365	M2365	cc2d5bf5acc40978d612c15844291d59
12294	Toei International Company Ltd.	\N	\N	T5365	\N	a2f1f8bdcb57011c205cc9a84c6b3f3d
64189	Helber Pictures Inc.	[us]	\N	H4161	H4161	92c63878cee42479ec1c98c13728d075
31368	South London Gallery	[gb]	\N	S3453	S3453	34ddc9c28196f7f5104bf8dfdb6de69e
26382	Mañana Film	[se]	\N	M5145	M5145	537bc7d976362e386fc2e1da6f9a80d0
45519	Rowenet Pictures	[us]	\N	R5312	R5312	986b9e7aed270feeae0a90936ad56346
36934	Cinedia Laro Films	\N	\N	C5346	\N	e5f8f909b07b927c837ef8907ae0483b
61589	Filmnic Inc.	[us]	\N	F4525	F4525	ecf0fdd2354d6767c9097566338c35a5
24592	Centre of National Film (CNF)	[ru]	\N	C5361	C5361	9136fb1de1828fc1462cb459330633e1
37935	Harrington Talents	[us]	\N	H6523	H6523	fa1e152a44611bc515c2d9a746221bfd
65496	Dream Theater	[us]	\N	D6536	D6536	868d91ef49ed5257c78e68f84a9ab99b
64674	Holland Avenue Boys Ltd.	\N	\N	H4531	\N	b8cd049b56a87df51f0fc2e1abea56ab
21211	Eden Video	[it]	\N	E3513	E3513	9d9925af9a7edf77522fdc45a2981d6e
59272	MW Studios	[us]	\N	M232	M232	fc2322050021209bd7c9d1033c175413
8931	ONE HD	[au]	\N	O53	O53	56c67dc669aba4b0f07eaee3d506a451
68805	Yad Vashem	[il]	\N	Y3125	Y3125	2d6e5edd14d39f64acc7f5aaa358d677
11986	Rocket Releasing	[us]	\N	R2364	R2364	5a733a8242cf80238bbc142716799068
65729	Order Productions A.V.V.	\N	\N	O6361	\N	1035a6828d754f845eb9da354b599ffc
5288	Waste of Paint	[us]	\N	W2315	W2315	0cd96ccb42d1ed5b1380695364fa24e7
55814	Joseph E. Levine	\N	\N	J2141	\N	0ad960a410549e0b969f894f8d13256c
18703	DisCina	[fr]	\N	D25	D2516	4e7e6c3b9a6a2ab64feca8cfd101b932
38834	Lucarelli Film	[it]	\N	L2641	L2641	61f3bb6f37e817583bfb4b4cd5ad355f
51788	Paradise Entertainment	[it]	\N	P6325	P6325	7dc344534f980e32f02d2e8a43a605ed
60632	Jour De Fete	\N	\N	J6313	\N	2a94ad65304a4571e35bad59c76e6f8c
16737	Rotana Cinema	[sa]	\N	R3525	R3525	35c2417b8ef065877eb988a81bce0278
2617	Astley Baker Davies Ltd.	[gb]	\N	A2341	A2341	8319eb8abc3b6243361fa02657e703fb
33389	Screen Indoors	[gb]	\N	S2653	S2653	d1cb5b08895024e49d6ada92d460d4b6
18384	Sarawak Media	[my]	\N	S6253	S6253	7e0eada2c1efcdb76531376150e784c1
55230	Starry Moon Productions	[us]	\N	S3651	S3651	acbb62fb37b9f6f4f9fcdd2053050193
27119	Play.com	[gb]	\N	P425	P4252	ff74f29b91ddb59a828b921559a90c2a
24753	Goldwyn Entertainment Company	\N	\N	G4353	\N	432f32493358a9df60c993ba2bda9d8f
55787	David Martínez Álvarez (La Real Academia de Taramundi)	[es]	\N	D1356	D1356	177f805c5f08f3120b465305778267e8
1610	Gravitas Ventures	[us]	\N	G6132	G6132	b68f1bd9708e765d511e6e251f56419a
696	Antena 1	[ro]	\N	A535	A5356	78347c87c9223bc639314258d46f1d11
38371	TNSmedia.net	[de]	\N	T5253	T5253	9b6177dbd66969fe5ff54f264a981e3f
46925	Infamous Adventures	[us]	\N	I5152	I5152	00bb5aabfb9045778689a64be0e5fded
1980	Rogers Cable	[ca]	\N	R2621	R2621	5ef300036b6c34de4721b8d9c43c64a2
47368	Produttori Associati	[it]	\N	P6362	P6362	f7d37ee3d6555930b58dc7f4817c25b9
21562	Tennek Film Corp.	[us]	\N	T5214	T5214	edffdbc03206bfedb42b8c3081e845d9
67936	Gulliver	[us]	\N	G416	G4162	f4f9c7cc26fe240fcda31eba84b5e38b
50888	Kommkino	[de]	\N	K525	K5253	3e3c3f33d7923bd07b4410e48db52103
21890	Art Cinefeel	[fr]	\N	A6325	A6325	ea0f98c7cbabcf5dd362b865629fdbe7
7711	Irib Studio	[ir]	\N	I6123	I6123	69e303c5988afeb14e7bab04a9b7752d
33179	Craig Galley Films	[gb]	\N	C6241	C6241	aa8322d76f3c0c7fa0f7a704cb9c1549
26408	Frame 59	[us]	\N	F65	F652	2bab46ebe4bbe729d3a9a0288b1399e3
68972	Desclee de Brouwer	[fr]	\N	D2431	D2431	3e334277e47087ef2a4fb3b4520c8f45
45382	Landseer	[gb]	\N	L5326	L5326	332aea68781f3549403aeaa8cd0fa0dc
62733	Hometronics	[fr]	\N	H5365	H5365	353353eb1bb3605809dee0b751e9d4e9
9645	Chronicles Film	[us]	\N	C6524	C6524	b185da50889826d206bdbf7fa37f72e0
69919	Mack Productions	[us]	\N	M2163	M2163	6606bc98ce7319cf7fef5647918c4fb9
48374	Empire Releasing	[us]	\N	E5164	E5164	de505cbf4a208cdd644d1ea18f6a7ab6
30486	TMJ Productions	[us]	\N	T5216	T5216	9a64fce91fed7c8c66fea27ba4edd956
8723	Sony Entertainment Television	[ec]	\N	S5363	S5363	feeccc19c92258e9e91dd5fda7a986bf
52174	Project Evolutionz	[gb]	\N	P6231	P6231	b5f9a50ad0eb748ec53845d0781ace35
13047	Steve Hall Video	[ie]	\N	S3141	S3141	2768c945b18252cd6661665c3d3007a0
17965	Sobhy Farahat Films	[eg]	\N	S1631	S1631	8b3f880a1c18decd4b8050e96670e073
21706	FRA Musica	[fr]	\N	F652	F6521	40c6bc2b2f242f7f82596faad99eda53
62368	Wad Family Promotions	[us]	\N	W3154	W3154	de0a7a4d4939579808aca15cb27fcc67
34335	Vrais Films	[fr]	\N	V6214	V6214	e231972810601e5410f2cd7c60410287
25920	Tai Shan Productions	[gb]	\N	T2516	T2516	ad73966c3656502fee4e9ef05609a7bf
42124	Sunsoft	[gb]	\N	S5213	S5213	f2bc6fa38793eec03bf06855a3aae772
40378	Lux Digital Pictures	[us]	\N	L2323	L2323	911790da1ff1c90620850f0c5f023286
14728	Wrench Films	\N	\N	W6521	\N	594715bbe6046fd16cd269c5234613a4
19987	Pulp Video	[it]	\N	P413	P413	0c173ffc52a4069f6943a40e8ee1df48
59393	VintageTheatre.Com, The	[us]	\N	V5323	V5323	42b69fabe89330a60ec673a07f9bbb3d
11803	MGM/UA Home Video	[au]	\N	M2513	M2513	22ee81a8f9bc6cb3d416f55fd523a257
62768	Audaz Entertainment	[us]	\N	A3253	A3253	fa95e92eabaa753987ab10861b6d5781
69754	Melvin Simon Productions	[us]	\N	M4152	M4152	e28d35f7b4875772bddb1d921bb84d2b
4437	Fernsehen der DDR	[ddde]	\N	F6525	F6525	1c8c48abe81033f0cd3b1fa8d23c7bcb
53407	Quest Management	\N	\N	Q2352	\N	8c240f369a274b1971f199a03540de47
13714	House Of Films, The	[es]	\N	H2145	H2145	642891b1db8293b9079be198b7f80687
42193	BBC Film Network	[gb]	\N	B1214	B1214	9de6d8628398fe5edec88880b93453d5
32793	UMCU	[nl]	\N	U52	U5254	4373d5cef4f0f5be08af17ffef3fe4e0
31866	Traffic Entertainment	[us]	\N	T6125	T6125	3bfd8893431bcbedbf4a2f3aef13c2c9
564	Trinity Broadcasting Network (TBN)	[us]	\N	T6531	T6531	eef36f9edb939dfa2a13d058d6c9e889
46238	Visual	[gb]	\N	V24	V2421	d5f2c4502f5af4a66057d2e8040ff16a
67342	Dean Film	[it]	\N	D5145	D5145	4ccc5ccb1fb61f188ce4363062dfe0e3
36647	Udruzenje Gradjana Multi	[ba]	\N	U3625	U3625	cb5d00b8c73edb63bb04f73cf507e075
42588	News Room Productions	[us]	\N	N2651	N2651	814aa15caa9c061ed149df0f89eae79e
7018	Televisa	[mx]	\N	T412	T4125	7c10decd5a9cefa709116791c80df754
23239	Brooklyn Video	[nl]	\N	B6245	B6245	3c63687f868536f439d71f39d032dfc1
8784	Nippon Housou Kyoukai Satellite	[jp]	\N	N1523	N1523	8ffccf2cb26206c63bc2dd72c3e98eea
31944	Rosforth	[dk]	\N	R2163	R2163	6e721b38f1e480bf4496aa4e6201710d
48644	Calinauan Cineworks	[ph]	\N	C4525	C4525	e8dd589f050fb27e6d630cc7ac4665c7
47198	Khussro Films	[in]	\N	K2614	K2614	0cc870b4fd224a85daf4eb0825e4e827
42815	Altschul Communications	\N	\N	A4324	\N	fb34c401d9151205e4a64d9b857c841e
14291	Herbert Richers Produções Cinematográficas	[br]	\N	H6163	H6163	5f5ae3f315291848c8683e4d84772658
40285	CVK Kvadrat	[xyu]	\N	C1213	C1213	a7c58bfbd0f8c8737059d599d147c2db
59197	HBO Entertainment	[us]	\N	H1536	H1536	f800d21188aece86fb4784bf418eeba9
18428	Fujikan	[jp]	\N	F25	F2521	2d62d2e816a20a0f83a2a10a35cc4250
47729	Tassili Films	[dz]	\N	T2414	T2414	978accdc668ec91ba30aa96f688ca7c1
49880	Mamaroneck High School Video	[us]	\N	M5652	M5652	d2e1ff05ea57f7e266eaeccd19dba70a
29586	Maryland Center for Public Broadcasting	\N	\N	M6453	\N	5345344e984f1f9bd98a95487b878c81
54404	Six Elements Films	[gb]	\N	S2453	S2453	6290769816da2d5ffffd923eb9fd4bb5
34235	Stina Eriksson Film	[se]	\N	S3562	S3562	10b006246d62c06438f601d59f42243b
42701	Werner Brotherz Production	[se]	\N	W6561	W6561	15707e679f09652b3bd58375a7f348e1
1830	Microcinema International	[us]	\N	M2625	M2625	09489599f353bf902ceb1f3ffa3c85bd
54035	Niagara, Niagara LLC	[us]	\N	N2652	N2652	8bf2e2200c8aad74c326292f6a2cbbf4
19461	BitComposer Games	[de]	\N	B3251	B3251	000be7272f3c1b000ec5e960908c67d7
64248	MGM-EMI Distributors	[gb]	\N	M2532	M2532	3a5df3a4007c725912dcb9184d9512fa
14227	Walturdaw	[gb]	\N	W4363	W4363	4cf75b12a24186e6cfd20a8b6b0d8198
47268	Putas Producciones	[es]	\N	P3216	P3216	651c6a23511a99548b8e98b2985b39a6
18715	Essentia	[it]	\N	E253	E253	010e9214e40aada9108d1550e5d0564f
27303	VideoVisa	[mx]	\N	V312	V3125	4eb85067ecf099fa6780f1dd951670d6
6458	Focus Gesundheit	[de]	\N	F253	F253	adf01873594b1cb00a17f4ccc4f1ffe0
51964	The Asia Society, New York	[us]	\N	T2356	T2356	670e8169f0361dd456b6c06719c9160a
42776	Hiero Imperium	[us]	\N	H6516	H6516	00ace0824215151681b68861ade56cb8
50306	Sociedad General de Cine (SOGECINE) S.A.	[es]	\N	S2325	S2325	9260cdada84446c5a9793ca35a434426
42564	Yung Hua Film	[hk]	\N	Y5214	Y5214	cec79143eea3a7ac7c50ccd10c9e65cd
55125	Utah Moving Picture Company	\N	\N	U3515	\N	c6733f7d11d194eaf1988d419f59c1e9
5073	Antena 3	[ro]	\N	A535	A5356	2f5d548f7962efcae10e25e14af27a9c
26221	Impulso Records	[es]	\N	I5142	I5142	15df09ad098d26101c633f05df4bab5c
18305	Pacific Sun Entertainment	\N	\N	P2125	\N	514283858b783555c6ed1499868ab4ac
10385	Final Cut Productions	[us]	\N	F5423	F5423	1f253e915f534f7b7f3fd7309ce8a7c5
53704	Jernigan Films	[us]	\N	J6525	J6525	116373a1d9dffa8d6f54a81404310d34
16801	Live Film & Mediaworks Inc.	[us]	\N	L1453	L1453	24e00e0d691277966cde768923c2ba8e
32672	Cosmopol-Film	[at]	\N	C2514	C2514	a7ee41b053e13aeef083f51ea1d8f9a9
33647	Garagenfilm	[de]	\N	G6251	G6251	cb7abbf6ec701cf4d674f71cc3c681b2
10062	Allstate Insurance	\N	\N	A4235	\N	13230716ad7e641743428255a9ae71bd
36636	K.P. Sasi	[in]	\N	K12	K125	a135305076b6c15eedd842376d856603
25343	Talent Television	[gb]	\N	T4534	T4534	1e7de1a97977f619a1284dc917d5cd1d
32361	Hawke Films	[nz]	\N	H2145	H2145	057f76cef11d483936b573d76f8f8e44
26923	Carolina First	[us]	\N	C6451	C6451	49adc8ab0a4c6e6fd42c4a5fcb47d10d
10273	National Science Foundation	[us]	\N	N3542	N3542	95a5ed1e69cbe0b51eccbe3773223ed6
62448	M.A. Marcondes	[br]	\N	M5625	M5625	0e16c5b3d980cd7cab4a38dd00aaad3a
55730	PLO-bureau	[be]	\N	P416	P4161	48c1802a2087330a6bd54e8f2526ccc5
60840	Cadro Films	[hu]	\N	C3614	C3614	8c219c8eb51ca66e6745fe63b0a5a674
34160	Hand Crank Films	[us]	\N	H5326	H5326	f4fc9a3d1257e2344f6110fbb4be5b74
60905	Brooklyn Atlantic Films	[us]	\N	B6245	B6245	6eac8275f80bf73aee972f43bbf653d0
24107	Buku-Larrnggay Mulka	[au]	\N	B2465	B2465	602dbe04d75e576fc2919062471997f5
30212	Les Productions de la Géode	[fr]	\N	L2163	L2163	fdeb5ef442074f8d90847c994b2f62dd
29476	A. Gonzalez Rodriguez	\N	\N	A2524	\N	f60667b645ba078202b3bfa65c2e11db
25197	Stefan Studios International (Stefan University)	[us]	\N	S3152	S3152	2293703ef0d0c93619c62d1c339ecb7e
68512	Icadyptes Distribution	[se]	\N	I2313	I2313	204d78aa7a9240d5bde48b3d07bfea46
54517	Lovcen Film	[xyu]	\N	L1251	L1251	2b42f936900c300b9f30806896a89786
17001	Black Starz!	[us]	\N	B4236	B4236	9f002ab1f9f9d203cb9eea77b649e7ef
12301	Legend Video	[us]	\N	L2531	L2531	e7aac7f15b0fc6d5e26b3c3549a63893
37639	APA Studio	[us]	\N	A123	A1232	5b29ba1fc076338e97b46ec2e544bb0d
1206	Rock House Productions	[us]	\N	R2163	R2163	abf1efe0cc979a0d686aa5083b2db5a1
30450	Unilever	[ph]	\N	U5416	U5416	89f0124ee68c7fc3e57b1ef6d16c2448
59035	Match TV	[fr]	\N	M3231	M3231	751487d2ad5d7eeb9a0d0f08e91fd624
23893	The Grundy Organization	\N	\N	T2653	\N	20a2ab84a3dddb4db83e644e59c297b2
56928	Alliance Entertainment Singapore	[sg]	\N	A4525	A4525	863a3df7706675e2a81ffb478bc9eb7f
36621	Protex Trading Company	[us]	\N	P6323	P6323	4aaa93de82fcc1923e3bdb37c6415775
60319	Film Images	\N	\N	F452	\N	7445e10675f217f01adf7bf07c42cbce
18902	Cobra Productions	[us]	\N	C1616	C1616	9d59952c7cb54d28bb2b4ff3db70d6de
41777	Musical Collectables	[gb]	\N	M2424	M2424	6e21fb871b7c233c905fdc0e077c3a10
48964	G. Dentener	[fr]	\N	G3535	G3535	a002b39f7ddb05d5fad298b8ce84f395
69816	Vinterlys Film	[no]	\N	V5364	V5364	16178fc896b5ddf684fbc0765657b021
28849	Alterego Films	[fr]	\N	A4362	A4362	8b3356cd590d3faddd9b9f5e6aecd1e8
9610	Telemontecarlo	[it]	\N	T4532	T4532	7d02068351d2877b36f613a71471e13b
31701	Not a Number	[gb]	\N	N3516	N3516	0a47b131fdb70a96f508b96a4d11f3ab
24444	Accent Films International	[ch]	\N	A2531	A2531	f8cb3537f6a511e07244dad7c5f97ba6
20242	Future Focus Films	[gb]	\N	F3612	F3612	0c3391cbe8891c819eff73a462f21a27
38078	Twenty Seven Films	[us]	\N	T5321	T5321	03be78fda32cf2b7a1d87b587b3cfd28
68139	Artists Confederacy	[us]	\N	A6323	A6323	c3d10295fdb352b882813ee9bd11b188
48012	Wonder World Pictures	[es]	\N	W5364	W5364	eaeb66e3f632ca3178979fad641186fe
2485	Total Film Home Entertainment	[nl]	\N	T3414	T3414	08a4789a6fdf4ffb278de8ca902bdc54
37351	José Manuel Villanueva	[es]	\N	J2541	J2541	c46178fc6d1e1b8fcc64380f852b149c
21373	Agar House	[gb]	\N	A262	A2621	e66ea3abfe4f370fa6d5444e60c63848
43259	Hoverground Studios	[us]	\N	H1626	H1626	d81620fd8304d554974e2cfce414e1ea
25984	Clingy Films	[gb]	\N	C4521	C4521	aae21672181b00bc2c032b18f74c7a7e
35596	Atlantic Video	[us]	\N	A3453	A3453	f96e63fd5314f7cd60a5f72b1495d296
56899	Snowblind Productions LLC	[us]	\N	S5145	S5145	030fd4b1ed4eb14d606b4c0cf95a61dc
29104	Lancaster Films	[fr]	\N	L5236	L5236	84ee9f0f0b66a13fd87844e6d1eb4def
48990	Albatros Films	\N	\N	A4136	\N	7e35ed02b75cb36eb531cba86a5e572c
37374	Lardux Films	[fr]	\N	L6321	L6321	3b5ccbcce55d5883fa601ba52da1c980
32877	NuWorlds Distribution	[us]	\N	N6432	N6432	64d015c722dd5b8fb08535856459ee18
57588	Troubleyn	[be]	\N	T6145	T6145	814cfbd2845fd803e70c803287f0d5e0
68809	Piratenpartei	[de]	\N	P6351	P6351	5595066b9bcafddb403fde6c4206fd6b
29276	Filmpartnership	[au]	\N	F4516	F4516	e50632abca2f6e5cb0fa940799fe7b73
47349	Nichiei	[jp]	\N	N2	N21	7c0cb2f8ff962af3d4ef7f3098f56ef4
66090	Genre Pictures International	[us]	\N	G5612	G5612	7e33ff49dc9b6a4c7ece2041c2356bdb
39311	Escort Video	[us]	\N	E2631	E2631	a82c3a792f3da1110304c2b955dee991
27105	Seattle International Film Festival	[us]	\N	S3453	S3453	2d2ded877d3cb02b11a33414e9a792c4
28826	set22	[it]	\N	S3	S3	278cc929e36a86587cbfeaa582a8a38e
59718	Avanti Film	[de]	\N	A1531	A1531	222d21d33a68129b4648240ac58d1073
29110	Atropos	[cshh]	\N	A3612	A3612	1f76e2bd454f01f26951da33261e040f
35221	Lilienthal Verleih	[at]	\N	L4534	L4534	9e41fa98b17161a003db1851baf46801
13384	GT Interactive	[us]	\N	G3536	G3536	4ea1f96cfad1890e7f7793d77f8bb4c1
55732	Lichtspiel Entertainment	[de]	\N	L2321	L2321	f296446c86da87ebdfb0e34045e43c51
45522	Tai Entertainment	\N	\N	T5363	\N	4610bf637b25ec25acad803c6667b547
55511	Athenaeum Films	[us]	\N	A3514	A3514	e60b88d66f1eb7f916703c8ba7063277
21350	Sage Films	[us]	\N	S2145	S2145	f152e13cf92f4b51f8c1383fb695acb9
23970	B-Pro	[nl]	\N	B16	B1654	4119d901ea64c6e0b7e7ccf7e0ac283b
458	M1	[hu]	\N	M	M	e627d4ba3c2666051c6f49499ddcd58a
66580	Convivencia Forever Films	[us]	\N	C5152	C5152	b72dc8ef41c2c2aee002531b02611c60
58259	Impact Productions LLC	[us]	\N	I5123	I5123	b4be9d3540a9cfc294391a16e2a2fa35
54135	Merle Productions	[us]	\N	M6416	M6416	41639a2cfdc4b76b665df501b3e63a86
7968	Main Antagonist Productions	[us]	\N	M5325	M5325	3ed3d8ca1ae5a7f63c9164cd3d085693
68900	Massway Film Distribution Co.	[cn]	\N	M2145	M2145	1ff30416c0c1bcba52f2d4c40fbda95f
23550	A.F.E. Corporation	[us]	\N	A1261	A1261	1536a1580220e5d7da3c32204bd4febd
56730	IDG Entertainment	[us]	\N	I3253	I3253	9b7227f5193f527a396e52e992b3c404
20702	New Daydream Films	[us]	\N	N3651	N3651	487bcc33a916621507d137d7213a0562
33534	Uko	[jp]	\N	U2	U21	1e4fbcc2d6a64c8bc181160d2f9e40c9
47155	Kambeckfilm	[de]	\N	K5121	K5121	bb4ad737226c68f3e00c0521654d0cb6
69404	GNC Films	[us]	\N	G5214	G5214	6828574a27f5aabf37f89c0e61d804c0
10448	Warner Bros. Home Video	[us]	\N	W6561	W6561	9ff71fc3e0a38fe25a4659959a546f20
23862	Les Films de la Boétie	[fr]	\N	L2145	L2145	7ce57ea910dcd60cc4718548dc9a2021
53725	G.R.Pictures	[in]	\N	G6123	G6123	e18a8a44e7a9540ccfea90659255b5d8
66510	Rootbeer Films	[us]	\N	R3161	R3161	7f67e1e52c3d647c3abfc182a93a8b0c
67162	Synesthesia Productions	\N	\N	S5232	\N	c2666b68a1ec806e0e455f4ffacd721f
57996	Reels In Motion	[gb]	\N	R4253	R4253	4d35dd066ed4b6c88daf5c5d82dbe0cd
52483	The Sight Unseen Theatre Group	\N	\N	T2352	\N	e7b57e3332c6adf83f14c08f907e4ec6
51534	Zenith Film	[it]	\N	Z5314	Z5314	be6ca72440e100388523477a28c69af6
10221	Martell Brothers Studios	[us]	\N	M6341	M6341	aa661988fa16414030da64561ca19c74
45568	Metro Video	[de]	\N	M3613	M3613	5082c3a6298afef5a9a29a74dca6d17c
20169	Parco Co. Ltd.	[jp]	\N	P6243	P6243	6c1f24322c63327be004f560215bd958
19236	Gotham Pictures	\N	\N	G3512	\N	80aeb2b84913b89cb0223034f020483e
25096	Kalasangham Films Release	[in]	\N	K4252	K4252	a651d50531dd31ee6e4776053dda5677
5474	KJ Music International	[tw]	\N	K2525	K2525	1d0d36fd677bac8877eb8cceac8c3092
26430	Paramount Magazine	\N	\N	P6535	\N	75a9bd45ad7d3f7cc727718da62463a6
35060	Cold Meat Industry	[se]	\N	C4353	C4353	c6022d9e3baed3bad61d5da58d280a6a
39183	Palm Beach Entertainment	\N	\N	P4512	\N	7ec3bd9df562b03feca31d8919c8f7d6
49002	Ciné Films Association	[be]	\N	C5145	C5145	787735cec85ca856c98a944b676b6344
22244	FF Film & Music	[hu]	\N	F1452	F1452	17156f57fd85c7b01f107c97688203f9
39276	FMRL	[us]	\N	F564	F5642	040f83c7d4d4a8454ab8bafa801c295f
29722	Cruzical Film & Media	[se]	\N	C6241	C6241	0335bbf7bbbeb08c0b82b748d8b6e152
9634	USA Talk Network	[us]	\N	U2342	U2342	00d4223caa13bb0ccd2eb0c6aac6177d
26936	Cine Sales	[us]	\N	C5242	C5242	5a344d72e7104649d637eb0f01aa386a
28353	Unique Films	[gb]	\N	U5214	U5214	ed72683d5d61e4d54a3659ad76082f03
7446	Nippon Terebi	[jp]	\N	N1536	N1536	faeea8dad3731e1e0b8b12c9120ee79e
41863	SystemSoft	[jp]	\N	S2352	S2352	3bcff13f55b961e66cc1531e49bf3576
49017	Quark Productions	[fr]	\N	Q6216	Q6216	9a4b95efd464ba1c753fd49c6312d146
61893	Altofilm	[se]	\N	A4314	A4314	7fa9cb62cd8685d768f60dfd7857ae7f
51495	Labour Party Films and Media	[us]	\N	L1616	L1616	15b6b7745f84571d9979d456f65ccd30
15564	RKO Radio Pictures	[br]	\N	R2631	R2631	7f2e81e71c04557e81e98c4612bffc4c
4515	One Movie	[it]	\N	O51	O513	70c16d2d06383839dc98ad26abd0fef0
42606	Windsor Picture Plays Inc.	[us]	\N	W5326	W5326	b910dd6ed34827eda955605e7c60e8b7
33466	Cote Blanche Productions	[us]	\N	C3145	C3145	f95c977ed803cf6457bf9a94a5eda216
55145	Matemotja Productions	[us]	\N	M3532	M3532	e4600584226a95daa78d9f7372e0fef2
32741	Karola Czerny Filmverleih	[at]	\N	K6426	K6426	dfaa2cd8b8f27c47f19a930b0317de2d
49771	16Arts Films	[fr]	\N	A6321	A6321	ed926fd02a1e1163a25e396f1188762e
66170	Bishop/Pessers	[gb]	\N	B2126	B2126	e77808e5578e7a29ab69e2673ef828d8
31691	Rule	[jp]	\N	R4	R421	810870f0427fab07762cc24d6373a43b
12576	Videoflims	[ar]	\N	V3145	V3145	081a920231192086bcdd6c6d0126c2bd
35829	Aspyr Media	[us]	\N	A2165	A2165	8642a899309b8a79e0ee6ef418a36c14
33080	Peliculas Bravas	[ch]	\N	P4242	P4242	4b22b0e5f6fad4ea8a3c5e5501622a83
3957	Seattle Opera	[us]	\N	S3416	S3416	db1fb36a9ecc1510639156eaff2f1286
20112	Sensito Films	[fr]	\N	S5231	S5231	83e6cf6cb114c1bbaa4495542bd60c06
26580	Allied Artists of Indonesia	[my]	\N	A4363	A4363	55dbfb5611eb2586fe01743a2c366ef3
14350	Markt	\N	\N	M623	\N	8f5d01b8621c037504efb2425c0f5bf1
20830	Other Cinema DVD	[us]	\N	O3625	O3625	06b38047d309a9da867d93b7ac376221
48273	C.E.M.	[it]	\N	C5	C53	0b8f7a4599c4fa5ff6faf815f38ef47a
40491	Prism	[gb]	\N	P625	P6252	8b1a8dbdd6671ba873eaad9de76a67fe
8630	Five Ace	[jp]	\N	F12	F121	a728aca885587001e8b5bd08bb2a8abe
10135	Purple Cow Productions	[us]	\N	P6142	P6142	6fe769cdeaf4ef63e656c78fa4f2df47
53559	Topazio Filmes	[br]	\N	T1214	T1214	f61eae532c1ffe2613160364d02d0eea
15250	Independant	\N	\N	I5315	\N	b06a91757225a6da3cd67bfb71b957aa
2073	Canal 9 de Buenos Aires	[ar]	\N	C5431	C5431	bc3be6a7eb2776598c4bcabbc013b2ec
57708	Borde Releasing	\N	\N	B6364	\N	82209b70b528228444b83549843160e9
26284	Charles Sherhoff & Associates	[us]	\N	C6426	C6426	599a166223f509eee750cdca9f6b7d49
58100	Codania Film	[dk]	\N	C3514	C3514	11ef237aad3680618bd50b84353d3b49
50415	Red Candle Films	[us]	\N	R3253	R3253	77956349c904e8bce184fccf96aad5eb
42530	Dillon Markey	[us]	\N	D4562	D4562	095459fe5ad807744891a5a3196c9375
59511	Magdalene Entertainment	[us]	\N	M2345	M2345	6f2f99c4c6b692c205f5933a8069e15e
34509	Onix Filmproduction	[ch]	\N	O5214	O5214	9cd9b358cb84de95d91456b9daffac3a
1803	Tu Universo TV	[pr]	\N	T5162	T5162	9f557b9dd8a7fe7d8d7c5d3b25443faf
66362	American Portrait Films	[us]	\N	A5625	A5625	afada6636b87fe27d5c5a2919ccd4416
63290	King	[nz]	\N	K52	K5252	1ccbb58287894e6426c5225e5cbbb9ad
32678	Sofar-Film	\N	\N	S1614	\N	c801783fb22ec62cd207a34c1235d73e
51685	N-cite	[us]	\N	N23	N232	bec149798cf38f4f53301a18e97b8438
26051	BISD Films	[us]	\N	B2314	B2314	4c0603bf454d43f01fd13438453ff299
70186	Megasteakman	[ca]	\N	M2325	M2325	3543161e1ac43783a7ecc16eb2605d05
13119	Le Fresnoy Studio National des Arts Contemporains	[fr]	\N	L1625	L1625	40e33307d12106fda33d840d3f96ea2e
54822	Spy Films	[fr]	\N	S1452	S1452	0570b74cbf657b45b7435dacb37a1db2
9925	KSHO-TV	[us]	\N	K231	K2312	b6b663164e92ca41c74c2bd17248644d
27718	Sterling Pictures	[us]	\N	S3645	S3645	6bdd75024e74c4dcf1ec52977cd8864a
29254	CD Choice	[bd]	\N	C32	C3213	05842aa17f9dbf012b731eac7cce87dc
48019	Magister	\N	\N	M236	\N	68a2059fe4f8bdc35880846f527c7b80
43126	Treasure Island Pictures	[us]	\N	T6262	T6262	1cfd9b3c32f5d0405c6e3d10b69f066e
46323	AMT Production	[se]	\N	A5316	A5316	48d85a29f672993322754c3daf7f224b
48987	Ceinvest	[cz]	\N	C5123	C5123	f8ebe23c1526539a4a78e7d7a3d8511e
45881	India Film Exchange, Film Division	[in]	\N	I5314	I5314	581d461e54f164723ddd6477bf1380f2
69220	Voices Productions	\N	\N	V2163	\N	09963783c6185a9ddac7b530584181b7
44344	Università La Sapienza, Roma	[it]	\N	U5162	U5162	8154e8b7d23edfdb7dcdc17d4ca2ca96
44414	Epileptic	[fr]	\N	E1413	E1413	68523d962871ae0506fb4df57d279ef2
16993	Virgin Video	[gb]	\N	V6251	V6251	6ad58a8cadbc2b4614bf959c2dac288b
44002	Behan Brothers	\N	\N	B5163	\N	a3ef2a44dfc4e830c2530130f10acf54
28630	Concorde Film	[at]	\N	C5263	C5263	343398d2dc40e101a62d421c27aa0a47
14077	Forgotten Films	[us]	\N	F6235	F6235	8bc9636187fd7b9bb55582ea53e98998
10616	Corvus Film	[hr]	\N	C6121	C6121	75f48aa614dc73db25f1d1ddb10679b9
60942	FilleFilm	[no]	\N	F4145	F4145	06008726474bf903468802a9f6ad8ea8
384	Fox Television	[us]	\N	F2341	F2341	628a9d3887bc13c1833bcabba73adac9
60788	FlickU.me	[us]	\N	F425	F4252	98e26f6d5ca51ceb5adc9b111f00b0a6
35620	Solarise Records	[gb]	\N	S4626	S4626	55f32aea38048ad97c36165cc9eb2fa5
57148	Gazelle Films	[us]	\N	G2414	G2414	7acb6cb2605a71e5831daa16f3448207
61664	Road Dog Productions	[us]	\N	R3216	R3216	7e78d8cf0ea64074746d92ccb6d81a9d
23811	Lux	[gb]	\N	L2	L21	3011869c974b6ca30b5a6b28c74afe90
55948	U.S. Department of Health and Human Services	[us]	\N	U2316	U2316	da37eee0499006d8d66631b904240a52
11149	American Mutoscope & Biograph	[us]	\N	A5625	A5625	63b83ddcf4b81dd4bd4b2f4215b8b4fe
17718	West World Films	[gb]	\N	W2364	W2364	60bc082b13492a7fac9f8391c152936b
5838	Vishnus Trumpet	[us]	\N	V2523	V2523	d1f0bfaafeafc37bbd0cde49f2a703d8
64552	Ghost Man on Third Productions	[us]	\N	G2353	G2353	2fdfd26144434b6127e20c45234eae97
31897	Nanhai	\N	\N	N5	\N	b8b8d9bb661357a49824d5e72d128d70
28793	Sigma Production	\N	\N	S2516	\N	6c0dadd906398ae95ae911ff60f61f22
56452	Action = Life	[us]	\N	A2354	A2354	8200a8c4450e59345df7400a270bc9e1
12213	MTV On-Demand	[us]	\N	M3153	M3153	1338b36362077c10ea90259a4e1b00ae
42940	Ican Films GmbH	[ch]	\N	I2514	I2514	133b301515cc7f61d13a9137da7f48bc
29817	Azov Films	[ca]	\N	A2145	A2145	bcff021c3f7514709fa7455beaa08dd1
35677	Context Studios	[us]	\N	C5323	C5323	ff8262ea4d12ddfcaa9ae790cbd964ef
8272	Southern Television Guangdong (TVS)	[cn]	\N	S3653	S3653	f218bc4ddc48c16e9fcddc4736c30f2c
31076	48 Hour Film Project	[nl]	\N	H6145	H6145	1073430405e01383ad354f57e7b515b2
26704	Minerva Films	[gb]	\N	M5614	M5614	da8bf1211ac5d363adc24f857e39d3e3
53783	Utopie Films	[fr]	\N	U3145	U3145	eec90590c2f677c532eb8a85968d6ab5
13609	European Video Corporation (EVC)	[nl]	\N	E6151	E6151	ca3c9cb609621aae64ad4ca21a84ecbd
64388	Reel Entertainment	[au]	\N	R4536	R4536	4e8782fafda9abbf48c3543d423d984b
11198	Rim	\N	\N	R5	\N	6a05a3d9585e7e6afe11143fa359772c
18059	Video Signal	[gr]	\N	V3254	V3254	8c4f626c12a52c7956a728efa27b871c
19138	U-M	\N	\N	U5	\N	c57b94ee2455d6932eae85efa2bfc091
67595	Imperial	[pl]	\N	I5164	I5164	98f55d049c5f5c2111455d759a72d110
51455	Marignan Video	[fr]	\N	M6251	M6251	beec05bb43afa7b67d29f7711e64cffc
7527	Discover Real Time	[gb]	\N	D2164	D2164	c6e06dc533e04d49c4c476ce21217cf2
22528	GFD	[us]	\N	G13	G132	357054320036e659d376ab648a8863f2
10042	2001 Video	[gr]	\N	V3	V326	a1f8141ba0a8babc9e9569eb8176e654
62306	ATH Productions	[fi]	\N	A3163	A3163	872a5c101085b2aeaf24aebb11437e8e
2703	Studio 23 Productions	[us]	\N	S3163	S3163	10731e272885ddb6f534c86906ba3c28
39820	Down Home Films	[us]	\N	D5145	D5145	d0bd9a9400774b57f62e0c8e40cb0341
66569	WhiteShore Films	[us]	\N	W3261	W3261	deaada427269a02da54119d6eb098118
66502	Mid-Century Pictures	[us]	\N	M3253	M3253	efb42279e640be193d40f108e8d34c19
51128	PyroMan Entertainment	[ca]	\N	P6536	P6536	3e02110b7f39f32fc84b07cb1745c178
48623	Chinatown Films Ltd.	[ca]	\N	C5351	C5351	fa01d4af2452f9b6830d54352ece5160
45435	Pictorial International Productions	\N	\N	P2364	\N	0dcbd0f428947714f5db6bb574a3db50
47662	Acof	[it]	\N	A21	A213	28ba2e70c1d95098838853052adc96c4
5391	SAD Pictures	[ca]	\N	S3123	S3123	68c253dcee35ee39a298b9596cc7f954
4014	First National Pictures (II)	[us]	\N	F6235	F6235	11ea022cbae9b7de1147fbfa3f57e8a6
28867	United Pictures	[it]	\N	U5312	U5312	694a1fa8caf9836bb3d4cfb5deeb597e
24985	Traci Lords Company	[us]	\N	T6246	T6246	172ddc03c58cab5efae159b8b6817acb
25591	Kindai Eiga Kyokai	[jp]	\N	K532	K5321	333df76f94e8af9f17b709262effc409
22653	CLMC Multimedia	[pt]	\N	C4525	C4525	ef1e06db7e44e756a4a152dde6aaf548
65806	Abandad Film	[ir]	\N	A1531	A1531	e5cf21feca6de9c9d1dfc38bd2f4f9d1
38815	Wiener Urania	[de]	\N	W565	W5653	0a569e12842fcea9db4499d98bd032b5
28454	Les Films C.O.D.I.F.	[fr]	\N	L2145	L2145	c541c3cb911608f446be3e9615b8d667
52686	Hem Films	[se]	\N	H5145	H5145	3c964881b0ea1d4cfaed209fa7cc8523
69938	Inter-Varsity Christian Fellowship	[ca]	\N	I5361	I5361	7de5be9e8e4851d010d18f854035ef51
33564	defLemonkid	[ie]	\N	D1452	D1452	bb9eb5d951ccfaec1d5bd8a1495a9319
8006	Japan Home Video (JHV)	[jp]	\N	J1513	J1513	465b372d9013dc7be0accd70d1160db5
47147	Fellowship Art Group	[ru]	\N	F4216	F4216	87495b717bd8e10ad08838478bed6c0e
67942	Arlen Entertainment	[us]	\N	A6453	A6453	fc776b81c74927e26259c0d07eb8dec9
282	Prima TV	[ro]	\N	P6531	P6531	a4b28987f4b096f8e06b29d1b7ddbd61
55297	Life	[us]	\N	L1	L12	fdd1b97fb1bf4183216174448e48792b
56563	Videomania	[br]	\N	V35	V3516	0db818c8551a905004eaace72d69d349
10980	Chengtian Entertainment	[cn]	\N	C5235	C5235	256369c67448f3d43a93b034e389e751
27692	Ostrow and Company Producer's Representatives	[us]	\N	O2365	O2365	125ace1f7a1b1f533a7bddf9016cd3e3
56018	Dune	[fr]	\N	D5	D516	e86947e6df621d91c489971cfa803e09
10164	Big Media	[us]	\N	B253	B2532	a006f1d3e3b9b1efea8d66a0b6bcbe9b
1886	Thames Television	[gb]	\N	T5234	T5234	e022ea2d3a1ac9a1bc60e66a6c358268
42641	Statens Filmsentral	[no]	\N	S3521	S3521	79e47ee53e588b51aeefc218a6bbced0
13930	Pan Européenne Distribution	[fr]	\N	P5615	P5615	d5db9fd039b7869cdbfb0ea2a6c68515
6520	Windfall Films	[us]	\N	W5314	W5314	069865c16c43ba2a0a352df4311daab3
33872	International Film	\N	\N	I5365	\N	ffc6b7b0996d626a7c47688e4290009c
66825	Vectorinvader Productions	[us]	\N	V2365	V2365	e3283c754b27279794a40974a15f6e3b
20425	Cherry Vision	[cz]	\N	C6125	C6125	7d7d99dc6e97e1915e23e25eb97d7af2
49755	Arpa Video	[be]	\N	A613	A6131	6bc596ce926f2040b6284db7773c6435
58015	U.S. Department of Defense, Information and Education Division	[us]	\N	U2316	U2316	a317292267f5ce30115389dcb2aa5efd
3442	High Hand Productions	[us]	\N	H2531	H2531	accfab7554ee0f72a57183cbda3bd52a
9961	Hallmark Channel	[cz]	\N	H4562	H4562	622592ea7b9583922604a88940ccbebc
5937	Thriller Video	[us]	\N	T6461	T6461	9ce6e1db86604c62a58566159cd7405f
41411	Game Arts Co.	[jp]	\N	G5632	G5632	bae67f99619c38d4a83d011142a1ee5c
23594	BMG Finland Oy	[fi]	\N	B5215	B5215	c87341c089171d3aeb97409a7eb6a2dd
10214	Mark Goodson Productions LLC	[us]	\N	M6232	M6232	aba3ba3cb9ca9242311523783d785e53
7821	Jim Henson Company	[gb]	\N	J5252	J5252	80b75f30ce5e9c2636c5a8e417a8cef8
33231	Action Video	[gr]	\N	A2351	A2351	2cb04da95c147c1a5da78bb6b8e1b7f3
8011	NickMom	[us]	\N	N25	N252	1bad3c79d76a1b2ff4ec8b22701bb9f8
35754	Gilde Studija	[lv]	\N	G4323	G4323	27d541225fc242bcc1c5010d0fbfeb36
23483	Spectradyne	\N	\N	S1236	\N	e9f1716a141a5b706b175e86fd5388fe
10105	Starrunner	[us]	\N	S3656	S3656	91d297e8402169a0062233fea5ad8607
61609	Masculine Magazine	[us]	\N	M2452	M2452	6890a096a66582dfac0d2a0ab7ad44d1
20266	Sub Pop Records	[us]	\N	S1626	S1626	36499adc83f81466e625effce72cdcf8
57428	GNR8 Film	[gb]	\N	G5614	G5614	939430f132571b9beb5a00300cbc8dd8
64833	York University	[ca]	\N	Y6251	Y6251	dc57964bce4c9e9a531eab1ebea25dd2
58304	Cannon Releasing	[pt]	\N	C5642	C5642	d6b4f70641e800ed0e31d4649dd52db5
40310	Hales	[jp]	\N	H42	H421	18466b6d2090e7d80c2137e8f83aa718
48707	Lyon and Lyon Productions	[gb]	\N	L5345	L5345	f6444242d6d18a93dbb4c2aecb4439a4
35141	Silwa Video	\N	\N	S413	\N	8623bee760686163aaec761a4807db72
26387	Rogue Taurus Productions	[us]	\N	R2362	R2362	9c01bc6e74c262e1545a0baf27a0c7db
8985	Concorde Video	[de]	\N	C5263	C5263	52631c96af5a8b80dba074d6adc39a3e
38347	Underhill Films	[us]	\N	U5364	U5364	96effd437b94109dce111e55ba0828fe
32599	Deutsche Mutoskop und Biograph (DMB)	[de]	\N	D3253	D3253	25bb0569ab166d69b8f2a93ab43fde00
40127	RKO Radio Pictures	[it]	\N	R2631	R2631	a5876bbe0771d10d1355e6ab70f68d05
33299	Mountain Deux High School Productions	[us]	\N	M5353	M5353	e1a7428e16a64bdd4adcc782cce9c962
30392	Blowfish Studios	[us]	\N	B4123	B4123	474aa3600228e5b346947de2ed698a27
42752	Universal Pictures International (UPI)	[mx]	\N	U5162	U5162	dd0e7aef50aaeb7f9e5763807b47ab58
37208	SMV	[br]	\N	S51	S516	ca30b95d2ce7678a578122d9cc01ac33
62467	Drumsandthunder	[gb]	\N	D6525	D6525	7e1802ddf209cb832c061281e2abd445
37868	Kalia Films S.A.	[es]	\N	K4145	K4145	7a3120d3a96d0b5a9368d41934a6bcad
29965	Fazil	[in]	\N	F24	F245	d5d699cd36bde3a65e250f927b969341
34696	Eclair Distribution	[fr]	\N	E2463	E2463	9489971cd0ff5acd5ebd0d5b71ed31c1
5976	Haunted RI Productions	[us]	\N	H5361	H5361	d51086a59431de2b9662554f1b318c9d
9280	Delta TV	[ca]	\N	D431	D4312	ee427e5d8eba04caf58bcbfa83ff92ae
13483	Compagnie Commerciale Française Cinématographique (CCFC)	[fr]	\N	C5125	C5125	33f0740efb6f41323a2885f15fe0bbd0
60045	New York Skyscraper Museum	[us]	\N	N6261	N6261	c3682ca4e62b4f9ce73ece324d7d135f
39215	S&N Films	[us]	\N	S5145	S5145	acbe1b4efd9fde9ce7041247b7ca6664
44728	Cross Wind Productions	[us]	\N	C6253	C6253	a42ca2dfc809dd3b36fdc57c938e7267
16474	20,000 Leagues Under the Industry	[us]	\N	L2536	L2536	7f3d446f5058f8e524d024670d34445c
15372	Gail Pictures	[us]	\N	G4123	G4123	db3ffe68983770421f5db387ac41053c
38467	Korova Films	[it]	\N	K6145	K6145	274a66339c78f17006d97b4823f66553
47885	K-O Films	[ca]	\N	K1452	K1452	703a58b3a28f8931a7472a7196e85eb1
35426	Haphazard Films	[us]	\N	H1263	H1263	e45e4e347d5306b3514d50121f32c99f
2240	Epic Pictures Group	[us]	\N	E1212	E1212	38b6724efdb892c18b995c2eacc91c81
57009	Slovenská Filmová Tvorba	[sk]	\N	S4152	S4152	866eefa3601da8f616c7704a7587cc4a
54804	Bavayou Films	[us]	\N	B1452	B1452	aab1ba413ed69c68431b0630b11f21eb
67968	Pyro Entertainment	[us]	\N	P6536	P6536	edcf3a121238c8a7edbc275b646556d8
40568	Ager 3	[it]	\N	A26	A263	8186e0cfedde2c7c213847ff0026f0a6
1185	Portfolio Entertainment	[ca]	\N	P6314	P6314	480a8dec08980799119b58a700ec4af3
33341	The Incredible Strange Filmworks	\N	\N	T5263	\N	8ab62bacadd3280949be6dc6806db6c1
8693	Alliance Films	[ca]	\N	A4521	A4521	03af8ef320b9d92479e68ef1054684dc
66816	Lynnvander Productions	[ca]	\N	L5153	L5153	cbf32d2537d3792fef8f46afe5432f44
56704	D.B.C. Entertainment	[us]	\N	D1253	D1253	c558c37cea2295a20b648da7d8c35e43
45551	Hidden TV Productions	[us]	\N	H3531	H3531	80850dc4da328b911d840a9fe1bd64a0
63741	Conscious Pictures	[us]	\N	C5212	C5212	170e19d13c0a979bdf4323942c231d31
17388	Editions Atlas	[fr]	\N	E3523	E3523	e329ea4397025c074821b5d59f51e4be
29964	Institut pour la Coordination et la Propagation des Cinémas Exploratoires (ICPCE)	[ca]	\N	I5231	I5231	71efb2c78352f005318267f26a05aaf0
47355	Black Cat Pictures	[gb]	\N	B4231	B4231	083b8969a2b4fe0b680a626b8539b2dd
28384	Go Video	[gb]	\N	G13	G1321	6aa71533e73d234fe6088911489d1bc5
20609	Twilight Movies	[us]	\N	T4235	T4235	7af9a0fa6d286fed383e9e83b174b97b
47721	Grup Media Art	[es]	\N	G6153	G6153	377cb4c68e8da42009e42ed9480a691f
45076	Liguria Film Company	[it]	\N	L2614	L2614	ab5224fe2ff2ae97b42c4281e49ecb7b
39989	Ginero Media Group	[ru]	\N	G5653	G5653	0a2ede432851731b2e2d851e0ae8e714
33608	Rai 5	[it]	\N	R	R3	a75f546cae1638b9b20f1351d2432637
36335	Torn Pictures	[us]	\N	T6512	T6512	981e11738b7e65f6fae8ccd44da83e52
67986	Fred Halstead	[us]	\N	F6342	F6342	70a8dcfc95339bd2400a8f95edd8dc7d
12612	Leeding Media	[us]	\N	L3525	L3525	39bd39103a55f976cfef95474468785c
41173	Cahiers du Cinéma	[fr]	\N	C6232	C6232	528802a0236e52af987bb556a2a18522
59830	L'Atlantica Cinematografica	\N	\N	L3453	\N	5073579880ab475024bb96f96566a0e5
23313	Kerosene Films	[us]	\N	K6251	K6251	8c7c42c7e5c5ed84b1ab13c59d86f9e8
46723	Prakash Jha Productions	[in]	\N	P6216	P6216	4120a8a8fe5a0761b61f72c0ee318a93
63821	ChocaMilk Studios	[us]	\N	C2542	C2542	31138accdaf60d505a68e9a4aedca10f
59635	United States Army Corps of Engineers	[us]	\N	U5323	U5323	b4d907f3635e78eae89979a349a3e1b6
13756	Synergy Cinema	[fr]	\N	S5625	S5625	6df6303cf6f476873e39f1e26dc4f370
13710	Loud Pictures	[us]	\N	L3123	L3123	6200ae61128faa5b032eac1d7fb4bea4
37106	Fuera de Foco	[es]	\N	F6312	F6312	99974fa1f67e970dce978e8de319c3e6
46948	Sujatha Cine Arts	[in]	\N	S2325	S2325	6380b1d82c9ca75e212384ad3137ebd5
3341	KECA-TV	[us]	\N	K231	K2312	d2795365381e1d406ef5a330b582c875
25094	Madhu Entertainment and Media	[in]	\N	M3536	M3536	0b844d4fb47640c6c2710f68d7845339
38855	Muenchen Film Akademie	[de]	\N	M5251	M5251	da9e2633447b422c42c2078bec22ab99
62956	Balarrasa	[es]	\N	B462	B462	8f5d49eb88ae40e9cee30ba7fda3bc7b
18633	AAA Foundation for Traffic Safety	[us]	\N	A1535	A1535	02acc9b4cc3f1b8af5c6223f2c4fccdc
69080	National Film	[us]	\N	N3541	N3541	fa006950e077bad82dc95f1c898074fa
49168	Séquoia Communication	[fr]	\N	S2523	S2523	e92a1ed9bab7dc290ed09923af29c3b0
24763	Time Story Group	[kr]	\N	T5236	T5236	a4e2d0d66e9ee19be680b92d0ecaa1ea
3440	Premiere Sunset	[de]	\N	P6562	P6562	f0546bde4622a110f7954ad5e88972ed
43009	Bosser-Films	[de]	\N	B2614	B2614	badc607618d8f61301d2d25c161f0d5c
39262	Telefilms International	[us]	\N	T4145	T4145	9a57bdf21d708f3009a4ab4f33aa0754
44251	Intra Films, Italy	\N	\N	I5361	\N	c936b365699a6238f2868fd50eb86b9e
5436	Mobilefilmworks	[us]	\N	M1414	M1414	9c2ddb0b3d1b0d34cee1c3ee614fc2c7
54110	Nival Interactive	[ru]	\N	N1453	N1453	35de6cb112b100ea54befcb2d80fc49d
52608	VN International Video	[au]	\N	V5365	V5365	42fc8cb9e4c8b44aac289e6a7f2ea3f8
45351	Kinoteka	[hr]	\N	K532	K5326	85e14628d899e506e14b49002cd86541
59794	Arena Films	[fr]	\N	A6514	A6514	e07ae714885662393977de2c01505643
43699	Prism Entertainment Home Video	[us]	\N	P6253	P6253	687bfc9b133d07d6e51063fbfc588d3a
54319	Nobody Knows	[us]	\N	N1325	N1325	fe26e6c3fa79aeb92fbd18791867961d
64326	Zbig Vision Ltd.	[us]	\N	Z1212	Z1212	215824599dbd95a5bef8418473776084
58468	CAF Red Tail Squadron	[us]	\N	C1634	C1634	cd16545900d05d54b54e308a73b1401a
40816	Cookies & Wine	[us]	\N	C25	C252	113481e3ca291327b24fb25c784bfb17
16089	Sector Vídeo	[br]	\N	S2361	S2361	f11410c0b5026e420f8dbae1d4d7bb00
44726	Creative Media Institute	[us]	\N	C6315	C6315	bd5b723698afcf5f5dc90cc7dc49f194
33038	Digit Anima	[fr]	\N	D235	D2351	88daa9cbc5b579113188708ba18d71a7
15534	Ronin Films LLC	[us]	\N	R5145	R5145	6ce1916c000c836f6a271bc60cf3125f
27076	Security on Campus	[us]	\N	S2635	S2635	ff80edd4fb476cdcb0ac08ab0216d889
15101	Condor Filmes	[br]	\N	C5361	C5361	7b2f998fb55083d80520af98865f0ba2
22914	Khamsa Film Productions	\N	\N	K5214	\N	c8c12416a21081762dfbd8e0b8c1420a
8790	Retro	[ar]	\N	R36	R36	7afa958e9213a76e933ae080274e7d61
39392	Multithematiques	[ca]	\N	M4353	M4353	c217dd1f6d0405ef37c43e64e3fc5168
69928	Jewell	\N	\N	J4	\N	98b3290c059fa23b472f7277bba9e6c9
56582	Aacci	[mx]	\N	A2	A252	dfe99b29969dcbfe800254044ad26c59
6307	Wagner-Hallig Film	[de]	\N	W2564	W2564	e7ef049b27ad2d87f57ea9bb792b712e
36008	Wells Films	[us]	\N	W4214	W4214	d0213f44c0a036291f2377eb7071803d
62500	C3Studios	[us]	\N	C232	C232	9233751d199d9443f8b5793915145ab3
65513	Nikkso Productions	[us]	\N	N2163	N2163	485828c26b9eab6232264eedec68a9c7
10122	Home Vision Cinema	[us]	\N	H5125	H5125	5471ec282b0409e741eee3f56e73288e
2815	Telekanal Expert	[ru]	\N	T4254	T4254	2e196347e2a1ebbd011d9d0321a7cbe9
49706	Liar's Poker LLC	\N	\N	L6212	\N	fef8cd32cef4e7e6067561bafe829aa0
3079	NRK Drama	[no]	\N	N6236	N6236	62961d32a68f41c2507989bcec0f33e7
33971	Komplizen Film GbR	[de]	\N	K5142	K5142	1ce7ab738b0a50ef384e08157ab3cfcd
31760	BuenCine Producciones	[uy]	\N	B5251	B5251	c88fab094d0fd594aa8e02f1451b1c57
34704	Vidicom Media Productions	[ge]	\N	V3253	V3253	ab469ee6a618a697f5fc29955a1f99a0
40107	Mackstudio	[fr]	\N	M23	M2316	73824c8f1630cf5d81b61b84e4c6d6ba
64452	Flashfilms	[us]	\N	F4214	F4214	26fb45903405c11a55b0cae886c3d2b3
58926	Cavall Fort	\N	\N	C1416	\N	ae19a96a34d54b7e7ee2c770489cf9fb
69257	Fortuna-Film GmbH	[de]	\N	F6351	F6351	571d4bb282c03ba40c88bbd150b264fe
22692	Red Fortress Entertainment	[us]	\N	R3163	R3163	6a0a861113535422f89dccb7bfda03e8
53081	Rose Hackney Barber	[gb]	\N	R2516	R2516	825d9cb86f47f04310ba97585683b2a0
51714	Cyclone Productions	[us]	\N	C2451	C2451	5af6a788f64bec01104538b599737881
63399	Roy Alexandre Productions	[us]	\N	R4253	R4253	98d6f098d42466d502f71b3442812500
2069	Jack TV	[ph]	\N	J231	J231	a6376b47e4c7341e9e0d6d47658261d4
45912	Alsace Productions	[ie]	\N	A4216	A4216	177de5d319beff920d94da49fb871cf7
13010	D.I.Y.	[mo]	\N	D	D5	4afb5d6d4185fb68b1fbf9d217778022
53907	Pan Terra	[ru]	\N	P536	P536	0a2c4eb5ee3805dc83bff846527fb656
55213	Azyl Production	[sk]	\N	A2416	A2416	d0cc594f4db651877daf40718d3358a7
63787	EBE	\N	\N	E1	\N	851cacc6fab9c05dd652dfddb5a22d73
53065	Arra Productions	[be]	\N	A6163	A6163	310dfb30a420b93d641843e94f6c26ff
46039	EBA	\N	\N	E1	\N	5339ad073ad9ada675a10b9707776c80
44122	Haymatfilm	[de]	\N	H5314	H5314	655d979f37d283b5e287676eaf24a43e
46965	Bliss Sinema	[us]	\N	B425	B4252	f2d50435f1c8f42cb7d1f068310c4c08
23226	Creative Waves	[us]	\N	C6312	C6312	8c487a99a73924b0253b0791da2111ac
42374	Enterprises Pictures Limited	[gb]	\N	E5361	E5361	cf54d57b4a96f2285cab2be75396fa0a
1318	Film Café	[hu]	\N	F4521	F4521	707033efe0f083699c8fa1f207e83109
12350	Gryphon Entertainment	[au]	\N	G6153	G6153	6ff416ea60551aab8374830eff3f6eb2
5107	ZAZ	[mx]	\N	Z2	Z252	0e69809359d790c3f30b47c1a28e9b0d
51019	Story Point Media	[us]	\N	S3615	S3615	0dfd0d8ecb44b630a2b48e7171e88987
1382	Blue Balloon Productions	[ca]	\N	B4145	B4145	4819080be1a558be8c2d4f7608eabf00
29460	Bad Boys	[fr]	\N	B312	B3121	ab2b9e7653f603a9b488b81904b6884a
59829	Mya Communications	[it]	\N	M2523	M2523	c78394b654676ed86274a753db87dd75
10521	Radiovideo GPE	[it]	\N	R3132	R3132	8afc58cb1e8c160659c99bdad7fc77b7
4270	Nordwestdeutscher Rundfunk (NWDR)	[de]	\N	N6323	N6323	93ee574ff373fd77468d157c0b65a7e0
35721	Galaxy454 Productions	[us]	\N	G4216	G4216	c045fb3729212312cc2a3d914e1e3aa9
45372	Les Productions de la Lanterne	[fr]	\N	L2163	L2163	707595d5050873bb482c2f33db4ec978
19344	abbywinters.com	[au]	\N	A1536	A1536	0f3ed3539a4c1be9c3783ba3df5cfff3
68806	Hurricane Entertainment	[us]	\N	H6253	H6253	067f020102ad6846ff9ef49bf6838af8
2630	Dolmen Home Video	[it]	\N	D4513	D4513	70c8557af2d35fd98dffe0b201fdbbc8
7522	Land and Sea, CBC	[ca]	\N	L5353	L5353	dfa16fc4a1f4ec58bcd1801a9aeb89e6
30718	Simple (TV) Productions	[gb]	\N	S5143	S5143	834d4bb15eae5107b00844118a0f090d
58450	Sunbeam Motion Picture Corp.	\N	\N	S5153	\N	d080bb6e8b8f971607a6575b57858308
19584	Vanguard International Cinema	[us]	\N	V5263	V5263	a1b7a9f655d8ad4224e9dfa8ed93bc24
1791	Films sans Frontières	[fr]	\N	F4525	F4525	9ea456f9dafbf7de75e76c2d2f3a97ea
61839	Redeemable Features	\N	\N	R3514	\N	304fb61962531fddda3dbf82b251d837
33091	Cinema International Corporation (UK)	[gb]	\N	C5365	C5365	55a86a9f2e574429ae99e3a92749d1fa
16323	Metropolis Films	[gb]	\N	M3614	M3614	d15b28b4f3649300b52c23fb7beb03dd
22170	Amazing Fantasy Entertainment	\N	\N	A5252	\N	a4b9e2325ed5a0e1e03b22b8699e5b81
67547	Mind Films	\N	\N	M5314	\N	ed263ef3949c4c88080952f4c472ee61
46127	Hanmaek Movies	\N	\N	H5251	\N	19448c7caad756552b89d449f45ac27b
21869	Zeus Film	[it]	\N	Z2145	Z2145	ddc06a2e36b42f79a8de4114f25a7c0b
48131	Lorimage	[fr]	\N	L652	L6521	77e71c0ef5ae865336a21eaa000c408f
50359	Visual Arts Entertainment	[us]	\N	V2463	V2463	16bd0e7102b436be31533dda2d207e5c
18994	Shemaroo Entertainment	[in]	\N	S5653	S5653	ca622c97a3e0ff49a0bcebd37f4491fc
16441	Lotte Entertainment	[kr]	\N	L3536	L3536	7f1aebf73d3642d6cec65f84d336261f
12013	Nexo	[it]	\N	N2	N23	8eb39544eea1fca12f1a46d1747c807c
12023	Wild Bunch	[fr]	\N	W4315	W4315	59ef968d4011c9ff1846639bf01fec65
24047	Blue Byte	\N	\N	B413	\N	aeb1863496911b5af40af73f65c92473
19380	Independent Releasing Organization	[us]	\N	I5315	I5315	7bf3c0459dc3211baad63207f9bbe048
24633	filmisches Berlin	[de]	\N	F4521	F4521	d34eff71be1f047f9fc8247eed361257
62907	DFI Films	[gb]	\N	D1452	D1452	4a76a4510b1bb1f349adaf44ef05b857
65776	Film Circuit	[ca]	\N	F4526	F4526	b1a5783f6366d551422191c5863bdec5
5934	Penta	[it]	\N	P53	P53	9a1e8a387af86a13fbcb2e9c6fc999c8
27175	Regiment Productions	[us]	\N	R2531	R2531	f58fc9b953955e435f239721996870ce
766	Travel	[br]	\N	T614	T6141	645a11145a10c512e8573b22380c3b3c
24199	Media Luna New Films	[de]	\N	M3451	M3451	0309b7b4045c801c9d765ac9419b9e5f
4818	UBC Series	[th]	\N	U1262	U1262	a04335ca9278ae408e91db8a01c89fee
69243	Behaviour Interactive	[ca]	\N	B1653	B1653	2ecfc3a48a442c117bf38744da13a66a
55486	B3Media	[gb]	\N	B53	B5321	a2476db460ed077e6e646e7912ee7e7d
50902	Hibiki Films	[gb]	\N	H1214	H1214	22efb2aa9e70995222aa9bff70aea756
66417	Campbell/Black Productions	[us]	\N	C5141	C5141	4f61129ce9d50f188b217f4f0d0c2f2a
39636	Ison Entertainment	[us]	\N	I2536	I2536	7a3b92ba8847946d745ac5a0a35b2ab1
5219	Guang Dong Tung Ah	[hk]	\N	G5235	G5235	b2ec894f6dbe15fde66ade3f7e0d724d
45219	Alcifrance	[fr]	\N	A4216	A4216	7706fabc4bb9363d8b61eca62158180d
926	KDOC	[us]	\N	K32	K32	49f29f20134984fc4558da11689321bc
68229	IZ-Project	[jp]	\N	I2162	I2162	77a1af2335537ab4fb3fb50ea9876af2
67335	Strangeballs	\N	\N	S3652	\N	1202ef783dbd6c54721912264584958f
61696	Triplex Films	[ca]	\N	T6142	T6142	d0de569ae486c4b4ce7d685728c87749
56435	Studio Filmowe N	[pl]	\N	S3145	S3145	9a7ad4230f191fdd81defa014fef8ccb
35161	L.T.V.	[gr]	\N	L31	L3126	77d4315e4089de536203db1ddfe3dc70
19700	Upstream Pictures	[nl]	\N	U1236	U1236	c68792780c3ac8ef89f6a57aff340da8
16806	Indigo	[de]	\N	I532	I5323	06853316525722facfd402635651b7a3
18015	Silwa	[de]	\N	S4	S43	3e14c8ccad3032d7b9aea147e92a082c
9701	Universal Music & Video Distribution (UMVD)	[us]	\N	U5162	U5162	37fac2d56e57bccc911e51e0e7830631
12481	Cinema Epoch	[us]	\N	C512	C512	7841d5f47953f7ba5be5d852d59bf893
9660	Agatha Christie	[gb]	\N	A2326	A2326	4a383f056bbc7fe74ac3dc54f6b89798
10421	Content Factory, The	[nl]	\N	C5353	C5353	234bd3ebde565b871cf4303b21400f3a
49366	Khanzhonkov	[ru]	\N	K5252	K5252	b46d3332cdfcd5e0177a15a31dbfade9
35770	Krzystek Productions	[us]	\N	K6232	K6232	173ec167250c6fc19b5c1a4ec56169b4
31282	Bolton University	[gb]	\N	B4351	B4351	db7026a0544e8900681dc66614420e03
41551	Edition Tonfilm	[de]	\N	E3535	E3535	c85df361a87ac72e8246751e2cdd27ad
47136	Tam Communications	[us]	\N	T5252	T5252	51bb27d8b926ae58666f0cb77ff9cf1a
50785	Richard-Oswald-Produktion	[de]	\N	R2632	R2632	f0644057cba8dd4801083905eb893117
53641	KSS Hanbai	[jp]	\N	K251	K2512	ce6dba13fc4042f1cdf91beab29c38b8
16036	Illicit Pictures	[us]	\N	I4231	I4231	3c2256e35f55373daea334e89fa71fcc
13882	Denkmal-Films	[de]	\N	D5254	D5254	8738fa2e87fc061e601d26b163f84704
47637	Love Above All Productions	[us]	\N	L1416	L1416	0c4077fdbb50bdbf5c670941ee1b9b9c
41231	Focus Film (I)	[dk]	\N	F2145	F2145	c6abcacd1cb638c613804df9f8b6af4d
42226	Neptune Distributors	[in]	\N	N1353	N1353	173f28408555c97a2eae10ff84cdfe6a
70553	Real Image	[ae]	\N	R452	R452	1bfcae9067177a63e1dbf3db0c5fa421
12224	Rotten Apple Productions	[us]	\N	R3514	R3514	75f780d9f368e60a646630da88dfc048
55855	Gravsports	[ca]	\N	G6121	G6121	bfd24305f4d75e6358cf350dfde62006
51326	Lithuanian Film Studios	[lt]	\N	L3514	L3514	fbcc2ff925f290df3f14efb84c827347
43842	8th Avenue Venture	[us]	\N	T1515	T1515	8c1dfc8a53957977af32abd0d56a1dfb
9907	Focus Filmes	[br]	\N	F2145	F2145	2d15859edc64d25ef26409686e168e6e
7930	Lenz Releasing	[ca]	\N	L5264	L5264	b6e17f999063dce0e8c2062f1796a392
29639	Lamb Films	[gb]	\N	L5145	L5145	b0daa2359404f73035d5266e45b8ccf0
62954	N.I.P films	[us]	\N	N1452	N1452	c255c0e6bc316a0f5936b7bf2571d1fa
6570	Playboy TV Latin America & Iberia LLC	[us]	\N	P4131	P4131	17735617ecf67a009bd9cfe31fd7e2c4
3828	Shokus Video	[us]	\N	S213	S2132	42ed812237fe7076f9628ef29636dd2b
52175	Health Point Productions	[us]	\N	H4315	H4315	efbea26b3af63607be4fea5a0cc6d9ac
28762	Nanook	[pt]	\N	N52	N5213	4b949d57ceb2bf34245404931038ca18
61403	Sinne Entertainment	[us]	\N	S5363	S5363	669823885f214b35bbcaa97ca2e136b0
30002	Helkon Media AG	[de]	\N	H4253	H4253	309952c211b1b952d1f235338496712d
57590	Videofactory S.R.L.	[it]	\N	V3123	V3123	632854b6d8aea31b19b1bb7adda25b4c
49964	InterTropic Films	[au]	\N	I5363	I5363	3b59e707409ffad3827aedb29b3f86c4
67863	Traveler Production Company L.l.c.	\N	\N	T6146	\N	86cd9cd2d84d45fc5e3a777e85088426
42949	Allodox Productions	[us]	\N	A4321	A4321	f98931b2324f03b793adc4590e2fb58e
21552	Evrokom-Plovdiv	[bg]	\N	E1625	E1625	95bf6a96d930e080971701709503fc65
48278	Torrevado	[it]	\N	T613	T613	b3a44dc7aab615ef6cc85d63290dbab5
14036	European Video Distributors (EVD)	[us]	\N	E6151	E6151	751ad9d4112d5278a6a21c52226e1b29
36554	Intimate Video	[us]	\N	I5353	I5353	be945ca627ac4da73d389af4728f6cb8
51076	TV 1 Yhteistuotannot	[fi]	\N	T1323	T1323	7a1f9cf250172b3d3d97f73b68411339
21437	Obsession Entertainment	[us]	\N	O1253	O1253	32f2510afc655700b9eb192c2432002d
39827	Kellum Talking Picture Company	[us]	\N	K4534	K4534	c6b517f55fe6f2c0f85176a2c845245a
55520	Oslo Beach Films	[gb]	\N	O2412	O2412	e161f390d5ec2f8a5c75fa19361a5cf6
40110	Clapham-Battersea Adult Education	[gb]	\N	C4151	C4151	d703505fa5edcf2f7a1632ccabd8446f
44917	San Francisco Art Institute	[us]	\N	S5165	S5165	81d45e2e27595c7b796612120a7cd10c
22649	Rok Americas	[us]	\N	R2562	R2562	dd53518991acb8988d67e9879b762db4
14984	Octopus Pictures	[nz]	\N	O2312	O2312	35f4ebbca78a5640856ee733c7688289
23212	Virtual Audiovisuais	[pt]	\N	V6343	V6343	c73e30fd8412725933f2cc336ea9dfa0
15356	Cone Light	[gb]	\N	C5423	C5423	8d84b3c4381b06434bac3905056a662b
34516	Wilder Süden Filmverleih	[de]	\N	W4362	W4362	6edeed66574c2fc818a5d8698f1b9590
57816	Daddy Inc. S/A	[br]	\N	D352	D3521	702e20984a315444f63ec0cac91563b0
60490	Asylum Arts	[us]	\N	A2456	A2456	bbacb2076033ddd8b270ca1f06187596
23377	FifiGE/AG Kino	[de]	\N	F125	F1253	642d891266f99b6459078f98f4e4a07d
8361	Dylann Bobei Productions	[ca]	\N	D4516	D4516	6801e1132fa730de7040e34e3ecf7cef
49033	Saint Séverin	[fr]	\N	S5321	S5321	2e2fad3236df256b0afff12f2a99f2a4
61386	Regione Piemonte	[it]	\N	R2515	R2515	34bd013401579d27c96b7ee4f9170d1d
66696	Four Cranes Films	[us]	\N	F6265	F6265	a50b901122ee0fb9e2b3114542e9104c
38968	OMC	[tw]	\N	O52	O523	d647aec477e8176d14ef173ad0954acb
30700	Ricochet Electronic	[us]	\N	R2342	R2342	cc6e92a5c4c8b1688d8f4028e4728776
10449	There's Hope Inc.	[us]	\N	T6215	T6215	d0b4274a1460ba315491c3efd8ec49d4
32509	Paiaya Films	[gb]	\N	P1452	P1452	6457f4a49641fe626d062ec5fb80ffb4
57697	JEF Productions	[us]	\N	J1632	J1632	22866b308a036a37c229f2ece4da7edb
65327	Opera World	[gb]	\N	O1643	O1643	73e492089bff54a9b0f24eaa7c90f69b
66490	Jama Films	\N	\N	J5145	\N	d50e40696e5910e85c80df663a2b4af8
34869	Drive Fast, Take Chances Productions	[us]	\N	D6123	D6123	7aadb8ba4330cdff09d56bd0fcb7d273
24489	Lion's Gate Films	[us]	\N	L5231	L5231	7deab473c766697cc44b19ec69b64fa7
67697	Sandrino Giglio	[us]	\N	S5365	S5365	371fbda9eac94ad4c3a4a2828ca3753e
60639	MGM Music	\N	\N	M252	\N	732a0c1827e0025e206f943fd367c1c3
40769	Neofilm	[de]	\N	N145	N1453	07e74f66af02dcd33d78ac4cf79c645c
92	Tokyo Broadcasting System (TBS)	[jp]	\N	T2163	T2163	b05fe1b8ab62ed5a47879df0663d6457
9060	Beijing Ai Ke Sai Wen Film & TV Production Co.	[cn]	\N	B2525	B2525	4a319a642645e65d6ec6228b08e3ab9d
27912	Tokyo Koei	[jp]	\N	T2	T21	04d8956fc46ef07542a9b44ba6cc09f0
62307	Catapult Productions	\N	\N	C3143	\N	1a32215a5ca07f42fb6ecff3be5b702f
43134	Kép-Árnyek	[hu]	\N	K1652	K1652	76f281ee57a75a8b9299db73f063eac8
7122	Comep	[br]	\N	C51	C516	bbee6b715cd850068c0307c212e4f853
19740	Goodfellas Productions	[us]	\N	G3142	G3142	e0a17fedfb20e95a5150d7db660cb706
58439	Precious Films	\N	\N	P6214	\N	e72ff304f265b9ca701ed35e631f08a5
13415	American Top Video	[ar]	\N	A5625	A5625	9113d2ca8936fcf474911d0cabbf9adb
21724	United States Army	[us]	\N	U5323	U5323	410b42f03b1332f0b8e5480c990e8c6b
52392	MyCool Sound	[nz]	\N	M2425	M2425	3a3eb22c6f96c3102b5ae2d6e7bd4166
63547	Wrong Way Pictures	[us]	\N	W6521	W6521	032d8bcf3f3c398d8bd34a415fba549d
15661	Tobis Portuguesa	[pt]	\N	T1216	T1216	4271ecb04403f1ae9fb955b13f58bd4b
48084	Sonido Mambo	[mx]	\N	S5351	S5351	51933017cc95cfa2225334acce89198b
39507	Orion's Gate	[us]	\N	O6523	O6523	5c9f7219322687fb8c5af6f35b13ff5e
21422	Finalement	[fr]	\N	F5453	F5453	975027d4ac43d3530332fcf6b159cf36
21030	Estinfilm	[ee]	\N	E2351	E2351	64dda8a56d3d4abb911802cc45853ce0
17179	Old School Pictures	\N	\N	O4324	\N	32a3d119b0d7a7942dd8fb78efc265ea
15376	Rascal Video	[us]	\N	R2413	R2413	d71451b0fb96b475e8f0a08ee5ebd236
13896	Virgil Films	[us]	\N	V6241	V6241	575cb56d4f332c9409711d5b5e4eda7c
43680	CH-Film	[de]	\N	C145	C1453	ccdcb989779f3812358546b89da35b1f
11850	IF Télévision	[fr]	\N	I1341	I1341	afe28ae6b7fc74f224b1ddde53fe1efc
65662	MM Air Media Distribution	[au]	\N	M5653	M5653	e9f4164b4f7e38a53b65455329a43eed
13698	Imovision	[br]	\N	I5125	I5125	1a7b5d7af8f097af9a8a52f4c0405ff5
1333	Télé-Québec	[ca]	\N	T4212	T4212	a808d334a7a8b293c63c6162191d7c4b
12750	Blue Fire	[gb]	\N	B416	B4162	a309061e04554013e1a14ba13ef0195a
51814	DreamWorks Home Entertainment	[fr]	\N	D6562	D6562	89e70c7a431effb744cf6389fc671cae
69456	7th Art International Agency	[it]	\N	T6353	T6353	ce5d394eb5c85c263869b384dd5e4286
55459	Fretboard Pictures	[us]	\N	F6316	F6316	386016d602724062cb019769429c289d
54510	Belfilms	[be]	\N	B4145	B4145	9bf4db7de03ebe535de235924f6c6bbd
51165	VIS	[it]	\N	V2	V23	890349a9904c02c833b0f9415b54f399
43678	Pierre Grise Productions	[fr]	\N	P6262	P6262	9f843804ef22d053003e4dbbf22aa64c
69288	Milano International FICTS Festival	[it]	\N	M4536	M4536	2dbf3660c76e2968cf1e35a9a0b27746
34411	Tamarack Road Productions	[us]	\N	T5626	T5626	7148a1b6e86971b766041b01aea40d13
5985	Seeking Distribution	[us]	\N	S2523	S2523	48ccc98aa54823ce56ac6d9d564320bc
58172	Emerson/DeRouchie	[us]	\N	E5625	E5625	4a4972e6c55c807255b34ab3bda65511
70589	Peter Joseph	[us]	\N	P3621	P3621	8dcd717a29815ec5f33d4f7d682bf413
63331	Maverick Filmworks	[us]	\N	M1621	M1621	cc2a562404219ca1f8343348f0cb01d4
6990	ElleU Multimedia	[it]	\N	E4543	E4543	9df84fe058619eb6e674de022b1fc041
2325	ITV Network	[gb]	\N	I3153	I3153	985082af2bd8041772eb8dbb8eb37787
25078	Jaguar Film International Distribution	[lb]	\N	J2614	J2614	9918780611186248479fc5dd65a41786
13770	Maxximum Film und Kunst GmbH	[de]	\N	M2514	M2514	b0e974fff9c23c7dbc3484e6557e9a5c
67308	Tripilleye Entertainment	[us]	\N	T6145	T6145	3ffa8e74f7db0113633631bb6d9530ea
58226	CinEscondite Ltd.	[cl]	\N	C5253	C5253	5e537632b7e364f15a724532c5c5574f
7477	Envy Productions	[ca]	\N	E5163	E5163	d3520dfe4b4e52bdf15150f9f3a038f1
12879	Compañía General de la Imagen (CGI)	[ar]	\N	C5125	C5125	0691e2e131b3f15b26d28b0dc8352ac0
10831	TV Asahi Channel	[jp]	\N	T1254	T1254	bd1130f6abe75b672fc79b7141a42ee0
26397	CineBags	[us]	\N	C512	C512	d67735233362124a1a929d20f8e9caf9
21388	Pequod Edizioni	[it]	\N	P2325	P2325	0df53e17ff86effdeeb13517f0c4cc43
6751	Justice Woman Productions	[us]	\N	J2325	J2325	460f176df1666248f171f14f70f17cb9
10975	Travel Channel International	[gb]	\N	T6142	T6142	6adc40db6f4dc95c81f40eba741049c1
2570	Echocloud Entertainment	[ca]	\N	E2435	E2435	1f15ed0c40039be0a9243175a456c9b6
3192	BVITV	[gb]	\N	B131	B1312	9117b4f29417d403371dcf88a2d79d4d
61728	X-Kombat	[it]	\N	X2513	X2513	65dc80f88a4b01b3e9f5432dd5eb700b
\.


--
-- Data for Name: company_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company_type (id, kind) FROM stdin;
1	distributors
2	production companies
3	special effects companies
4	miscellaneous companies
\.


--
-- Data for Name: complete_cast; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.complete_cast (id, movie_id, subject_id, status_id) FROM stdin;
1	1634350	1	4
2	1634391	1	3
3	1634423	1	4
4	1634434	1	3
5	1634450	1	3
6	1634882	1	4
7	1635273	1	3
8	1635294	1	3
9	1634924	1	3
10	1634948	1	3
11	1635171	1	3
12	1634956	1	3
13	1634961	1	3
14	1634968	1	3
15	1634969	1	3
16	1635021	1	3
17	1635034	1	3
18	2852	1	3
19	2853	1	3
20	2854	1	3
21	2855	1	3
22	2857	1	3
23	1635037	1	4
24	1635059	1	3
25	1635078	1	3
26	1635086	1	3
27	1635088	1	3
28	1635102	1	3
29	1635314	1	3
30	1634672	1	4
31	1635320	1	4
32	1634899	1	3
33	3553	1	3
34	1634686	1	3
35	1634692	1	3
36	1634706	1	3
37	1860	1	3
38	1861	1	3
39	1863	1	3
40	1868	1	3
41	1869	1	3
42	1866	1	3
43	1873	1	3
44	1874	1	3
45	1875	1	3
46	1876	1	3
47	1877	1	3
48	1878	1	3
49	1879	1	3
50	1880	1	3
51	1881	1	3
52	1883	1	3
53	1884	1	3
54	1885	1	3
55	1632907	1	3
56	1634814	1	4
57	1634819	1	3
58	1634838	1	4
59	1634844	1	4
60	1635608	1	4
61	1632970	1	3
62	1635611	1	3
63	1635482	1	4
64	1635833	1	4
65	1635837	1	3
66	1547	1	3
67	1635813	1	4
68	1635814	1	4
69	1635816	1	3
70	1635656	1	4
71	1635657	1	4
72	1635664	1	3
73	1635697	1	3
74	1635723	1	3
75	4212	1	3
76	4217	1	3
77	4227	1	3
78	4230	1	3
79	4233	1	3
80	4245	1	3
81	4259	1	3
82	4266	1	3
83	4268	1	3
84	1635736	1	3
85	1635756	1	3
86	1635757	1	3
87	4496	1	3
88	1635895	1	3
89	1635904	1	4
90	1635906	1	3
91	1635921	1	3
92	4651	1	3
93	1635947	1	4
94	1635949	1	3
95	1635951	1	3
96	1636027	1	3
97	1636107	1	3
98	1636111	1	4
99	1636135	1	4
100	1636057	1	3
101	1636068	1	3
102	1636073	1	3
103	1636083	1	4
104	1636090	1	3
105	1636161	1	3
106	1636189	1	3
107	1636192	1	3
108	1636262	1	3
109	1636221	1	3
110	1636224	1	3
111	1636287	1	4
112	1636301	1	3
113	1636419	1	4
114	5212	1	3
115	5213	1	3
116	5214	1	3
117	5215	1	3
118	5216	1	3
119	5217	1	3
120	1636360	1	3
121	1636361	1	3
122	1577	1	3
123	1578	1	3
124	1579	1	3
125	1580	1	3
126	1581	1	3
127	1582	1	3
128	1583	1	3
129	1584	1	3
130	1585	1	3
131	1586	1	3
132	1587	1	3
133	1588	1	3
134	1589	1	3
135	1590	1	3
136	1591	1	3
137	1592	1	3
138	1593	1	3
139	1594	1	3
140	1597	1	3
141	1596	1	3
142	1595	1	3
143	1598	1	3
144	1599	1	3
145	1600	1	3
146	1601	1	3
147	1602	1	3
148	1603	1	3
149	1604	1	3
150	1605	1	3
151	1606	1	3
152	1607	1	3
153	1608	1	3
154	1609	1	3
155	1610	1	3
156	1611	1	3
157	1612	1	3
158	1613	1	3
159	1614	1	3
160	1615	1	3
161	1616	1	3
162	1617	1	3
163	1618	1	3
164	1619	1	3
165	1620	1	3
166	1621	1	3
167	1622	1	3
168	1623	1	3
169	1624	1	3
170	1625	1	3
171	1626	1	3
172	1627	1	3
173	1628	1	3
174	1629	1	3
175	1630	1	3
176	1631	1	3
177	1636629	1	4
178	1636704	1	3
179	1636460	1	3
180	1636578	1	3
181	1636581	1	3
182	5284	1	3
183	1636802	1	3
184	1636813	1	3
185	1636836	1	4
186	1636842	1	4
187	1636908	1	3
188	1637046	1	4
189	1632899	1	4
190	1637609	1	3
191	1634634	1	4
192	1634544	1	3
193	1634547	1	3
194	1397	1	3
195	1398	1	3
196	1399	1	3
197	1634553	1	3
198	6302	1	3
199	1638291	1	3
200	1638293	1	4
201	1638295	1	3
202	1638298	1	3
203	1638407	1	4
204	1638300	1	3
205	1638307	1	4
206	1638310	1	4
207	7683	1	3
208	1638450	1	4
209	1638451	1	3
210	1638426	1	3
211	1638430	1	3
212	1638500	1	4
213	1638734	1	3
214	1638838	1	3
215	1638349	1	3
216	1638853	1	4
217	1638904	1	3
218	1638977	1	3
219	1638983	1	3
220	8092	1	3
221	8093	1	3
222	8094	1	3
223	8095	1	3
224	8096	1	3
225	8098	1	3
226	8099	1	3
227	8100	1	3
228	8101	1	3
229	8102	1	3
230	8103	1	3
231	8104	1	3
232	1639089	1	3
233	1638229	1	3
234	1638241	1	3
235	1638242	1	4
236	1638254	1	3
237	1638263	1	3
238	1638273	1	3
239	1639166	1	3
240	1639171	1	3
241	1637789	1	3
242	1639231	1	3
243	8322	1	3
244	1639181	1	4
245	1639191	1	4
246	1639194	1	4
247	8343	1	3
248	8465	1	3
249	1639323	1	3
250	1639322	1	3
251	1639318	1	3
252	1639893	1	3
253	1639336	1	3
254	1639321	1	3
255	9091	1	4
256	8962	1	3
257	8963	1	3
258	8968	1	3
259	8969	1	3
260	8964	1	3
261	8965	1	3
262	8966	1	3
263	8967	1	3
264	8970	1	3
265	8971	1	3
266	8972	1	3
267	8973	1	3
268	8974	1	3
269	8975	1	3
270	8976	1	3
271	8977	1	3
272	8978	1	3
273	8979	1	3
274	8980	1	3
275	8981	1	3
276	8983	1	3
277	8984	1	3
278	8985	1	3
279	8986	1	3
280	8987	1	3
281	8992	1	3
282	8993	1	3
283	8988	1	3
284	8989	1	3
285	8990	1	3
286	8991	1	3
287	8994	1	3
288	8995	1	3
289	8996	1	3
290	8997	1	3
291	8998	1	3
292	8999	1	3
293	9000	1	3
294	9001	1	3
295	9002	1	3
296	9003	1	3
297	9004	1	3
298	9005	1	3
299	9006	1	3
300	9007	1	3
301	9008	1	3
302	9009	1	3
303	1639517	1	3
304	1639372	1	4
305	8689	1	3
306	8690	1	3
307	8691	1	3
308	8692	1	3
309	8693	1	3
310	1639443	1	3
311	1639446	1	3
312	1639457	1	3
313	1639678	1	3
314	1639640	1	3
315	1639709	1	3
316	9251	1	3
317	9246	1	4
318	9258	1	4
319	9271	1	3
320	9280	1	3
321	9299	1	3
322	9300	1	3
323	9309	1	3
324	9314	1	3
325	9315	1	3
326	9319	1	3
327	9322	1	3
328	1639781	1	3
329	1639757	1	3
330	1639759	1	3
331	1639798	1	4
332	1639799	1	4
333	1639822	1	3
334	1639823	1	4
335	1639851	1	3
336	1639860	1	3
337	1639876	1	4
338	1637828	1	3
339	1637859	1	4
340	1637877	1	4
341	1638050	1	3
342	1638079	1	3
343	1640636	1	4
344	11495	1	3
345	11496	1	3
346	11497	1	3
347	11498	1	3
348	11494	1	3
349	11500	1	3
350	11501	1	3
351	11502	1	3
352	11503	1	3
353	11508	1	3
354	11504	1	3
355	11509	1	3
356	11505	1	3
357	11510	1	3
358	11511	1	3
359	11512	1	3
360	11506	1	3
361	11513	1	3
362	11514	1	3
363	11515	1	3
364	11518	1	3
365	11516	1	3
366	11517	1	3
367	11507	1	3
368	11519	1	3
369	11520	1	3
370	11521	1	3
371	11522	1	3
372	11523	1	3
373	11524	1	3
374	11525	1	3
375	1640617	1	3
376	1640462	1	3
377	1640480	1	4
378	1640484	1	3
379	1640661	1	3
380	1640510	1	3
381	1640604	1	3
382	11120	1	3
383	11121	1	3
384	11126	1	3
385	11129	1	3
386	11140	1	3
387	11153	1	3
388	11156	1	3
389	11165	1	3
390	11166	1	3
391	11167	1	3
392	11190	1	3
393	11203	1	3
394	11215	1	3
395	11216	1	3
396	11219	1	3
397	11221	1	3
398	11224	1	3
399	11226	1	3
400	11233	1	3
401	11235	1	3
402	11239	1	3
403	11242	1	3
404	1640582	1	3
405	1640974	1	4
406	1640975	1	4
407	1640977	1	3
408	1640979	1	3
409	1640386	1	3
410	11573	1	3
411	1640793	1	3
412	1640804	1	4
413	1640862	1	3
414	1640887	1	4
415	1640830	1	3
416	1640831	1	3
417	1640833	1	3
418	1640834	1	4
419	1640838	1	4
420	1640919	1	4
421	1632975	1	3
422	1640956	1	3
423	1639997	1	3
424	1639998	1	3
425	1640013	1	4
426	1640049	1	3
427	1640064	1	3
428	1640077	1	3
429	1640116	1	4
430	1640149	1	4
431	1640168	1	3
432	1640190	1	3
433	1640198	1	3
434	1640200	1	3
435	1640201	1	3
436	1640411	1	3
437	9911	1	3
438	9917	1	3
439	9919	1	3
440	1640251	1	3
441	1640255	1	4
442	1640259	1	3
443	1640256	1	4
444	1640258	1	4
445	1640262	1	3
446	1640285	1	3
447	1640287	1	3
448	1640322	1	3
449	1640360	1	4
450	1641406	1	3
451	1641417	1	3
452	1641283	1	3
453	1641424	1	3
454	1641292	1	3
455	1641298	1	3
456	1641313	1	3
457	1641315	1	3
458	1641323	1	4
459	1641347	1	3
460	1641349	1	3
461	1641379	1	3
462	1641444	1	3
463	1641495	1	3
464	1641505	1	4
465	1633917	1	3
466	1641541	1	3
467	1641542	1	4
468	1641279	1	3
469	1641585	1	3
470	1634282	1	3
471	1641571	1	3
472	1641620	1	3
473	1641648	1	4
474	1641658	1	4
475	1632981	1	3
476	1641680	1	3
477	1641130	1	4
478	1641151	1	4
479	1641722	1	4
480	1641164	1	3
481	1641172	1	4
482	1641189	1	3
483	1641197	1	3
484	1641208	1	4
485	1641699	1	3
486	1641770	1	3
487	1641256	1	3
488	1642219	1	3
489	1642189	1	3
490	1642074	1	3
491	1642079	1	3
492	1642091	1	3
493	1642096	1	3
494	1642097	1	3
495	1642099	1	3
496	1642102	1	3
497	1642107	1	3
498	1642120	1	3
499	1642124	1	3
500	1642162	1	3
501	1641799	1	3
502	1642288	1	4
503	1642309	1	4
504	1642324	1	4
505	14908	1	3
506	14909	1	3
507	14910	1	3
508	14911	1	3
509	14912	1	3
510	14913	1	3
511	14914	1	3
512	14915	1	3
513	14916	1	3
514	14917	1	3
515	14918	1	3
516	14919	1	3
517	14920	1	3
518	14921	1	3
519	1642328	1	3
520	1642363	1	3
521	1641812	1	4
522	1641814	1	3
523	1641821	1	3
524	1641826	1	4
525	1641848	1	3
526	1641845	1	3
527	1641863	1	3
528	1641925	1	4
529	1641932	1	3
530	1641961	1	3
531	1641997	1	3
532	1642414	1	4
533	1642013	1	3
534	1642428	1	4
535	1642430	1	3
536	1642017	1	3
537	1642525	1	3
538	1642555	1	3
539	2526432	1	3
540	1642607	1	4
541	1642629	1	3
542	1642644	1	4
543	1642654	1	3
544	1642690	1	3
545	1642686	1	3
546	1642681	1	3
547	1642737	1	3
548	1642440	1	3
549	1642449	1	4
550	1642475	1	3
551	18389	1	3
552	1643051	1	4
553	1643075	1	3
554	1643109	1	3
555	1643140	1	3
556	18466	1	3
557	1642852	1	3
558	1642868	1	4
559	1642895	1	3
560	17524	1	3
561	17621	1	3
562	1642940	1	3
563	1643208	1	4
564	1643212	1	3
565	1642982	1	4
566	1642993	1	3
567	1643401	1	3
568	1643380	1	3
569	1643393	1	3
570	1643533	1	4
571	1643443	1	4
572	1643446	1	4
573	19362	1	3
574	1643466	1	3
575	1643482	1	4
576	1643477	1	3
577	1643246	1	3
578	1643353	1	3
579	1643268	1	4
580	1643276	1	4
581	1643295	1	4
582	1643297	1	4
583	1643515	1	4
584	19183	1	3
585	19184	1	3
586	19185	1	3
587	19186	1	3
588	19187	1	3
589	19188	1	3
590	19190	1	3
591	19191	1	3
592	19192	1	3
593	19193	1	3
594	19194	1	3
595	19189	1	3
596	19195	1	3
597	19196	1	3
598	19197	1	3
599	19198	1	3
600	19199	1	3
601	19200	1	3
602	19201	1	3
603	19202	1	3
604	19203	1	3
605	19204	1	3
606	19205	1	3
607	19206	1	3
608	19207	1	3
609	19208	1	3
610	19209	1	3
611	19210	1	3
612	19211	1	3
613	19212	1	3
614	19213	1	3
615	19214	1	3
616	19215	1	3
617	19219	1	3
618	1643324	1	4
619	19225	1	3
620	19232	1	3
621	19235	1	3
622	19229	1	3
623	19230	1	3
624	19231	1	3
625	19237	1	3
626	19240	1	3
627	19242	1	3
628	19243	1	3
629	19248	1	3
630	19249	1	3
631	19250	1	3
632	19251	1	3
633	19252	1	3
634	19255	1	3
635	19256	1	3
636	19257	1	3
637	19260	1	3
638	19261	1	3
639	19262	1	3
640	19263	1	3
641	19264	1	3
642	19265	1	3
643	19266	1	3
644	19267	1	3
645	19268	1	3
646	19269	1	3
647	19270	1	3
648	19274	1	3
649	19277	1	3
650	19280	1	3
651	19285	1	3
652	19287	1	3
653	19288	1	3
654	19289	1	3
655	19290	1	3
656	19291	1	3
657	19294	1	3
658	19295	1	3
659	19296	1	3
660	19297	1	3
661	19299	1	3
662	1643333	1	3
663	1643346	1	3
664	19409	1	3
665	19410	1	3
666	19411	1	3
667	19412	1	3
668	19414	1	3
669	19415	1	3
670	19588	1	3
671	19593	1	3
672	19599	1	3
673	19604	1	3
674	19606	1	3
675	19610	1	3
676	19611	1	3
677	19614	1	3
678	19626	1	3
679	19627	1	3
680	19628	1	3
681	19632	1	3
682	19639	1	3
683	19640	1	3
684	19641	1	3
685	19648	1	3
686	19651	1	3
687	19655	1	3
688	19659	1	3
689	19664	1	3
690	19665	1	3
691	19669	1	3
692	19672	1	3
693	19673	1	3
694	19675	1	3
695	19677	1	3
696	19684	1	3
697	19685	1	3
698	19686	1	3
699	19688	1	3
700	19690	1	3
701	1643700	1	3
702	1643677	1	3
703	1643544	1	3
704	1643546	1	3
705	1643763	1	3
706	1643764	1	3
707	1643765	1	3
708	1643766	1	3
709	1643767	1	3
710	1643768	1	3
711	1643746	1	3
712	1643747	1	3
713	1643773	1	4
714	1643830	1	3
715	1643831	1	4
716	1643834	1	3
717	1643870	1	4
718	1643600	1	3
719	1643625	1	3
720	1643695	1	3
721	1643947	1	3
722	19450	1	4
723	1644019	1	3
724	1644021	1	3
725	1644038	1	3
726	1644041	1	3
727	1644053	1	3
728	31920	1	3
729	31940	1	3
730	1661457	1	3
731	1661496	1	4
732	1661503	1	3
733	1661517	1	4
734	1661374	1	3
735	1661527	1	4
736	1661529	1	3
737	1661564	1	4
738	1661575	1	4
739	1661599	1	4
740	1661604	1	3
741	1661610	1	3
742	1661636	1	4
743	1661668	1	4
744	1661672	1	3
745	1661681	1	4
746	1661692	1	3
747	1661708	1	3
748	1661774	1	3
749	1661779	1	4
750	1661813	1	4
751	1661817	1	4
752	1661786	1	3
753	1661837	1	3
754	1661841	1	3
755	1661790	1	3
756	1661853	1	3
757	1661865	1	4
758	1661871	1	4
759	1661872	1	4
760	1661873	1	3
761	1661876	1	4
762	1661903	1	3
763	1661946	1	3
764	1661955	1	3
765	32063	1	3
766	1661897	1	3
767	1661991	1	3
768	1662002	1	3
769	1662014	1	3
770	1662015	1	4
771	1662026	1	3
772	1662029	1	3
773	1662035	1	4
774	1662004	1	3
775	1662042	1	3
776	1662006	1	4
777	1662051	1	3
778	1662066	1	3
779	1662065	1	4
780	1662067	1	3
781	1662101	1	3
782	1662108	1	3
783	1644151	1	3
784	1644184	1	3
785	1662226	1	3
786	1662231	1	3
787	1662237	1	3
788	1662269	1	3
789	1644263	1	3
790	1662301	1	3
791	1662332	1	3
792	1662333	1	3
793	1662373	1	4
794	1662374	1	4
795	1662375	1	4
796	1662376	1	4
797	1662378	1	4
798	1662379	1	4
799	1662380	1	4
800	1662381	1	4
801	1662392	1	3
802	1662393	1	3
803	1662398	1	4
804	1662409	1	3
805	32250	1	3
806	32272	1	3
807	32361	1	3
808	32386	1	3
809	33974	1	3
810	2526433	1	3
811	34050	1	4
812	1662136	1	4
813	1662498	1	3
814	1662512	1	3
815	1662539	1	3
816	1662559	1	3
817	1662553	1	3
818	1644307	1	3
819	1644324	1	3
820	1644339	1	4
821	34237	1	3
822	1662573	1	3
823	1662576	1	4
824	1644391	1	3
825	1662624	1	3
826	1662644	1	3
827	1662663	1	3
828	1662664	1	3
829	1662667	1	4
830	1662702	1	3
831	1662726	1	3
832	1644411	1	3
833	1644412	1	3
834	1644432	1	3
835	1662747	1	3
836	1662758	1	3
837	1662786	1	4
838	1662791	1	4
839	1662796	1	3
840	1644473	1	3
841	1644474	1	4
842	1644478	1	3
843	1662901	1	4
844	1662902	1	3
845	1644492	1	4
846	1644493	1	4
847	1662908	1	3
848	1644502	1	3
849	1644504	1	3
850	1644514	1	4
851	1662920	1	3
852	20458	1	3
853	20459	1	3
854	20460	1	3
855	20461	1	3
856	20462	1	3
857	20463	1	4
858	20464	1	3
859	20465	1	3
860	20466	1	3
861	20467	1	3
862	20468	1	3
863	20469	1	3
864	20470	1	4
865	1644563	1	3
866	1662149	1	3
867	1644598	1	3
868	1644611	1	3
869	1644638	1	3
870	1644642	1	3
871	1644649	1	4
872	1644686	1	3
873	1662996	1	3
874	1644708	1	3
875	1644729	1	3
876	1663067	1	4
877	1663098	1	3
878	34707	1	3
879	1663139	1	4
880	1663147	1	3
881	1663148	1	3
882	1663157	1	4
883	1663189	1	4
884	1663205	1	3
885	1663212	1	4
886	1663213	1	4
887	1663230	1	4
888	1663232	1	4
889	1644781	1	3
890	1644782	1	4
891	1644794	1	4
892	1644797	1	3
893	1644799	1	3
894	1663279	1	4
895	1644838	1	3
896	1663313	1	4
897	1644871	1	4
898	1644875	1	3
899	1663326	1	4
900	1644889	1	3
901	1644906	1	4
902	1644910	1	3
903	1644916	1	3
904	1644935	1	3
905	1644952	1	3
906	1663358	1	3
907	1644958	1	4
908	1644960	1	3
909	1644967	1	3
910	1644971	1	3
911	1644975	1	3
912	1644995	1	4
913	1645006	1	4
914	1663384	1	3
915	1663416	1	3
916	1663402	1	4
917	35088	1	3
918	35089	1	3
919	35093	1	3
920	35094	1	3
921	35096	1	3
922	35099	1	3
923	35101	1	3
924	35102	1	3
925	35103	1	3
926	35106	1	3
927	35107	1	3
928	35108	1	3
929	35110	1	3
930	35111	1	3
931	35112	1	3
932	35116	1	3
933	35119	1	3
934	35120	1	3
935	1663452	1	4
936	1663465	1	3
937	1663534	1	4
938	1663550	1	4
939	1663555	1	4
940	1663559	1	4
941	1663564	1	3
942	1663588	1	4
943	1645038	1	4
944	1645039	1	3
945	1663721	1	3
946	1645050	1	4
947	1645061	1	4
948	1645062	1	4
949	1645065	1	3
950	1645067	1	3
951	1645103	1	4
952	1645108	1	4
953	1645120	1	3
954	1645123	1	4
955	1663752	1	4
956	1645130	1	4
957	1645142	1	3
958	1663791	1	3
959	1663793	1	3
960	1645185	1	3
961	1645198	1	3
962	1645215	1	4
963	1645219	1	3
964	1645248	1	3
965	1645264	1	4
966	1645257	1	4
967	1645292	1	3
968	35385	1	3
969	35335	1	4
970	1663896	1	3
971	1645308	1	3
972	1645350	1	3
973	1645374	1	4
974	1645386	1	4
975	1645410	1	3
976	1645461	1	4
977	1663918	1	3
978	1663923	1	3
979	35415	1	3
980	1663925	1	3
981	1663929	1	3
982	1663942	1	3
983	1663954	1	4
984	1663968	1	3
985	2526203	1	3
986	1663989	1	4
987	37134	1	3
988	1664022	1	3
989	1664044	1	3
990	1664064	1	4
991	1664072	1	4
992	1664078	1	4
993	1664104	1	3
994	1664127	1	3
995	37388	1	3
996	1664156	1	3
997	2526434	1	3
998	1663821	1	3
999	37409	1	3
1000	1664185	1	3
\.


--
-- Data for Name: info_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.info_type (id, info) FROM stdin;
1	runtimes
2	color info
3	genres
4	languages
5	certificates
6	sound mix
7	tech info
8	countries
9	taglines
10	keywords
11	alternate versions
12	crazy credits
13	goofs
14	soundtrack
15	quotes
16	release dates
17	trivia
18	locations
19	mini biography
20	birth notes
21	birth date
22	height
23	death date
24	spouse
25	other works
26	birth name
27	salary history
28	nick names
29	books
30	agent address
31	biographical movies
32	portrayed in
33	where now
34	trade mark
35	interviews
36	article
37	magazine cover photo
38	pictorial
39	death notes
40	LD disc format
41	LD year
42	LD digital sound
43	LD official retail price
44	LD frequency response
45	LD pressing plant
46	LD length
47	LD language
48	LD review
49	LD spaciality
50	LD release date
51	LD production country
52	LD contrast
53	LD color rendition
54	LD picture format
55	LD video noise
56	LD video artifacts
57	LD release country
58	LD sharpness
59	LD dynamic range
60	LD audio noise
61	LD color information
62	LD group genre
63	LD quality program
64	LD close captions-teletext-ld-g
65	LD category
66	LD analog left
67	LD certification
68	LD audio quality
69	LD video quality
70	LD aspect ratio
71	LD analog right
72	LD additional information
73	LD number of chapter stops
74	LD dialogue intellegibility
75	LD disc size
76	LD master format
77	LD subtitles
78	LD status of availablility
79	LD quality of source
80	LD number of sides
81	LD video standard
82	LD supplement
83	LD original title
84	LD sound encoding
85	LD number
86	LD label
87	LD catalog number
88	LD laserdisc title
89	screenplay-teleplay
90	novel
91	adaption
92	book
93	production process protocol
94	printed media reviews
95	essays
96	other literature
97	mpaa
98	plot
99	votes distribution
100	votes
101	rating
102	production dates
103	copyright holder
104	filming dates
105	budget
106	weekend gross
107	gross
108	opening weekend
109	rentals
110	admissions
111	studios
112	top 250 rank
113	bottom 10 rank
\.


--
-- Data for Name: keyword; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.keyword (id, keyword, phonetic_code) FROM stdin;
2068	handcuffed-to-a-bed	H5321
157	jane-austen	J5235
8309	narcotic	N6232
1059	woods	W32
3991	hanging	H5252
2148	junior-high-school	J5624
6744	hogwarts-express	H2632
7068	hf100	H1
6175	snowing	S52
4292	bicycle-accident	B2423
5875	fishing-pole	F2521
7738	handshake	H532
579	art-gallery	A6324
9915	shaving	S152
8273	saipan	S15
1355	detroit-michigan	D3635
4607	extramarital-affair	E2365
5688	screaming	S2652
9323	domestic-quarrel	D5232
3749	reference-to-barry-white	R1652
9452	hula-hoop	H41
2649	prize	P62
8325	intelligence-mole	I5342
4997	dead-body-in-water	D3135
9052	alternate-version-of-same-incident	A4365
3802	pet-bird	P3163
3127	lock-out	L23
9409	gun-store	G5236
1196	wedding-anniversary	W3525
7812	singer-acting	S5262
9955	bust-of-caesar	B2312
7481	horseshoe	H62
5906	thunder	T536
224	cooking	C252
1310	new-york-yankees	N6252
6698	saber-fencing	S1615
9948	coin-flip	C5141
6534	puppet-maker	P1352
6854	united-nations	U5353
4835	groupie	G61
7814	admiral	A3564
6212	giant-insect	G5352
1535	hero	H6
1884	reporter	R1636
1690	panel-game	P5425
2606	china	C5
83	critically-acclaimed	C6324
2862	kissing	K252
1105	cult	C43
3502	women's-college	W5242
4000	river-of-blood	R1614
6445	body-waxing	B3252
1925	webseries	W1262
5852	controversy	C5361
5607	grade-school	G6324
724	military	M436
4151	fear-of-ghosts	F6123
4805	summons	S52
7981	french-accent	F6525
2674	polaroid-camera	P4632
8062	christmas-eve	C6235
2919	mental-disorder	M5343
3371	expectant-father	E2123
2333	cocaine	C25
2573	comedy-troupe	C5361
5240	car-showroom	C6265
2869	cheating	C352
5106	dna	D5
9414	telescopic-rifle	T4212
8374	toyota-starlet	T3236
238	insecurity	I5263
9131	marriage-for-money	M6216
9597	year-1919	Y6
821	religion-versus-science	R4251
9883	telegraph	T4261
5117	passport	P2163
5720	strike	S362
9050	year-1912	Y6
9613	year-1916	Y6
9757	stabbed-with-a-letter-opener	S3134
5181	garden-center	G6352
264	plastic-surgery	P4232
2538	hurt	H63
5624	meteorologist	M3642
5310	glass	G42
9101	lord	L63
5879	hole	H4
9848	seeking-love	S2524
7624	mother-superior	M3621
9060	framed-picture	F6531
8011	reference-to-the-sphinx	R1652
651	bound-and-gagged	B5353
9919	gold-coin	G4325
5091	locker	L26
4432	victorian-house	V2365
538	caiman	C5
8519	magic-carpet	M2613
2743	swiss-bank-account	S2152
276	cold-open	C4315
9625	sudden-death	S353
5265	police-station	P4235
2135	medical-drama	M3243
6815	100th-birthday	T163
893	cookery	C26
222	complaining	C5145
66	travel	T614
7783	cheetah	C3
8376	audi	A3
4483	private-property	P6131
7401	loss-of-friend	L2165
327	gaming	G52
9976	beauty	B3
2378	soccer-game	S2625
1635	reference-to-andy-warhol	R1652
9794	diagram	D265
3745	hispanic-woman	H2152
2209	gay-minister	G5236
9970	horse-stumbles	H6235
7168	extortion	E2363
1836	crucifix-pendant	C6212
7829	territory-name-in-title	T6365
6518	gum-paste	G5123
9830	truth-serum	T6326
1673	headquarters	H3263
4338	haunted-apartment	H5316
3620	wink	W52
5327	murder-suspect	M6362
9019	scotch-and-water	S2325
6839	nikon-camera	N2525
7545	wing	W52
4500	wind	W53
576	wine	W5
5787	blind	B453
2601	patricide	P3623
8156	gun-holster	G5423
6084	tool-box	T412
4833	spouse-abuse	S1212
7914	webisode	W123
6148	playhouse	P42
7234	crime-prevention	C6516
3504	backpack	B212
839	blood-brothers	B4316
7197	purse-snatcher	P6253
9930	draw-water-from-well	D6361
9501	men's-club	M5241
4572	wales	W42
6414	boa-constrictor	B2523
7813	singer-as-actor	S5262
9004	doghouse	D2
7309	yeti	Y3
8442	october-war	O2316
8047	herbal-medicine	H6145
2883	tow-truck	T362
4807	telephone-operator	T4151
228	drinking	D6525
9703	flower-in-hair	F4656
2423	iaido	I3
7376	silver	S416
9129	furniture-design	F6536
7145	scholar	S246
5035	video-game	V325
2670	human-bone	H515
9251	overactive-imagination	O1623
9677	reading-of-will	R3521
1121	mafia-boss	M12
602	boutique-hotel	B3234
718	arrow	A6
3806	temporary-blindness	T5161
5522	volcano	V425
2431	tea-shop	T21
5144	burial	B64
7831	angola	A524
2614	iraq-war	I626
7639	series	S62
582	distillery	D2346
4196	spider	S136
6903	camden-yards	C5356
7437	turnip	T651
6066	laboratory	L1636
8857	neck-breaking	N2162
6379	drag-queen	D625
5718	shame	S5
2251	oprah	O16
8940	business-deal	B2523
5971	paper-bag	P1612
8819	homoeroticism	H5632
5089	keys	K2
31	bribe-attempt	B6135
4888	problem-solving	P6145
8726	hosted-television-series	H2341
7311	south-pole	S314
6252	true-love	T641
6556	grecian-pottery	G6251
7637	martial-arts	M6346
5552	business-takeover	B2523
4008	bloody-scratch	B4326
828	1910s	S
2354	fugitive	F231
6867	grapes	G612
4273	cornerstone	C6562
5249	rspca	R212
8683	car-jump	C6251
3216	reference-to-santa-claus	R1652
9	awkward-situation	A2632
5559	kitchen-maid	K3253
5134	diabetic	D132
1722	counter-terrorist	C5363
6238	atv	A31
2599	counter-terrorism	C5363
833	1970s	S
6402	drugged-drink	D6236
2131	wasp	W21
4748	rich-widow	R23
6662	film-reel	F4564
321	turned-into-animal	T6535
6551	film-shoot	F4523
6230	knight	K523
7838	niger	N26
7138	jumping-to-death	J5152
6138	baby-brother	B1636
1887	basketball	B2314
7771	low-budget-film	L1323
9603	shooting-movie	S3525
7570	service	S612
4968	internal-affairs	I5365
3046	engagement	E5253
484	tango	T52
6671	jazz-pianist	J2152
6514	concept-cake	C5213
8013	stock	S32
2556	dead-mother	D3536
7596	collapse	C412
4252	haunted-by-the-past	H5313
3737	full-moon	F45
9152	insurance-money	I5265
6929	evil	E14
6210	laugh-track	L2362
5702	wealthy-family	W4315
6759	16th-birthday	T163
1146	double-standard	D1423
2365	outlaw	O34
2069	handcuffs	H5321
548	tree	T6
845	shower	S6
4260	pneumonia	P5
1596	war-on-terrorism	W6536
6012	battle-against-evil	B3425
3438	reference-to-marx	R1652
8991	white-rat	W363
7343	selflessness	S4142
6799	tournament-scrabble-player	T6532
5421	freeze-to-death	F623
4382	reference-to-psalm-23	R1652
7807	kidnap	K351
8148	escalator	E2436
2483	glastonbury-festival	G4235
9471	garden-swing	G6352
202	boy-scout	B23
7552	divan	D15
1519	balkan-war	B4256
790	pop-culture	P1243
2945	moving-on	M1525
8361	porsche-panamera	P6215
5562	matriarch	M362
6038	furrier	F6
1076	slash-in-title	S4253
3589	contact-lens	C5323
322	addict	A323
3945	letter	L36
8135	manic-laughter	M5242
3075	age-difference	A2316
1835	video-file	V314
2364	morality	M643
5438	dummy	D5
807	singer	S526
6764	episode	E123
9689	snooping	S5152
5927	arm-injury	A6526
5589	professor	P6126
7764	camp	C51
192	lap-dancer	L1352
658	stand-up-comedy	S3531
3931	hiding-under-covers	H3525
3342	wealthy-parent	W4316
5588	prime-minister	P6523
1185	first-anniversary	F6235
1056	scream	S265
4446	crowbar	C616
8667	russian-drug-dealer	R2536
1717	bomb	B51
597	tequila	T24
6920	christopher-columbus	C6231
1367	george-h.w.-bush	G6212
1937	travois	T612
6928	death-by-falling	D3145
4525	ulcer	U426
1110	sexism	S25
7332	leather-jacket	L3623
6309	hungary	H526
6711	thai	T
1995	wanted-poster	W5312
1390	business-partner	B2521
3376	in-vitro-fertilization	I5136
8298	stuck-in-elevator	S3254
6098	menu	M5
4566	jacobite	J213
188	buxom	B25
9954	bust	B23
5894	cougar	C26
3623	bush	B2
2871	pledge-of-allegiance	P4321
9974	doc-holliday	D243
8434	rich	R2
7340	rice	R2
8899	sound-effect	S5312
6378	porton-down	P6353
6460	dinner-date	D563
9284	big-break	B2162
1279	guano	G5
4744	magazine-publisher	M2514
218	clumsiness	C4525
7194	bow-and-arrow	B536
2799	baseball-bat	B2141
2640	coming-out-of-a-coma	C5231
6557	greek-mythology	G6253
5038	army-veteran	A6513
5088	hostage-situation	H2323
8259	airplane-shot-down	A6145
2612	jaguar	J26
2326	baltimore-ravens	B4356
5928	broken-leg	B6254
7259	crime-victim	C6512
6954	sandhill-crane	S5342
4294	boarder	B636
1245	pretzel	P6324
736	wounded-man	W535
9270	killed-in-shower	K4352
9093	pouring-drink-over-someone	P6523
3648	frigidity	F623
9912	red-wine	R35
6767	gym-locker	G5426
8575	self-hatred	S4136
7084	computer-animation	C5136
3252	disaster	D236
442	fair	F6
3166	heirloom	H645
9718	horse's-hooves	H6212
2719	consummation	C5253
9403	iron-curtain	I6526
1797	black-u.s.-president	B4216
5177	custom-official	C2351
6256	baby-seal	B124
8114	interior-monologue	I5365
6430	internet-video	I5365
4460	hammer	H56
6922	deadpan	D315
5850	apple-computer	A1425
4405	demonologist	D5423
5824	urban-renewal	U6156
390	silent-movie-sequence	S4535
8635	scorn	S265
6587	60th-birthday	T163
6146	missing-item	M2523
3665	pirate	P63
449	nature	N36
392	voice-of-god	V2123
9709	torture-rack	T6362
892	italian-food	I3451
7412	defiance	D152
3181	debt	D13
1372	tyranny	T65
620	south-africa	S3162
995	accident	A2353
7118	comedy-sketch	C5323
9622	oath	O3
2171	new-orleans-louisiana	N6452
4189	incense	I5252
5944	rock-throwing	R2365
1276	double-date	D143
9909	bead-curtain	B3263
9763	third-degree-burn	T6326
3128	obscenity	O1253
2513	stockholm-syndrome	S3245
805	rock-singer	R2526
5878	hay-bale	H14
5721	working-mom	W6252
8980	burying-a-corpse-in-a-cellar	B6526
6380	male-prostitute	M4162
5114	homicide-investigation	H5235
7854	bar-keeper	B6216
7709	canyon	C5
2962	george-washington	G6252
997	con-artist	C5632
569	paris-france	P6216
679	pregnancy	P6252
1389	blonde	B453
4586	girls'-boarding-school	G6421
9568	oversized-book	O1623
6646	lighthouse	L232
8593	game-of-chance	G5125
6158	trapdoor	T6136
6381	pornographic-film	P6526
3694	hearing-voices	H6521
9700	saw-woman-in-half	S541
9524	startled	S3634
1526	cricket-the-game	C6232
3294	borough-name-in-title	B6253
8470	branding-iron	B6535
2539	jackass	J2
5455	japanese-army	J1526
778	life	L1
8712	electrocution	E4236
7609	spit	S13
12	café	C1
9824	prostitute-wife	P6231
6225	filmmaker	F4526
8095	boardroom	B6365
4907	chile	C4
3939	child	C43
4795	chili	C4
8538	flying-boat	F4521
6358	spin	S15
7501	wildcat	W4323
4892	commerce	C562
7002	taken-for-granted	T2516
5286	female-police-officer	F5414
9454	chemical-structure	C5242
1931	empty-canteen	E5132
4046	unwanted-gift	U5321
4187	flooding	F4352
2754	narcissism	N625
393	based-on-comic	B2352
7448	canoeing	C52
9456	expert-witness	E2163
3073	reference-to-napoleon	R1652
5870	chased-by-a-dog	C2313
9686	fig-leaf	F241
1063	madonna	M35
4776	doorman	D65
8169	damaged-bicycle	D5231
8042	trustee	T623
8397	fjernsynsteater	F2652
841	memorial	M564
4671	toaster	T236
6200	aussie-rules	A2642
7772	rebellion	R145
5635	after-school-special	A1362
2933	pay-raise	P62
425	rallye	R4
3759	year-1976	Y6
4526	year-1974	Y6
5331	demotion	D535
4504	year-1972	Y6
8445	year-1973	Y6
3807	year-1970	Y6
2737	year-1971	Y6
8188	half-sister	H4123
1182	bureaucrat	B6263
6123	middle-ages	M342
9626	will-to-live	W4341
2572	comedy-team	C535
7027	battered-wife	B3631
5143	brain-damage	B6535
7020	restaurant-owner	R2365
3118	chicken-pox	C2512
9877	pile-of-money	P415
6579	engagement-party	E5253
4804	subpoena	S15
1861	silenced-shotgun	S4523
922	arrow-in-eye	A65
4174	throttling	T6345
5553	class-distinction	C4232
9857	scam	S25
37	disguise	D2
5197	reference-to-king-kong	R1652
7705	walking-under-a-ladder	W4252
7949	lasso	L2
160	storage-unit	S3625
265	speeding-ticket	S1352
7974	ham	H5
5409	insubordination	I5216
5877	hay	H
5077	autistic-teenager	A3232
613	prison	P625
4921	shoemaker	S526
287	hat	H3
9598	car-license-plate	C6425
6067	last-of-one's-kind	L2315
9681	husband-and-wife-working-together	H2153
6462	playing-with-own-breasts	P4523
2650	survival	S614
6083	time-machine	T525
3208	gameboy	G51
4863	holiday-home	H435
3369	birth	B63
2311	somnophilia	S514
9589	strait-jacket	S3632
2168	head-in-toilet	H3534
6244	desire	D26
4642	crime-scene	C6525
8107	seaside	S23
4488	sleeping-in-the-forest	S4152
5886	animated-episode	A5312
5630	weather-observation	W3612
7871	prologue	P642
5737	girl-on-boys-team	G6451
2602	battlefield	B3414
3415	attorney	A365
1880	heart-attack	H632
584	fishing-village	F2521
7489	crown	C65
6112	captive	C131
3048	unwanted-pregnancy	U5316
5759	harassment	H6253
6633	christmas-decoration	C6235
9082	age-discrimination	A2326
3054	sleep-over	S416
7674	comeuppance	C5152
1728	double-agent	D1425
8256	air-attack	A632
7641	fox	F2
4208	fog	F2
9121	exposition	E2123
5129	treadmill	T6354
9179	blacking-out	B4252
9744	canandaigua-new-york	C5325
5430	bath-salt	B3243
8831	joking-about-program's-sponsor	J2521
3334	panic-attack	P5232
312	nuclear-war	N246
7112	movie-news	M152
4067	cross-protects-against-evil	C6216
2800	crossing-the-border	C6252
2645	movie-criticism	M1263
7487	bowing	B52
5756	swim-team	S535
7321	despair	D216
7200	los-angeles-international-airport	L2524
3964	butcher's-shower	B3262
6407	honeymoon	H5
4099	son	S5
575	walled-city	W4323
5734	hospice	H212
3545	gardening	G6352
8440	military-offensive	M4361
1222	clothes-line	C4324
8455	sword-and-fantasy	S6353
7349	support	S163
8140	reference-to-jack-the-ripper	R1652
1154	sex-tape	S231
3388	triplets	T6143
4024	slide-show	S432
7789	gender-disguise	G5363
1605	year-2012	Y6
9752	year-1910	Y6
3178	junk-food	J5213
7166	christmas-episode	C6235
7588	pretending-to-be-dead	P6353
1138	teenage-boy	T521
9973	water-tower	W3636
8307	incinerator	I5256
7936	masked-ball	M2314
7861	duel	D4
7846	genealogy	G542
8255	tall-girl	T4264
3065	break-up	B621
6529	black-hawk	B42
4840	narration-from-the-grave	N6351
3207	duet	D3
5122	police-superintendent	P4216
4402	baby-powder	B136
7253	dune-buggy	D512
3571	juvenile	J154
1082	teenage-girl	T5264
642	wehland	W453
2386	tournament	T653
3021	bathrobe	B361
3605	textbook	T2312
4470	land-grant	L5326
924	decapitation	D2135
9165	death-row	D36
838	television-history	T4125
4625	black-market	B4256
8049	liver-disease	L1632
4036	dead-brother	D3163
2964	crutches	C632
8451	genie	G5
9558	pawn-ticket	P5323
5003	dry-cleaners	D6245
479	actor	A236
2679	sexual-sadism	S2423
4104	tied-to-a-chair	T326
1356	detroit-tigers	D3632
1572	transgender	T6525
9416	caller-hangs-up-when-phone-is-answered	C4652
5511	greenhouse-effect	G6521
5735	basketball-team	B2314
440	live-comedy	L1253
1915	double-cross	D1426
4085	looking-at-one's-self-in-a-mirror	L2523
9473	manhunt	M53
3460	murder-mystery	M6365
6786	king-kong	K5252
5617	persecution	P6235
9241	cleaver	C416
7005	year-1899	Y6
4946	shakespeare's-othello	S2162
947	mad-scientist	M3253
1001	jewelry	J46
6439	county-fair	C5316
1876	shootout	S3
8870	playing-chess	P452
5800	death-of-sister	D3123
3470	bluebells	B4142
1169	crotch-shot	C6323
4829	marital-discord	M6343
4920	peacock	P2
2064	shot-in-the-stomach	S3532
7426	chain	C5
3822	necromancy	N2652
7146	swinging-london	S5252
5642	child-entrepreneur	C4353
7273	petty-criminal	P3265
5176	crocodile	C6234
4191	kiss-on-the-cheek	K2532
3242	reference-to-jackie-kennedy	R1652
5993	dog-shot-by-gun	D2312
7550	chair	C6
5545	ballet	B43
6996	reference-to-red-skelton	R1652
8728	precognition	P6253
2340	dea-agent	D253
2997	reference-to-martin-luther-king	R1652
2897	black-eye	B42
7322	dragonfly	D6251
5532	allentown-pennsylvania	A4535
4464	husband-wife-estrangement	H2153
69	cheap	C1
4357	praying-hands	P6525
1624	internet-chat	I5365
2998	sojourner-truth	S2656
2120	minute	M53
636	bauerfeind	B6153
4621	judaism	J325
6699	seasoning-factory	S2521
4451	estranged-husband	E2365
3934	tricycle	T624
4855	british-secret-intelligence-service	B6326
4053	belief-in-the-devil	B4153
1500	subway	S1
427	live-action	L1235
1923	team	T5
8276	atomic-bomb	A3521
8745	police-lieutenant	P4243
8925	bulldozer	B4326
7015	meadow	M3
2405	attic	A32
7908	fingernail	F5265
1610	prediction	P6323
8679	patient	P353
3406	lingerie-slip	L5262
6024	cartoon-elephant	C6354
8162	woman-driver	W5361
5529	falling-in-love	F4525
3886	framed-photograph	F6531
1365	saint-louis	S5342
7380	archery-lesson	A6264
2442	extraterrestrial	E2363
5972	record-player	R2631
8402	local-news	L2452
938	toxic-waste	T23
714	falling	F452
5171	aerobics-class	A6124
3622	badge	B32
6502	jury	J6
5300	falling-from-height	F4521
3081	funeral	F564
9429	store-santa-claus	S3625
6888	friend's-wedding	F6532
7211	repairing-a-tv-set	R1652
6970	reference-to-longfellow	R1652
8078	hydrochloric-acid	H3624
8878	lying-to-wife	L5231
5465	galileo	G4
2085	serial-killer	S6424
8926	convict	C5123
452	model-airplane	M3461
2479	relationship-problems	R4352
8978	applying-lipstick	A1452
245	love	L1
4115	disembodied-voice	D2513
2026	murder-trial	M6363
4242	back-wound	B253
6863	fire-truck	F6362
8245	australian-history	A2364
8436	1967-war	W6
4570	queen-victoria	Q5123
1075	single-parent	S5241
9902	told-to-get-out-of-town	T4323
9430	twinkle-in-the-eye	T5245
7352	tripping	T6152
3339	gay-kiss	G2
993	non-sequitur	N5236
4802	prosecutor	P6236
2764	female-archaeologist	F5462
6163	underground-river-system	U5362
8127	door-to-door-salesman	D6362
3642	clitoris	C4362
5029	stolen-credit-card	S3452
6267	death-of-son	D3125
9499	doppelganger	D1425
8988	suspected-of-killing-one's-wife	S2123
2633	investigative-reporter	I5123
5351	health-inspector	H4352
2710	police-informant	P4251
159	steamer-trunk	S3563
8853	idle-rich	I3462
2457	mascot	M23
6639	radio-city	R323
8681	car-damage	C6352
7614	androgyny	A5362
7780	lumberjack	L5162
2176	abortion	A1635
2623	reportage	R1632
5563	military-draft	M4363
2747	bombmaker	B5152
182	home-owners-association	H5623
5369	george-cross	G6262
2142	dating-show	D352
9674	television-repair	T4125
9022	tijuana-mexico	T252
2393	nascar	N26
3188	stole	S34
3590	crossword-puzzle	C6263
3045	casual-sex	C242
2038	cowardly-sheriff	C6342
9480	tolling-bell	T4521
3643	dyke	D2
1030	queens-new-york-city	Q5256
2264	gay-bait	G13
606	elephant	E4153
2412	plot-twist	P4323
4139	call-for-help	C4164
2653	criminal-investigation	C6545
2953	laundry	L536
4453	explorer	E2146
7896	celebrity-has-been	C4163
5432	drowning-in-a-bathtub	D6525
2551	native-american	N3156
4764	long-lost-daughter	L5242
1860	security-guard	S2632
2984	date	D3
2613	wikileaks	W242
4468	killing-an-animal	K4525
3459	childhood-friend	C4316
6771	mock-interview	M2536
9878	pulley	P4
6914	stress	S362
7058	surfing	S6152
1574	wheelchair	W426
1129	truck	T62
4541	face-scratch	F2632
4899	absurd-humor	A1263
3206	tutoring	T3652
6923	manga	M52
604	cable-car	C1426
999	hidden-fortune	H3516
2791	beaten-to-death	B353
1641	epilepsy	E1412
9498	passenger-ship	P2526
9263	penlight	P5423
8193	claim-in-title	C4534
9055	beheading	B352
1785	dead-flight-attendant	D3142
9365	thumb	T51
8690	exploding-building	E2143
7073	screen-writing	S2656
9712	year-1954	Y6
705	attraction	A3623
3152	suspicion	S2125
3123	suspension	S2152
4655	gold-leaf	G4341
2760	swastika	S232
2231	stand-up-comedian	S3531
6320	apron	A165
3249	civilian	C145
3394	alternative-comedy	A4365
1256	insomnia	I525
6089	amulet	A543
9786	records	R2632
2046	hanged-man	H5235
9562	diamond-necklace	D5352
7155	regression-therapy	R2625
1174	ketchup	K321
4359	reading-book	R3521
8053	spiritualism	S1634
6715	cartoon-character	C6352
1649	drama-filmmaking	D6514
3083	cardiac-arrest	C6326
1284	look-alike	L242
271	beer-bottle	B6134
2740	false-passport	F4212
3513	fisherman	F265
1784	security-guard-killed	S2632
2900	bowling	B452
4363	spiritualist	S1634
9863	amnesty	A523
2859	school-bus	S2412
7612	whitewashing	W3252
7886	square	S26
5195	reference-to-acker-bilk	R1652
9855	receipt	R213
6918	scripted-reality	S2613
5052	missing-girl	M2526
7883	minority	M563
7987	denouement	D53
695	workaholic	W6242
6573	sick-children	S2436
4054	blanket-moves-by-itself	B4523
9025	insurance-investigator	I5265
7149	swordsman	S6325
1060	investigation	I5123
1700	trauma	T65
8464	superhuman-speed	S1652
383	internet	I5365
9140	bird-imitation	B6353
1619	classic-rock-music	C4262
4010	demonology	D542
9260	coroners-inquest	C6562
4531	hairdresser	H6362
8110	broken-engagement	B6252
6907	making-a-cake	M252
3211	1st-century-b.c.	S3253
1262	spooning	S152
4961	mime	M5
1404	money-problems	M5161
8243	caucasus-mountains	C2535
911	online-series	O5452
3377	foreign-adoption	F6253
928	throat-slitting	T6324
16	dirty-joke	D632
3414	telenovela	T4514
5769	punk	P52
611	ostrich	O2362
8189	slashed-wrist	S4236
9523	locksmith	L253
5997	junkyard-dog	J5263
7431	neglect	N2423
9402	eye-patch	E132
4458	gunshot	G523
5324	intuition	I535
8854	long-hair	L526
6644	fund-raiser	F5362
1543	hit-record	H3626
981	spanish	S152
4925	city	C3
6253	wrath	W63
9399	money-tree	M536
1489	bite	B3
4663	displaced-person	D2142
6931	hit-by-a-train	H3136
1550	vladimir-lenin	V4356
2498	cinema-verite	C5163
90	funny-nazi	F52
5002	drugstore	D6236
260	tall-man	T45
7953	transatlantic-voyage	T6523
8101	shakespearean-play	S2165
2473	school-career-day	S2426
4109	breaking-up-with-girlfriend	B6252
5581	shawl	S4
9612	military-police	M4361
1358	san-diego-california	S5324
8250	gigantic-breasts	G2532
2345	drug-cartel	D6263
4617	inventor	I5153
2566	university-professor	U5162
6791	cherry-pie	C61
1643	clairvoyance	C4615
1818	biohazard	B263
5789	savant	S153
1608	future	F36
988	fantasy-world	F5326
5970	janitor	J536
641	russia	R2
2465	fat-cop	F321
3773	push-down-stairs	P2352
3993	illness	I452
1764	terrorism-prevention	T6251
5112	greyhound	G653
687	argument	A6253
5456	japanese-invasion	J1525
4609	older-man-younger-woman-relationship	O4365
7210	picketing	P2352
7638	sas	S2
1293	year-in-title	Y6534
6150	saw	S
4473	male-ghost	M423
2695	alias	A42
6281	hit-with-a-skateboard	H3231
1511	comedy-central	C5325
4854	zoo	Z
1508	note	N3
2113	dallas-texas	D4232
7395	butterfly	B3614
2233	television-writer	T4125
6701	movie-fan	M15
1967	indian-wife	I5351
4593	loss-of-father	L2136
1982	telegraph-office	T4261
3598	knee	K5
3011	meeting-parent	M3521
5314	pager	P26
6946	landscape-painter	L5321
7680	foot-closeup	F3242
2005	sonora-mexico	S5652
1992	ruby-arizona	R1625
1964	ex-convict	E2512
9761	sale	S4
4673	attempted-murder	A3513
3811	axe	A2
4074	flying-book	F4521
4559	salt	S43
2446	landlady	L5343
5704	child-custody	C4323
5175	cobra	C16
1791	murder-of-a-policewoman	M6361
1061	murder-weapon	M6361
9472	hiding-place	H3521
2299	reference-to-nintendo	R1652
4243	bloody-arm	B4365
4345	traumatic-experience	T6532
7504	blackfoot-indian	B4213
2685	run-over-by-a-car	R5161
7307	northwest-passage	N6323
3815	cloak	C42
8046	fox-terrier	F236
3779	tears	T62
1375	hockey	H2
6079	robe	R1
3444	child-murder	C4356
227	dispute	D213
3337	lesbian-kiss	L2152
333	psychiatrist	P2362
3307	assumed-identity	A2535
6360	friends-who-hate-each-other	F6532
7633	hand-to-hand-combat	H5353
1868	aerial-surveillance	A6426
3646	female-ejaculation	F5424
7290	olympic-medalist	O4512
1980	jail-break	J4162
483	singer-songwriter	S5262
8931	road-construction	R3252
7059	35mm-adapter	M5313
4972	blunt-instrument	B4535
5383	planting-evidence	P4535
6735	red-carpet	R3261
5215	pimp	P51
432	artist	A6323
6442	pregnant-woman	P6253
5727	drunk-driver	D6523
1556	priest	P623
4510	landlord	L5346
291	homeopathy	H513
647	vision	V25
6326	wet-t-shirt	W3263
7617	keyboard	K163
4629	gangster	G5236
1699	surgery	S626
2716	body-dump	B351
8212	religious-icon	R425
3767	garden-hose	G6352
5473	planet	P453
9693	shot-point-blank	S3153
5544	disability-rights	D2143
4183	american-girl	A5625
2392	auto-racing	A3625
9422	resigned-to-dying	R2535
822	science-history	S2523
3121	jumper	J516
4132	apparition	A1635
5065	supermarket	S1656
3695	moving-in	M1525
5154	steroid	S363
6049	baseball-cap	B2142
6227	moviemaking	M1525
6947	life-jacket	L123
8017	incriminating-photograph	I5265
4077	hair-stands-on-end	H6235
6775	harmonica	H652
2521	millionaire	M456
4898	serbian-immigrant	S6152
4818	monkey-wrench	M5265
9249	fantasy-sequence	F5325
9457	safety-catch	S1323
2246	workplace	W6214
6617	indian-culture	I5352
5014	mutilated-corpse	M3432
8602	riddle	R34
8099	prince-of-wales	P6521
\.


--
-- Data for Name: kind_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kind_type (id, kind) FROM stdin;
1	movie
2	tv series
3	tv movie
4	video movie
5	tv mini series
6	video game
7	episode
\.


--
-- Data for Name: link_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.link_type (id, link) FROM stdin;
1	follows
2	followed by
3	remake of
4	remade as
5	references
6	referenced in
7	spoofs
8	spoofed in
9	features
10	featured in
11	spin off from
12	spin off
13	version of
14	similar to
15	edited into
16	edited from
17	alternate language version of
18	unknown link
\.


--
-- Data for Name: movie_companies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.movie_companies (id, movie_id, company_id, company_type_id, note) FROM stdin;
1	2	1	1	(2006) (USA) (TV)
2	2	1	1	(2006) (worldwide) (TV)
3	11	2	1	(2012) (worldwide) (all media)
4	44	3	1	(2013) (USA) (all media)
5	50	4	1	(2011) (UK) (TV)
6	50	5	1	(2010-2011) (Canada) (TV)
7	50	6	1	(2010-2011) (USA) (TV)
8	50	7	1	(2011) (Australia) (TV)
9	50	8	1	(2011) (Netherlands) (TV)
10	50	9	1	(2011) (Brazil) (TV)
11	51	4	1	(2011) (UK) (TV)
12	51	5	1	(2010) (Canada) (TV)
13	51	6	1	(2010) (USA) (TV)
14	51	7	1	(2011) (Australia) (TV)
15	51	8	1	(2011) (Netherlands) (TV)
16	51	9	1	(2011) (Brazil) (TV)
17	52	4	1	(2011) (UK) (TV)
18	52	5	1	(2011) (Canada) (TV)
19	52	6	1	(2011) (USA) (TV)
20	52	8	1	(2011) (Netherlands) (TV)
21	53	4	1	(2011) (UK) (TV)
22	53	5	1	(2010) (Canada) (TV)
23	53	6	1	(2010) (USA) (TV)
24	53	8	1	(2011) (Netherlands) (TV)
25	54	4	1	(2011) (UK) (TV)
26	54	5	1	(2010) (Canada) (TV)
27	54	6	1	(2010) (USA) (TV)
28	54	7	1	(2011) (Australia) (TV)
29	54	8	1	(2011) (Netherlands) (TV)
30	54	9	1	(2011) (Brazil) (TV)
31	55	4	1	(2011) (UK) (TV)
32	55	5	1	(2011) (Canada) (TV)
33	55	6	1	(2011) (USA) (TV)
34	55	8	1	(2011) (Netherlands) (TV)
35	56	4	1	(2011) (UK) (TV)
36	56	5	1	(2010) (Canada) (TV)
37	56	6	1	(2010) (USA) (TV)
38	56	8	1	(2011) (Netherlands) (TV)
39	57	4	1	(2011) (UK) (TV)
40	57	5	1	(2011) (Canada) (TV)
41	57	6	1	(2011) (USA) (TV)
42	57	8	1	(2011) (Netherlands) (TV)
43	58	4	1	(2011) (UK) (TV)
44	58	5	1	(2011) (Canada) (TV)
45	58	6	1	(2011) (USA) (TV)
46	58	8	1	(2011) (Netherlands) (TV)
47	59	4	1	(2011) (UK) (TV)
48	59	5	1	(2010) (Canada) (TV)
49	59	6	1	(2010) (USA) (TV)
50	59	8	1	(2011) (Netherlands) (TV)
51	60	4	1	(2011) (UK) (TV)
52	60	5	1	(2010) (Canada) (TV)
53	60	6	1	(2010) (USA) (TV)
54	60	7	1	(2011) (Australia) (TV)
55	60	8	1	(2011) (Netherlands) (TV)
56	60	9	1	(2011) (Brazil) (TV)
57	61	4	1	(2011) (UK) (TV)
58	61	5	1	(2010) (Canada) (TV)
59	61	6	1	(2010) (USA) (TV)
60	61	7	1	(2011) (Australia) (TV)
61	61	8	1	(2011) (Netherlands) (TV)
62	61	9	1	(2011) (Brazil) (TV)
63	62	4	1	(2011) (UK) (TV)
64	62	5	1	(2011) (Canada) (TV)
65	62	6	1	(2011) (USA) (TV)
66	62	8	1	(2011) (Netherlands) (TV)
67	63	4	1	(2011) (UK) (TV)
68	63	5	1	(2010) (Canada) (TV)
69	63	6	1	(2010) (USA) (TV)
70	63	8	1	(2011) (Netherlands) (TV)
71	64	4	1	(2011) (UK) (TV)
72	64	5	1	(2010) (Canada) (TV)
73	64	6	1	(2010) (USA) (TV)
74	64	7	1	(2011) (Australia) (TV)
75	64	8	1	(2011) (Netherlands) (TV)
76	64	9	1	(2011) (Brazil) (TV)
77	65	4	1	(2011) (UK) (TV)
78	65	5	1	(2011) (Canada) (TV)
79	65	6	1	(2011) (USA) (TV)
80	65	8	1	(2011) (Netherlands) (TV)
81	66	4	1	(2011) (UK) (TV)
82	66	5	1	(2011) (Canada) (TV)
83	66	6	1	(2011) (USA) (TV)
84	66	8	1	(2011) (Netherlands) (TV)
85	67	4	1	(2011) (UK) (TV)
86	67	5	1	(2010) (Canada) (TV)
87	67	6	1	(2010) (USA) (TV)
88	67	7	1	(2011) (Australia) (TV)
89	67	8	1	(2011) (Netherlands) (TV)
90	67	9	1	(2011) (Brazil) (TV)
91	68	4	1	(2011) (UK) (TV)
92	68	5	1	(2010) (Canada) (TV)
93	68	6	1	(2010) (USA) (TV)
94	68	7	1	(2011) (Australia) (TV)
95	68	8	1	(2011) (Netherlands) (TV)
96	69	10	1	(1986-1989)
97	69	11	1	(1989-)
98	70	12	1	(2010) (USA) (TV)
99	82	13	1	(2001) (Canada) (TV)
100	82	14	1	(2001) (worldwide) (TV)
101	85	6	1	(1984) (USA) (TV)
102	86	15	1	(2002) (USA) (TV)
103	94	16	1	(2005) (USA) (TV)
104	106	17	1	(2012) (USA) (all media)
105	114	18	1	(2004) (Canada) (TV)
106	114	19	1	(2004) (USA) (TV)
107	118	17	1	\N
108	196	20	1	(2009) (USA) (TV)
109	211	20	1	(2009) (USA) (all media)
110	227	21	1	(1980) (Australia) (TV)
111	228	22	1	(2003) (USA) (TV)
112	272	19	1	(1979) (USA) (TV)
113	272	23	1	(USA) (TV)
114	273	19	1	(1979) (USA) (TV)
115	279	19	1	(1979) (USA) (TV)
116	282	24	1	(2011) (UK) (TV)
117	283	25	1	(2009) (USA) (TV)
118	284	26	1	(????) (worldwide) (video)
119	284	27	1	(1982-1992) (UK) (TV) (original airing)
120	284	28	1	(2008-) (Estonia) (TV) (re-release)
121	284	29	1	(2003) (Finland) (DVD)
122	284	30	1	(2010) (Germany) (DVD)
123	284	31	1	(199?-) (Netherlands) (TV) (reruns) (RTL5) (RTL7)
124	284	32	1	(19??-????) (Netherlands) (TV)
125	284	33	1	(2008) (Netherlands) (DVD) (season 5)
126	284	34	1	(2004) (USA) (DVD)
127	370	35	1	(2010) (UK) (all media)
128	371	36	1	(2007) (Canada) (TV)
129	398	37	1	(2000) (Yugoslavia) (TV)
130	404	38	1	(2007) (Belgium) (TV)
131	405	27	1	(2001) (UK) (TV)
132	414	39	1	(2009) (UK) (TV)
133	579	40	1	(2012) (worldwide) (DVD)
134	580	40	1	(2012) (worldwide) (DVD)
135	581	41	1	(2006) (USA) (TV)
136	581	42	1	(2012) (Hungary) (TV) (re-release)
137	581	43	1	(2012-2013) (Hungary) (TV) (re-release)
138	581	44	1	(2006) (worldwide) (all media)
139	581	45	1	(2008) (Hungary) (TV)
140	581	46	1	(2010) (Hungary) (TV) (re-release)
141	581	47	1	(2009) (Hungary) (TV) (re-release)
142	586	41	1	\N
143	596	48	1	(2007-) (UK) (TV)
144	596	49	1	(2006-) (USA) (TV)
145	596	31	1	(2008-) (Netherlands) (TV) (RTL8)
146	596	46	1	(2009-) (Hungary) (TV)
147	596	50	1	(2009) (Belgium) (DVD) (season 1)
148	596	51	1	(2009) (Netherlands) (DVD) (season 1)
149	596	52	1	(2009) (USA) (DVD) (season 2)
150	596	53	1	(2008-) (Estonia) (TV)
151	597	49	1	(2010) (USA) (TV)
152	597	46	1	(2011) (Hungary) (TV)
153	600	46	1	(2010) (Hungary) (TV)
154	601	49	1	(2010) (USA) (TV)
155	602	46	1	(2011) (Hungary) (TV)
156	603	46	1	(2011) (Hungary) (TV)
157	605	46	1	(2011) (Hungary) (TV)
158	606	54	1	(2008) (Germany) (TV)
159	606	49	1	(2007) (USA) (TV)
160	606	46	1	(2010) (Hungary) (TV)
161	607	49	1	(2010) (USA) (TV)
162	607	46	1	(2012) (Hungary) (TV)
163	608	54	1	(2009) (Germany) (TV)
164	608	49	1	(2007) (USA) (TV)
165	608	46	1	(2010) (Hungary) (TV)
166	609	49	1	(2010) (USA) (TV)
167	609	46	1	(2012) (Hungary) (TV)
168	610	54	1	(2008) (Germany) (TV)
169	610	49	1	(2006) (USA) (TV)
170	610	46	1	(2010) (Hungary) (TV)
171	611	54	1	(2008) (Germany) (TV)
172	611	49	1	(2006) (USA) (TV)
173	611	46	1	(2009) (Hungary) (TV)
174	612	46	1	(2011) (Hungary) (TV)
175	613	46	1	(2012) (Hungary) (TV)
176	614	54	1	(2008) (Germany) (TV)
177	614	49	1	(2006) (USA) (TV)
178	614	46	1	(2009) (Hungary) (TV)
179	615	46	1	(2011) (Hungary) (TV)
180	617	46	1	(2010) (Hungary) (TV)
181	618	49	1	(2010) (USA) (TV)
182	618	46	1	(2011) (Hungary) (TV)
183	619	54	1	(2008) (Germany) (TV)
184	619	49	1	(2007) (USA) (TV)
185	619	46	1	(2010) (Hungary) (TV)
186	620	54	1	(2009) (Germany) (TV)
187	620	49	1	(2007) (USA) (TV)
188	620	46	1	(2010) (Hungary) (TV)
189	622	54	1	(2008) (Germany) (TV)
190	622	49	1	(2007) (USA) (TV)
191	622	46	1	(2010) (Hungary) (TV)
192	624	46	1	(2011) (Hungary) (TV)
193	629	46	1	(2010) (Hungary) (TV)
194	630	46	1	(2011) (Hungary) (TV)
195	631	46	1	(2010) (Hungary) (TV)
196	632	46	1	(2011) (Hungary) (TV)
197	633	54	1	(2009) (Germany) (TV)
198	633	49	1	(2007) (USA) (TV)
199	633	46	1	(2010) (Hungary) (TV)
200	634	46	1	(2011) (Hungary) (TV)
201	635	54	1	(2008) (Germany) (TV)
202	635	49	1	(2006) (USA) (TV)
203	635	31	1	(2008) (Netherlands) (TV) (RTL8)
204	635	46	1	(2009) (Hungary) (TV)
205	636	46	1	(2011) (Hungary) (TV)
206	637	46	1	(2011) (Hungary) (TV)
207	638	46	1	(2011) (Hungary) (TV)
208	639	46	1	(2011) (Hungary) (TV)
209	642	54	1	(2008) (Germany) (TV)
210	642	49	1	(2006) (USA) (TV)
211	642	46	1	(2009) (Hungary) (TV)
212	644	49	1	(2008) (USA) (TV)
213	644	46	1	(2011) (Hungary) (TV)
214	645	49	1	(2010) (USA) (TV)
215	645	46	1	(2011) (Hungary) (TV)
216	646	49	1	(1998) (USA) (TV) (original airing)
217	646	46	1	(2011) (Hungary) (TV)
218	647	46	1	(2011) (Hungary) (TV)
219	648	46	1	(2011) (Hungary) (TV)
220	649	54	1	(2008) (Germany) (TV)
221	649	49	1	(2007) (USA) (TV)
222	649	46	1	(2010) (Hungary) (TV)
223	650	46	1	(2011) (Hungary) (TV)
224	651	54	1	(2008) (Germany) (TV)
225	651	49	1	(2007) (USA) (TV)
226	651	46	1	(2010) (Hungary) (TV)
227	651	55	1	(2008) (Belgium) (TV)
228	651	56	1	(2008) (France) (TV)
229	652	54	1	(2008) (Germany) (TV)
230	652	49	1	(2007) (USA) (TV)
231	652	46	1	(2010) (Hungary) (TV)
232	653	49	1	(2010) (USA) (TV)
233	654	54	1	(2008) (Germany) (TV)
234	654	49	1	(2007) (USA) (TV)
235	654	46	1	(2010) (Hungary) (TV)
236	654	55	1	(2008) (Belgium) (TV)
237	654	56	1	(2008) (France) (TV)
238	656	49	1	(2009) (USA) (TV)
239	656	46	1	(2011) (Hungary) (TV)
240	657	49	1	(2010) (USA) (TV)
241	658	54	1	(2008) (Germany) (TV)
242	658	49	1	(2007) (USA) (TV)
243	658	46	1	(2010) (Hungary) (TV)
244	659	54	1	(2008) (Germany) (TV)
245	659	49	1	(2007) (USA) (TV)
246	659	46	1	(2010) (Hungary) (TV)
247	660	49	1	(2010) (USA) (TV)
248	661	49	1	(2009) (USA) (TV)
249	661	46	1	(2011) (Hungary) (TV)
250	662	46	1	(2011) (Hungary) (TV)
251	663	54	1	(2008) (Germany) (TV)
252	663	49	1	(2006) (USA) (TV)
253	663	46	1	(2009) (Hungary) (TV)
254	664	54	1	(2008) (Germany) (TV)
255	664	49	1	(2007) (USA) (TV)
256	664	46	1	(2010) (Hungary) (TV)
257	665	54	1	(2008) (Germany) (TV)
258	665	49	1	(2007) (USA) (TV)
259	665	46	1	(2010) (Hungary) (TV)
260	666	49	1	(2010) (USA) (TV)
261	666	46	1	(2011) (Hungary) (TV)
262	667	49	1	(2009) (USA) (TV)
263	668	46	1	(2011) (Hungary) (TV)
264	669	54	1	(2008) (Germany) (TV)
265	669	49	1	(2006) (USA) (TV)
266	669	46	1	(2009) (Hungary) (TV)
267	670	49	1	(2007) (USA) (TV)
268	670	46	1	(2010) (Hungary) (TV)
269	670	52	1	(2009) (USA) (DVD)
270	671	54	1	(2008) (Germany) (TV)
271	671	49	1	(2006) (USA) (TV)
272	671	46	1	(2010) (Hungary) (TV)
273	673	54	1	(2008) (Germany) (TV)
274	673	49	1	(2006) (USA) (TV)
275	673	46	1	(2009) (Hungary) (TV)
276	674	46	1	(2010) (Hungary) (TV)
277	675	54	1	(2008) (Germany) (TV)
278	675	49	1	(2007) (USA) (TV)
279	675	46	1	(2010) (Hungary) (TV)
280	677	54	1	(2008) (Germany) (TV)
281	677	49	1	(2006) (USA) (TV)
282	677	46	1	(2009) (Hungary) (TV)
283	678	57	1	(2004) (USA) (TV)
284	681	6	1	(1961) (USA) (TV) (original airing)
285	682	6	1	(1961) (USA) (TV)
286	683	6	1	(1961) (USA) (TV)
287	684	6	1	(1961) (USA) (TV)
288	685	6	1	(1961) (USA) (TV)
289	686	6	1	(1961) (USA) (TV)
290	687	6	1	(1961) (USA) (TV) (original airing)
291	688	6	1	(1961) (USA) (TV)
292	689	6	1	(1961) (USA) (TV) (original airing)
293	690	6	1	(1961) (USA) (TV)
294	691	6	1	(1961) (USA) (TV)
295	692	6	1	(1961) (USA) (TV)
296	693	6	1	(1961) (USA) (TV)
297	694	6	1	(1961) (USA) (TV)
298	695	6	1	(1961) (USA) (TV)
299	399	58	1	(2009) (worldwide) (TV)
300	429	59	1	(2007) (Netherlands) (DVD) (season 1)
301	429	59	1	(2009) (Netherlands) (DVD) (season 2)
302	429	60	1	(2006-) (Netherlands) (TV)
303	429	61	1	(2011) (Netherlands) (DVD) (season 3)
304	442	60	1	(2011) (Netherlands) (TV)
305	443	60	1	(2011) (Netherlands) (TV)
306	452	60	1	(2011) (Netherlands) (TV)
307	453	60	1	(2011) (Netherlands) (TV)
308	454	60	1	(2011) (Netherlands) (TV)
309	456	60	1	(2011) (Netherlands) (TV)
310	457	60	1	(2011) (Netherlands) (TV)
311	460	60	1	(2011) (Netherlands) (TV)
312	469	62	1	(2004) (Netherlands) (DVD) (season 1)
313	469	62	1	(2006) (Netherlands) (DVD) (seasons 2-4)
314	469	31	1	(1995-2003) (Netherlands) (TV) (RTL4) (seasons 3-9)
315	469	31	1	(2004-2005) (Netherlands) (TV) (RTL8) (re-run)
316	469	31	1	(2009) (Netherlands) (TV) (RTL8) (re-run)
317	469	63	1	(1993-1995) (Netherlands) (TV) (seasons 1 and 2)
318	470	31	1	(2000) (Netherlands) (TV)
319	471	63	1	(1994) (Netherlands) (TV)
320	473	31	1	(1998) (Netherlands) (TV) (RTL4)
321	475	31	1	(1999) (Netherlands) (TV) (RTL4)
322	478	31	1	(1995) (Netherlands) (TV) (RTL4)
323	479	63	1	(1994) (Netherlands) (TV)
324	480	31	1	(1996) (Netherlands) (TV) (RTL4)
325	481	31	1	(1999) (Netherlands) (TV) (RTL4)
326	483	31	1	(1997) (Netherlands) (TV) (RTL4)
327	484	31	1	(1998) (Netherlands) (TV) (RTL4)
328	485	31	1	(1999) (Netherlands) (TV) (RTL4)
329	486	31	1	(2000) (Netherlands) (TV)
330	487	63	1	(1995) (Netherlands) (TV)
331	488	63	1	(1994) (Netherlands) (TV)
332	489	63	1	(1995) (Netherlands) (TV)
333	491	31	1	(1997) (Netherlands) (TV) (RTL4)
334	492	63	1	(1995) (Netherlands) (TV)
335	493	31	1	(1996) (Netherlands) (TV) (RTL4)
336	494	31	1	(1997) (Netherlands) (TV) (RTL4)
337	495	63	1	(1995) (Netherlands) (TV)
338	496	63	1	(1995) (Netherlands) (TV)
339	497	63	1	(1995) (Netherlands) (TV)
340	498	31	1	(1998) (Netherlands) (TV) (RTL4)
341	499	63	1	(1994) (Netherlands) (TV)
342	500	31	1	(1999) (Netherlands) (TV) (RTL4)
343	506	31	1	(1996) (Netherlands) (TV) (RTL4)
344	507	31	1	(1997) (Netherlands) (TV) (RTL4)
345	508	31	1	(1999) (Netherlands) (TV) (RTL4)
346	509	31	1	(1998) (Netherlands) (TV) (RTL4)
347	510	31	1	(1999) (Netherlands) (TV) (RTL4)
348	511	31	1	(1997) (Netherlands) (TV) (RTL4)
349	512	31	1	(1995) (Netherlands) (TV) (RTL4)
350	513	31	1	(1999) (Netherlands) (TV) (RTL4)
351	515	31	1	(1998) (Netherlands) (TV) (RTL4)
352	516	31	1	(1995) (Netherlands) (TV) (RTL4)
353	517	63	1	(1995) (Netherlands) (TV)
354	518	63	1	(1995) (Netherlands) (TV)
355	519	63	1	(1994) (Netherlands) (TV)
356	520	63	1	(1994) (Netherlands) (TV)
357	521	63	1	(1995) (Netherlands) (TV)
358	522	31	1	(1997) (Netherlands) (TV) (RTL4)
359	523	63	1	(1994) (Netherlands) (TV)
360	524	31	1	(1999) (Netherlands) (TV) (RTL4)
361	525	31	1	(1997) (Netherlands) (TV) (RTL4)
362	526	63	1	(1994) (Netherlands) (TV)
363	527	31	1	(1997) (Netherlands) (TV) (RTL4)
364	528	63	1	(1995) (Netherlands) (TV)
365	531	63	1	(1995) (Netherlands) (TV)
366	532	63	1	(1994) (Netherlands) (TV)
367	533	31	1	(1996) (Netherlands) (TV) (RTL4)
368	534	31	1	(1998) (Netherlands) (TV) (RTL4)
369	535	31	1	(1997) (Netherlands) (TV) (RTL4)
370	536	31	1	(1996) (Netherlands) (TV) (RTL4)
371	537	31	1	(1998) (Netherlands) (TV) (RTL4)
372	538	31	1	(1996) (Netherlands) (TV) (RTL4)
373	539	63	1	(1994) (Netherlands) (TV)
374	540	31	1	(1996) (Netherlands) (TV) (RTL4)
375	541	31	1	(2000) (Netherlands) (TV)
376	542	31	1	(1999) (Netherlands) (TV) (RTL4)
377	543	63	1	(1994) (Netherlands) (TV)
378	544	31	1	(1997) (Netherlands) (TV) (RTL4)
379	545	63	1	(1994) (Netherlands) (TV)
380	546	31	1	(1999) (Netherlands) (TV) (RTL4)
381	549	31	1	(1996) (Netherlands) (TV) (RTL4)
382	550	31	1	(1998) (Netherlands) (TV) (RTL4)
383	551	63	1	(1994) (Netherlands) (TV)
384	552	31	1	(1999) (Netherlands) (TV) (RTL4)
385	553	31	1	(2000) (Netherlands) (TV)
386	554	31	1	(1998) (Netherlands) (TV) (RTL4)
387	555	31	1	(1997) (Netherlands) (TV) (RTL4)
388	556	31	1	(2000) (Netherlands) (TV)
389	557	31	1	(2000) (Netherlands) (TV)
390	558	31	1	(1996) (Netherlands) (TV) (RTL4)
391	559	31	1	(1997) (Netherlands) (TV) (RTL4)
392	560	31	1	(1999) (Netherlands) (TV) (RTL4)
393	563	31	1	(1998) (Netherlands) (TV) (RTL4)
394	564	31	1	(1998) (Netherlands) (TV) (RTL4)
395	565	63	1	(1995) (Netherlands) (TV)
396	566	31	1	(1999) (Netherlands) (TV) (RTL4)
397	567	63	1	(1995) (Netherlands) (TV)
398	568	31	1	(2000) (Netherlands) (TV)
399	572	31	1	(1999) (Netherlands) (TV) (RTL4)
400	574	31	1	(1995) (Netherlands) (TV) (RTL4)
401	575	31	1	(1997) (Netherlands) (TV) (RTL4)
402	576	31	1	(1998) (Netherlands) (TV) (RTL4)
403	723	64	1	(2008) (Spain) (TV)
404	750	65	1	(2003) (Australia) (all media)
405	817	66	1	(2008) (worldwide) (all media)
406	819	67	1	(2010) (Germany) (TV)
407	820	68	1	(2006) (Germany) (TV)
408	826	64	1	(2004) (Spain) (TV)
409	901	69	1	(1971) (Spain) (TV)
410	853	70	1	(2007) (Germany) (TV)
411	860	71	1	(worldwide)
412	887	72	1	\N
413	903	73	1	(Denmark) (TV)
414	907	74	1	(2006) (Japan) (TV)
415	907	75	1	(2006) (USA) (DVD)
416	907	76	1	(2007) (USA) (DVD)
417	907	77	1	(2006) (Japan) (DVD)
418	907	78	1	(2006-2007) (USA) (TV)
419	907	79	1	(2006) (Japan) (TV)
420	907	80	1	(2006) (Japan) (TV)
421	907	81	1	(2006) (Japan) (TV)
422	907	82	1	(2006) (Japan) (TV)
423	908	74	1	(2006) (Japan) (TV)
424	908	78	1	(2006) (USA) (TV)
425	908	79	1	(2006) (Japan) (TV)
426	908	80	1	(2006) (Japan) (TV)
427	908	81	1	(2006) (Japan) (TV)
428	908	82	1	(2006) (Japan) (TV)
429	909	74	1	(2006) (Japan) (TV)
430	909	78	1	(2007) (USA) (TV)
431	910	74	1	(2006) (Japan) (TV)
432	910	78	1	(2006) (USA) (TV)
433	910	79	1	(2006) (Japan) (TV)
434	910	80	1	(2006) (Japan) (TV)
435	910	81	1	(2006) (Japan) (TV)
436	910	82	1	(2006) (Japan) (TV)
437	911	74	1	(2006) (Japan) (TV)
438	911	78	1	(2006) (USA) (TV)
439	911	79	1	(2006) (Japan) (TV)
440	911	80	1	(2006) (Japan) (TV)
441	911	81	1	(2006) (Japan) (TV)
442	911	82	1	(2006) (Japan) (TV)
443	912	74	1	(2006) (Japan) (TV)
444	912	78	1	(2007) (USA) (TV)
445	913	74	1	(2006) (Japan) (TV)
446	913	78	1	(2006) (USA) (TV)
447	913	79	1	(2006) (Japan) (TV)
448	913	80	1	(2006) (Japan) (TV)
449	913	81	1	(2006) (Japan) (TV)
450	913	82	1	(2006) (Japan) (TV)
451	914	74	1	(2006) (Japan) (TV)
452	914	78	1	(2007) (USA) (TV)
453	915	74	1	(2006) (Japan) (TV)
454	915	78	1	(2006) (USA) (TV)
455	915	79	1	(2006) (Japan) (TV)
456	915	80	1	(2006) (Japan) (TV)
457	915	81	1	(2006) (Japan) (TV)
458	915	82	1	(2006) (Japan) (TV)
459	916	74	1	(2006) (Japan) (TV)
460	916	78	1	(2006) (USA) (TV)
461	916	79	1	(2006) (Japan) (TV)
462	916	80	1	(2006) (Japan) (TV)
463	916	81	1	(2006) (Japan) (TV)
464	916	82	1	(2006) (Japan) (TV)
465	917	74	1	(2006) (Japan) (TV)
466	917	78	1	(2006) (USA) (TV)
467	917	79	1	(2006) (Japan) (TV)
468	917	80	1	(2006) (Japan) (TV)
469	917	81	1	(2006) (Japan) (TV)
470	917	82	1	(2006) (Japan) (TV)
471	918	74	1	(2006) (Japan) (TV)
472	918	78	1	(2006) (USA) (TV)
473	918	79	1	(2006) (Japan) (TV)
474	918	80	1	(2006) (Japan) (TV)
475	918	81	1	(2006) (Japan) (TV)
476	918	82	1	(2006) (Japan) (TV)
477	919	74	1	(2006) (Japan) (TV)
478	919	78	1	(2007) (USA) (TV)
479	920	74	1	(2006) (Japan) (TV)
480	920	78	1	(2007) (USA) (TV)
481	921	74	1	(2006) (Japan) (TV)
482	921	78	1	(2007) (USA) (TV)
483	922	74	1	(2006) (Japan) (TV)
484	922	78	1	(2007) (USA) (TV)
485	923	74	1	(2006) (Japan) (TV)
486	923	78	1	(2007) (USA) (TV)
487	924	74	1	(2006) (Japan) (TV)
488	924	78	1	(2007) (USA) (TV)
489	925	74	1	(2006) (Japan) (TV)
490	925	78	1	(2007) (USA) (TV)
491	926	74	1	(2006) (Japan) (TV)
492	926	78	1	(2006) (USA) (TV)
493	926	79	1	(2006) (Japan) (TV)
494	926	80	1	(2006) (Japan) (TV)
495	926	81	1	(2006) (Japan) (TV)
496	926	82	1	(2006) (Japan) (TV)
497	927	74	1	(2006) (Japan) (TV)
498	927	78	1	(2007) (USA) (TV)
499	928	74	1	(2006) (Japan) (TV)
500	928	78	1	(2006) (USA) (TV)
501	928	79	1	(2006) (Japan) (TV)
502	928	80	1	(2006) (Japan) (TV)
503	928	81	1	(2006) (Japan) (TV)
504	928	82	1	(2006) (Japan) (TV)
505	929	74	1	(2006) (Japan) (TV)
506	929	78	1	(2006) (USA) (TV)
507	929	79	1	(2006) (Japan) (TV)
508	929	80	1	(2006) (Japan) (TV)
509	929	81	1	(2006) (Japan) (TV)
510	929	82	1	(2006) (Japan) (TV)
511	930	74	1	(2006) (Japan) (TV)
512	930	78	1	(2006) (USA) (TV)
513	930	79	1	(2006) (Japan) (TV)
514	930	80	1	(2006) (Japan) (TV)
515	930	81	1	(2006) (Japan) (TV)
516	930	82	1	(2006) (Japan) (TV)
517	931	74	1	(2006) (Japan) (TV)
518	931	78	1	(2007) (USA) (TV)
519	932	74	1	(2006) (Japan) (TV)
520	932	78	1	(2007) (USA) (TV)
521	933	74	1	(2006) (Japan) (TV)
522	933	78	1	(2006) (USA) (TV)
523	933	79	1	(2006) (Japan) (TV)
524	933	80	1	(2006) (Japan) (TV)
525	933	81	1	(2006) (Japan) (TV)
526	933	82	1	(2006) (Japan) (TV)
527	934	83	1	(2004) (Spain) (DVD)
528	934	76	1	(2003) (USA)
529	934	77	1	(2002) (Japan)
530	934	78	1	(2003) (USA) (TV)
531	934	84	1	(2003) (Canada) (TV)
532	935	76	1	(2003) (USA) (all media)
533	935	77	1	(2002) (Japan) (all media)
534	935	78	1	(2003) (USA) (TV)
535	935	82	1	(2002) (Japan) (TV)
536	935	84	1	(2003) (Canada) (TV)
537	938	76	1	(2003) (USA) (all media)
538	938	77	1	(2002) (Japan) (all media)
539	938	78	1	(2003) (USA) (TV)
540	938	82	1	(2002) (Japan) (TV)
541	938	84	1	(2003) (Canada) (TV)
542	943	76	1	(2003) (USA) (all media)
543	943	77	1	(2002) (Japan) (all media)
544	943	78	1	(2003) (USA) (TV)
545	943	82	1	(2002) (Japan) (TV)
546	943	84	1	(2003) (Canada) (TV)
547	944	76	1	(2003) (USA) (all media)
548	944	77	1	(2002) (Japan) (all media)
549	944	78	1	(2003) (USA) (TV)
550	944	82	1	(2002) (Japan) (TV)
551	944	84	1	(2003) (Canada) (TV)
552	945	76	1	(2003) (USA) (all media)
553	945	77	1	(2002) (Japan) (all media)
554	945	78	1	(2003) (USA) (TV)
555	945	82	1	(2002) (Japan) (TV)
556	945	84	1	(2003) (Canada) (TV)
557	947	76	1	(2003) (USA) (all media)
558	947	77	1	(2002) (Japan) (all media)
559	947	78	1	(2003) (USA) (TV)
560	947	82	1	(2002) (Japan) (TV)
561	947	84	1	(2003) (Canada) (TV)
562	948	76	1	(2003) (USA) (all media)
563	948	77	1	(2002) (Japan) (all media)
564	948	78	1	(2003) (USA) (TV)
565	948	82	1	(2002) (Japan) (TV)
566	948	84	1	(2003) (Canada) (TV)
567	949	76	1	(2003) (USA) (all media)
568	949	77	1	(2002) (Japan) (all media)
569	951	76	1	(2003) (USA) (all media)
570	951	77	1	(2002) (Japan) (all media)
571	951	78	1	(2003) (USA) (TV)
572	951	82	1	(2002) (Japan) (TV)
573	951	84	1	(2003) (Canada) (TV)
574	953	76	1	(2003) (USA) (all media)
575	953	77	1	(2002) (Japan) (all media)
576	953	78	1	(2003) (USA) (TV)
577	953	82	1	(2002) (Japan) (TV)
578	953	84	1	(2003) (Canada) (TV)
579	954	76	1	(2003) (USA) (all media)
580	954	77	1	(2002) (Japan) (all media)
581	954	78	1	(2003) (USA) (TV)
582	954	82	1	(2002) (Japan) (TV)
583	954	84	1	(2003) (Canada) (TV)
584	956	83	1	(2004) (Spain) (DVD)
585	956	76	1	(2003) (USA) (all media)
586	956	77	1	(2002) (Japan) (all media)
587	956	78	1	(2003) (USA) (TV)
588	956	84	1	(2003) (Canada) (TV)
589	957	76	1	(2003) (USA) (all media)
590	957	77	1	(2002) (Japan) (all media)
591	957	78	1	(2003) (USA) (TV)
592	957	82	1	(2002) (Japan) (TV)
593	957	84	1	(2003) (Canada) (TV)
594	961	76	1	(2003) (USA) (all media)
595	961	77	1	(2002) (Japan) (all media)
596	962	76	1	(2003) (USA) (all media)
597	962	77	1	(2002) (Japan) (all media)
598	962	78	1	(2003) (USA) (TV)
599	962	82	1	(2002) (Japan) (TV)
600	962	84	1	(2003) (Canada) (TV)
601	963	85	1	(2004) (USA) (DVD)
602	963	82	1	(2003) (Japan) (TV)
603	976	86	1	(2010) (UK) (TV)
604	977	87	1	(2002) (UK) (DVD)
605	977	88	1	(2001) (UK) (TV)
606	978	69	1	(1979) (Spain) (TV)
607	979	89	1	(2007) (USA) (DVD)
608	979	90	1	((2006)) (Japan) (TV)
609	979	91	1	(2008) (USA) (DVD)
610	979	92	1	(2006) (Japan) (TV)
611	993	93	1	(1987) (UK) (TV)
612	996	94	1	\N
613	1114	95	1	(2009) (Japan) (TV)
614	1141	96	1	(2005) (worldwide) (all media)
615	1141	97	1	(2005) (Argentina) (TV)
616	1144	98	1	(2002) (Argentina) (TV)
617	1144	96	1	(worldwide) (all media)
618	1144	99	1	(2003) (Israel) (TV)
619	1146	100	1	(2012) (Greece) (TV)
620	1158	101	1	(2004) (USA) (TV)
621	1179	102	1	(2005) (Spain) (TV)
622	1181	103	1	(2012) (worldwide) (all media)
623	1182	104	1	(2005) (Germany) (TV)
624	1187	105	1	(2013) (USA) (TV)
625	1188	5	1	(2009) (Canada) (TV)
626	1188	106	1	(2010) (USA) (TV)
627	1335	16	1	(2006) (UK) (TV)
628	1370	27	1	(2010) (UK) (TV)
629	1147	107	1	(2007) (Japan) (TV)
630	1148	108	1	(2006) (Spain) (TV)
631	1149	109	1	(2007) (France) (TV)
632	1149	110	1	(2007) (France) (TV)
633	1157	111	1	(2007-2008) (Italy) (TV)
634	1352	112	1	(2006) (Netherlands) (TV)
635	1352	113	1	(2007) (Netherlands) (TV)
636	1369	92	1	(1980) (Japan) (TV)
637	1379	114	1	(2008) (Japan) (TV)
638	1389	64	1	(2008) (Spain) (TV)
639	1396	73	1	(1969) (Denmark) (TV)
640	1400	115	1	(2006) (Ireland) (TV)
641	1401	116	1	(2012) (Netherlands) (TV)
642	1401	63	1	(2012) (Netherlands) (TV)
643	1417	7	1	(2007-) (Australia) (TV)
644	1465	19	1	(2006) (worldwide) (TV)
645	1469	19	1	(2007) (USA) (TV)
646	1470	19	1	(2007) (USA) (TV)
647	1476	19	1	(2006) (USA) (TV)
648	1478	19	1	(2006) (USA) (TV)
649	1479	19	1	(2006) (USA) (TV)
650	1483	19	1	(2006) (USA) (TV)
651	1485	19	1	(2006) (USA) (TV)
652	1489	19	1	(2007) (USA) (TV)
653	1493	19	1	(2007) (USA) (TV)
654	1494	117	1	(2010) (USA) (TV)
655	1535	118	1	(2003) (South Korea) (TV)
656	1536	119	1	(1981-1982) (Portugal) (TV)
657	1547	19	1	(1961-1962) (USA) (TV)
658	1548	19	1	(1962) (USA) (TV)
659	1549	119	1	(1985) (Portugal) (TV)
660	1550	97	1	(Argentina)
661	1551	120	1	(2007) (worldwide) (TV)
662	1557	120	1	(2007) (worldwide) (TV)
663	1561	120	1	(2007) (worldwide) (TV)
664	1564	120	1	(2007) (worldwide) (TV)
665	1565	121	1	(2009) (Germany) (TV)
666	1570	121	1	(2008) (Germany) (TV)
667	1576	122	1	(2007-) (Hungary) (TV) (repeats)
668	1576	123	1	(2012) (UK) (TV)
669	1576	124	1	(2006-2009) (Japan) (TV)
670	1576	125	1	(USA)
671	1576	126	1	\N
672	1576	31	1	(2008) (Netherlands) (TV) (RTL8)
673	1576	46	1	(2005-2007) (Hungary) (TV) (original airing)
674	1576	53	1	(2008-) (Estonia) (TV)
675	1577	127	1	(2005) (Germany) (TV)
676	1577	125	1	(2003) (USA) (TV)
677	1577	46	1	(2005) (Hungary) (TV)
678	1578	127	1	(2006) (Germany) (TV)
679	1578	125	1	(2005) (USA) (TV)
680	1578	46	1	(2007) (Hungary) (TV)
681	1579	127	1	(2006) (Germany) (TV)
682	1579	125	1	(2005) (USA) (TV)
683	1579	46	1	(2007) (Hungary) (TV)
684	1580	127	1	(2006) (Germany) (TV)
685	1580	125	1	(2005) (USA) (TV)
686	1580	46	1	(2007) (Hungary) (TV)
687	1581	127	1	(2006) (Germany) (TV)
688	1581	125	1	(2005) (USA) (TV)
689	1581	46	1	(2007) (Hungary) (TV)
690	1582	127	1	(2006) (Germany) (TV)
691	1582	125	1	(2005) (USA) (TV)
692	1582	46	1	(2007) (Hungary) (TV)
693	1583	127	1	(2005) (Germany) (TV)
694	1583	125	1	(2003) (USA) (TV)
695	1583	46	1	(2005) (Hungary) (TV)
696	1584	127	1	(2005) (Germany) (TV)
697	1584	125	1	(2004) (USA) (TV)
698	1584	46	1	(2006) (Hungary) (TV)
699	1585	127	1	(2006) (Germany) (TV)
700	1585	125	1	(2005) (USA) (TV)
701	1585	46	1	(2007) (Hungary) (TV)
702	1586	127	1	(2005) (Germany) (TV)
703	1586	125	1	(2004) (USA) (TV)
704	1586	46	1	(2006) (Hungary) (TV)
705	1587	127	1	(2005) (Germany) (TV)
706	1587	125	1	(2003) (USA) (TV)
707	1587	46	1	(2005) (Hungary) (TV)
708	1588	127	1	(2005) (Germany) (TV)
709	1588	125	1	(2004) (USA) (TV)
710	1588	46	1	(2005) (Hungary) (TV)
711	1589	127	1	(2005) (Germany) (TV)
712	1589	125	1	(2004) (USA) (TV)
713	1589	46	1	(2006) (Hungary) (TV)
714	1590	127	1	(2006) (Germany) (TV)
715	1590	125	1	(2006) (USA) (TV)
716	1590	46	1	(2007) (Hungary) (TV)
717	1591	127	1	(2006) (Germany) (TV)
718	1591	125	1	(2006) (USA) (TV)
719	1591	46	1	(2007) (Hungary) (TV)
720	1592	127	1	(2005) (Germany) (TV)
721	1592	125	1	(2003) (USA) (TV)
722	1592	46	1	(2005) (Hungary) (TV)
723	1593	127	1	(2006) (Germany) (TV)
724	1593	125	1	(2005) (USA) (TV)
725	1593	46	1	(2007) (Hungary) (TV)
726	1593	115	1	(2006) (Ireland) (TV)
727	1594	127	1	(2006) (Germany) (TV)
728	1594	125	1	(2005) (USA) (TV)
729	1594	46	1	(2007) (Hungary) (TV)
730	1595	127	1	(2005) (Germany) (TV)
731	1595	125	1	(2003) (USA) (TV)
732	1595	31	1	(2008) (Netherlands) (TV) (RTL8)
733	1595	46	1	(2005) (Hungary) (TV)
734	1596	127	1	(2005) (Germany) (TV)
735	1596	125	1	(2004) (USA) (TV)
736	1596	46	1	(2006) (Hungary) (TV)
737	1597	127	1	(2005) (Germany) (TV)
738	1597	125	1	(2003) (USA) (TV)
739	1597	46	1	(2005) (Hungary) (TV)
740	1598	127	1	(2005) (Germany) (TV)
741	1598	125	1	(2005) (USA) (TV)
742	1598	46	1	(2006) (Hungary) (TV)
743	1599	127	1	(2005) (Germany) (TV)
744	1599	125	1	(2004) (USA) (TV)
745	1599	46	1	(2006) (Hungary) (TV)
746	1600	127	1	(2006) (Germany) (TV)
747	1600	125	1	(2005) (USA) (TV)
748	1600	46	1	(2007) (Hungary) (TV)
749	1601	127	1	(2005) (Germany) (TV)
750	1601	125	1	(2004) (USA) (TV)
751	1601	46	1	(2006) (Hungary) (TV)
752	1602	127	1	(2006) (Germany) (TV)
753	1602	125	1	(2005) (USA) (TV)
754	1602	46	1	(2007) (Hungary) (TV)
755	1603	127	1	(2005) (Germany) (TV)
756	1603	125	1	(2004) (USA) (TV)
757	1603	46	1	(2005) (Hungary) (TV)
758	1604	127	1	(2005) (Germany) (TV)
759	1604	125	1	(2003) (USA) (TV)
760	1604	46	1	(2005) (Hungary) (TV)
761	1605	127	1	(2005) (Germany) (TV)
762	1605	125	1	(2004) (USA) (TV)
763	1605	46	1	(2006) (Hungary) (TV)
764	1606	127	1	(2005) (Germany) (TV)
765	1606	125	1	(2003) (USA) (TV)
766	1606	46	1	(2005) (Hungary) (TV)
767	1607	127	1	(2006) (Germany) (TV)
768	1607	125	1	(2005) (USA) (TV)
769	1607	46	1	(2007) (Hungary) (TV)
770	1607	115	1	(2006) (Ireland) (TV)
771	1608	127	1	(2005) (Germany) (TV)
772	1608	125	1	(2004) (USA) (TV)
773	1608	46	1	(2006) (Hungary) (TV)
774	1609	127	1	(2006) (Germany) (TV)
775	1609	125	1	(2005) (USA) (TV)
776	1609	46	1	(2006) (Hungary) (TV)
777	1610	127	1	(2006) (Germany) (TV)
778	1610	125	1	(2005) (USA) (TV)
779	1610	46	1	(2007) (Hungary) (TV)
780	1610	115	1	(2006) (Ireland) (TV)
781	1611	127	1	(2005) (Germany) (TV)
782	1611	125	1	(2005) (USA) (TV)
783	1611	46	1	(2006) (Hungary) (TV)
784	1612	127	1	(2005) (Germany) (TV)
785	1612	125	1	(2003) (USA) (TV)
786	1612	46	1	(2005) (Hungary) (TV)
787	1613	127	1	(2005) (Germany) (TV)
788	1613	125	1	(2004) (USA) (TV)
789	1613	46	1	(2006) (Hungary) (TV)
790	1614	127	1	(2005) (Germany) (TV)
791	1614	125	1	(2004) (USA) (TV)
792	1614	46	1	(2006) (Hungary) (TV)
793	1615	127	1	(2005) (Germany) (TV)
794	1615	125	1	(2004) (USA) (TV)
795	1615	46	1	(2006) (Hungary) (TV)
796	1616	127	1	(2005) (Germany) (TV)
797	1616	125	1	(2004) (USA) (TV)
798	1616	46	1	(2006) (Hungary) (TV)
799	1617	127	1	(2006) (Germany) (TV)
800	1617	125	1	(2005) (USA) (TV)
801	1617	46	1	(2007) (Hungary) (TV)
802	1618	127	1	(2006) (Germany) (TV)
803	1618	125	1	(2006) (USA) (TV)
804	1618	46	1	(2007) (Hungary) (TV)
805	1618	115	1	(2006) (Ireland) (TV)
806	1619	127	1	(2006) (Germany) (TV)
807	1619	125	1	(2005) (USA) (TV)
808	1619	46	1	(2007) (Hungary) (TV)
809	1620	127	1	(2005) (Germany) (TV)
810	1620	125	1	(2004) (USA) (TV)
811	1620	46	1	(2005) (Hungary) (TV)
812	1621	127	1	(2005) (Germany) (TV)
813	1621	125	1	(2003) (USA) (TV)
814	1621	46	1	(2005) (Hungary) (TV)
815	1622	127	1	(2005) (Germany) (TV)
816	1622	125	1	(2003) (USA) (TV)
817	1622	46	1	(2005) (Hungary) (TV)
818	1623	127	1	(2005) (Germany) (TV)
819	1623	125	1	(2003) (USA) (TV)
820	1623	46	1	(2005) (Hungary) (TV)
821	1624	127	1	(2005) (Germany) (TV)
822	1624	125	1	(2003) (USA) (TV)
823	1624	46	1	(2005) (Hungary) (TV)
824	1625	127	1	(2005) (Germany) (TV)
825	1625	125	1	(2004) (USA) (TV)
826	1625	46	1	(2006) (Hungary) (TV)
827	1626	127	1	(2005) (Germany) (TV)
828	1626	125	1	(2004) (USA) (TV)
829	1626	46	1	(2006) (Hungary) (TV)
830	1627	127	1	(2006) (Germany) (TV)
831	1627	125	1	(2005) (USA) (TV)
832	1627	46	1	(2007) (Hungary) (TV)
833	1627	115	1	(2006) (Ireland) (TV)
834	1628	127	1	(2006) (Germany) (TV)
835	1628	125	1	(2005) (USA) (TV)
836	1628	46	1	(2007) (Hungary) (TV)
837	1629	127	1	(2005) (Germany) (TV)
838	1629	125	1	(2003) (USA) (TV)
839	1629	46	1	(2005) (Hungary) (TV)
840	1630	127	1	(2005) (Germany) (TV)
841	1630	125	1	(2005) (USA) (TV)
842	1630	46	1	(2006) (Hungary) (TV)
843	1631	127	1	(2005) (Germany) (TV)
844	1631	125	1	(2003) (USA) (TV)
845	1631	46	1	(2005) (Hungary) (TV)
846	1632	128	1	(2012) (Denmark) (TV)
847	1636	129	1	(2005) (Germany) (TV)
848	1636	69	1	(1994) (Spain) (TV)
849	1637	130	1	(2011) (USA) (TV)
850	1643	130	1	(2012) (USA) (TV)
851	1656	131	1	(2008) (worldwide) (all media)
852	1667	132	1	(2007) (USA) (TV)
853	1668	27	1	(2008) (UK) (all media)
854	1668	133	1	(2009) (Japan) (TV)
855	1677	134	1	(2003) (worldwide) (TV)
856	1757	135	1	(2008) (USA) (TV)
857	1760	36	1	(2006) (Canada) (TV)
858	1760	46	1	(2009-) (Hungary) (TV)
859	1760	52	1	(2008) (USA) (DVD) (seasons 1 and 2)
860	1760	136	1	(2006) (USA) (TV)
861	1761	46	1	(2010) (Hungary) (TV)
862	1762	46	1	(2009) (Hungary) (TV)
863	1763	46	1	(2012) (Hungary) (TV)
864	1764	46	1	(2010) (Hungary) (TV)
865	1765	46	1	(2012) (Hungary) (TV)
866	1766	46	1	(2010) (Hungary) (TV)
867	1767	46	1	(2010) (Hungary) (TV)
868	1768	46	1	(2009) (Hungary) (TV)
869	1769	46	1	(2010) (Hungary) (TV)
870	1770	46	1	(2012) (Hungary) (TV)
871	1771	46	1	(2012) (Hungary) (TV)
872	1772	46	1	(2012) (Hungary) (TV)
873	1773	46	1	(2010) (Hungary) (TV)
874	1774	46	1	(2012) (Hungary) (TV)
875	1775	46	1	(2009) (Hungary) (TV)
876	1776	46	1	(2009) (Hungary) (TV)
877	1777	46	1	(2010) (Hungary) (TV)
878	1778	46	1	(2012) (Hungary) (TV)
879	1779	46	1	(2010) (Hungary) (TV)
880	1780	46	1	(2012) (Hungary) (TV)
881	1781	46	1	(2009) (Hungary) (TV)
882	1783	137	1	(2009) (Germany) (TV)
883	1784	130	1	(2010) (USA) (TV)
884	1851	57	1	(2013) (USA) (TV) (cable)
885	1852	138	1	(2009) (UK) (TV)
886	1853	138	1	(2009) (UK) (TV)
887	1857	138	1	(2009) (UK) (all media)
888	1858	138	1	(2009) (UK) (TV)
889	1865	139	1	(2011) (UK) (TV)
890	2006	140	1	\N
891	2016	141	1	(1993) (USA) (TV)
892	2017	142	1	(2010) (USA) (TV)
893	2018	57	1	(2004) (USA) (TV)
894	2019	57	1	(2004) (USA) (TV)
895	2020	57	1	(2004) (USA) (TV)
896	2021	57	1	(2004) (USA) (TV)
897	2025	143	1	(2009) (USA) (TV)
898	2025	122	1	(2011) (Hungary) (TV) (episodes 11 - 20)
899	2025	144	1	(2010) (Hungary) (TV) (episodes 1 - 10)
900	2025	145	1	(2011) (USA) (DVD) (Season One, Volume 2)
901	2025	146	1	(2011-2012) (Germany) (TV)
902	2026	122	1	(2011) (Hungary) (TV)
903	2026	145	1	(2011) (USA) (DVD)
904	2027	122	1	(2011) (Hungary) (TV)
905	2027	145	1	(2011) (USA) (DVD)
906	2028	122	1	(2011) (Hungary) (TV)
907	2028	145	1	(2011) (USA) (DVD)
908	2029	144	1	(2010) (Hungary) (TV)
909	2031	144	1	(2010) (Hungary) (TV)
910	2030	144	1	(2010) (Hungary) (TV)
911	2032	144	1	(2010) (Hungary) (TV)
912	2033	122	1	(2011) (Hungary) (TV)
913	2033	145	1	(2011) (USA) (DVD)
914	2034	144	1	(2010) (Hungary) (TV)
915	2035	122	1	(2011) (Hungary) (TV)
916	2035	145	1	(2011) (USA) (DVD)
917	2036	144	1	(2010) (Hungary) (TV)
918	2037	122	1	(2011) (Hungary) (TV)
919	2037	145	1	(2011) (USA) (DVD)
920	2038	144	1	(2010) (Hungary) (TV)
921	2039	122	1	(2011) (Hungary) (TV)
922	2039	145	1	(2011) (USA) (DVD)
923	2040	144	1	(2010) (Hungary) (TV)
924	2041	122	1	(2011) (Hungary) (TV)
925	2041	145	1	(2011) (USA) (DVD)
926	2042	122	1	(2011) (Hungary) (TV)
927	2042	145	1	(2011) (USA) (DVD)
928	2043	122	1	(2011) (Hungary) (TV)
929	2043	145	1	(2011) (USA) (DVD)
930	2044	144	1	(2010) (Hungary) (TV)
931	2045	144	1	(2010) (Hungary) (TV)
932	2046	147	1	(2013) (USA) (TV) (cable)
933	2048	148	1	(2002) (UK) (TV)
934	2050	27	1	(2006) (UK) (TV)
935	2054	27	1	(2006) (UK) (TV)
936	2055	149	1	(2012) (USA) (TV)
937	2068	130	1	(2006) (USA) (TV)
938	2075	21	1	(2009) (Australia) (TV)
939	2079	150	1	(2009-) (Hungary) (TV) (repeats)
940	2071	151	1	(2007) (worldwide) (TV) (Broadcaster)
941	2071	152	1	(2007) (worldwide) (TV)
942	2071	153	1	(2007) (UK) (TV)
943	1649	64	1	(2008) (Spain) (TV)
944	1759	73	1	(1952-1953) (Denmark) (TV)
945	1785	154	1	(2007) (Finland) (TV)
946	1796	154	1	(2008) (Finland) (TV)
947	1807	154	1	(2011) (Finland) (TV)
948	1818	154	1	(2009) (Finland) (TV)
949	1832	69	1	(2005) (Spain) (TV)
950	1850	155	1	(2002) (Greece) (TV)
951	1850	156	1	(2003) (Greece) (TV)
952	1897	20	1	(2010) (worldwide) (TV)
953	2069	154	1	(2009-2010) (Finland) (TV)
954	2070	157	1	(1990) (Denmark) (TV)
955	2255	158	1	(2010) (Switzerland) (TV)
956	2266	159	1	(2010) (USA) (all media)
957	2281	160	1	(2003) (USA) (TV) (original airing)
958	2281	161	1	(2003) (worldwide) (TV)
959	2281	162	1	\N
960	2281	163	1	(2004) (UK) (TV)
961	2281	164	1	(2006) (Hungary) (TV)
962	2281	8	1	(2007) (Netherlands) (TV)
963	2282	160	1	(2003) (USA) (TV)
964	2282	127	1	(2009) (Germany) (TV)
965	2282	164	1	(2006) (Hungary) (TV)
966	2283	160	1	(2003) (USA) (TV)
967	2283	127	1	(2009) (Germany) (TV)
968	2283	164	1	(2006) (Hungary) (TV)
969	2284	160	1	(2003) (USA) (TV)
970	2284	127	1	(2009) (Germany) (TV)
971	2284	164	1	(2006) (Hungary) (TV)
972	2285	160	1	(2003) (USA) (TV)
973	2285	127	1	(2009) (Germany) (TV)
974	2285	164	1	(2006) (Hungary) (TV)
975	2286	160	1	(2004) (USA) (TV)
976	2286	127	1	(2010) (Germany) (TV)
977	2286	164	1	(2006) (Hungary) (TV)
978	2287	160	1	(2003) (USA) (TV)
979	2287	127	1	(2010) (Germany) (TV)
980	2287	164	1	(2006) (Hungary) (TV)
981	2288	160	1	(2003) (USA) (TV)
982	2288	127	1	(2009) (Germany) (TV)
983	2288	164	1	(2006) (Hungary) (TV)
984	2289	160	1	(2004) (USA) (TV)
985	2289	127	1	(2010) (Germany) (TV)
986	2289	164	1	(2006) (Hungary) (TV)
987	2290	160	1	(2003) (USA) (TV)
988	2290	127	1	(2010) (Germany) (TV)
989	2290	164	1	(2006) (Hungary) (TV)
990	2291	160	1	(2003) (USA) (TV)
991	2291	127	1	(2010) (Germany) (TV)
992	2291	164	1	(2006) (Hungary) (TV)
993	2292	160	1	(2004) (USA) (TV)
994	2292	127	1	(2010) (Germany) (TV)
995	2292	164	1	(2006) (Hungary) (TV)
996	2293	160	1	(2003) (USA) (TV)
997	2293	127	1	(2010) (Germany) (TV)
998	2293	164	1	(2006) (Hungary) (TV)
999	2294	160	1	(2003) (USA) (TV)
1000	2294	127	1	(2010) (Germany) (TV)
\.


--
-- Data for Name: movie_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.movie_info (id, movie_id, info_type_id, info, note) FROM stdin;
7266123	921521	4	English	\N
7266124	921522	4	English	\N
7266125	921523	4	English	\N
7266126	921524	4	English	\N
7266127	921525	4	English	\N
7266128	921526	4	English	\N
7266129	921527	4	English	\N
7266130	921528	4	English	\N
7266131	921529	4	English	\N
7266132	921530	4	English	\N
7266133	921531	4	English	\N
7266134	921532	4	English	\N
7266135	921533	4	English	\N
7266136	921534	4	English	\N
7266137	921535	4	English	\N
7266138	921536	4	English	\N
7266139	921537	4	English	\N
7266140	921538	4	English	\N
7266141	921539	4	English	\N
7266142	921540	4	English	\N
7266143	921541	4	English	\N
7266144	921542	4	English	\N
7266145	921543	4	English	\N
7266146	921544	4	English	\N
7266147	921545	4	English	\N
7266148	921546	4	English	\N
7266149	921547	4	English	\N
7266150	921548	4	English	\N
7266151	921549	4	English	\N
7266152	921550	4	English	\N
7266153	921551	4	English	\N
7266154	921552	4	English	\N
7266155	921553	4	English	\N
7266156	921554	4	English	\N
7266157	921555	4	English	\N
7266158	921556	4	English	\N
7266159	921557	4	English	\N
7266160	921558	4	English	\N
7266161	921559	4	English	\N
7266162	921560	4	English	\N
7266163	921561	4	English	\N
7266164	921562	4	English	\N
7266165	921563	4	English	\N
7266166	921564	4	English	\N
7266167	921565	4	English	\N
7266168	921566	4	English	\N
7266169	921567	4	English	\N
7266170	921568	4	English	\N
7266171	921569	4	English	\N
7266172	921570	4	English	\N
7266173	921571	4	English	\N
7266174	921572	4	English	\N
7266175	921573	4	English	\N
7266176	921574	4	English	\N
7266177	921575	4	English	\N
7266178	921576	4	English	\N
7266179	921577	4	English	\N
7266180	921578	4	English	\N
7266181	921579	4	English	\N
7266182	921580	4	English	\N
7266183	921581	4	English	\N
7266184	921582	4	English	\N
7266185	921583	4	English	\N
7266186	921584	4	English	\N
7266187	921585	4	English	\N
7266188	921586	4	English	\N
7266189	921587	4	English	\N
7266190	921588	4	English	\N
7266191	921589	4	English	\N
7266192	921590	4	English	\N
7266193	921591	4	English	\N
7266194	921592	4	English	\N
7266195	921593	4	English	\N
7266196	921594	4	English	\N
7266197	921595	4	English	\N
7266198	921596	4	English	\N
7266199	921597	4	English	\N
7266200	921598	4	English	\N
7266201	921599	4	English	\N
7266202	921600	4	English	\N
7266203	921601	4	English	\N
7266204	921602	4	English	\N
7266205	921603	4	English	\N
7266206	921604	4	English	\N
7266207	921605	4	English	\N
7266208	921606	4	English	\N
7266209	921607	4	English	\N
7266210	921608	4	English	\N
7266211	921609	4	English	\N
7266212	921610	4	English	\N
7266213	921611	4	English	\N
7266214	921612	4	English	\N
7266215	921613	4	English	\N
7266216	921614	4	English	\N
7266217	921615	4	English	\N
7266218	921616	4	English	\N
7266219	921617	4	English	\N
7266220	921618	4	English	\N
7266221	921619	4	English	\N
7266222	921620	4	English	\N
7266223	921621	4	English	\N
7266224	921622	4	English	\N
7266225	921623	4	English	\N
7266226	921624	4	English	\N
7266227	921625	4	English	\N
7266228	921626	4	English	\N
7266229	921627	4	English	\N
7266230	921628	4	English	\N
7266231	921629	4	English	\N
7266232	921630	4	English	\N
7266233	921631	4	English	\N
7266234	921632	4	English	\N
7266235	921633	4	English	\N
7266236	921634	4	English	\N
7266237	921635	4	English	\N
7266238	921636	4	English	\N
7266239	921637	4	English	\N
7266240	921638	4	English	\N
7266241	921639	4	English	\N
7266242	921640	4	English	\N
7266243	921641	4	English	\N
7266244	921642	4	English	\N
7266245	921643	4	English	\N
7266246	921644	4	English	\N
7266247	921645	4	English	\N
7266248	921646	4	English	\N
7266249	921647	4	English	\N
7266250	921648	4	English	\N
7266251	921649	4	English	\N
7266252	921650	4	English	\N
7266253	921651	4	English	\N
7266254	921652	4	English	\N
7266255	921653	4	English	\N
7266256	921654	4	English	\N
7266257	921655	4	English	\N
7266258	921656	4	English	\N
7266259	921657	4	English	\N
7266260	921658	4	English	\N
7266261	921659	4	English	\N
7266262	921660	4	English	\N
7266263	921661	4	English	\N
7266264	921662	4	English	\N
7266265	921663	4	English	\N
7266266	921664	4	English	\N
7266267	921665	4	English	\N
7266268	921666	4	English	\N
7266269	921667	4	English	\N
7266270	921668	4	English	\N
7266271	921669	4	English	\N
7266272	921670	4	English	\N
7266273	921671	4	English	\N
7266274	921672	4	English	\N
7266275	921673	4	English	\N
7266276	921674	4	English	\N
7266277	921675	4	English	\N
7266278	921676	4	English	\N
7266279	921677	4	English	\N
7266280	921678	4	English	\N
7266281	921679	4	English	\N
7266282	921680	4	English	\N
7266283	921681	4	English	\N
7266284	921682	4	English	\N
7266285	921683	4	English	\N
7266286	921684	4	English	\N
7266287	921685	4	English	\N
7266288	921686	4	English	\N
7266289	921687	4	English	\N
7266290	921688	4	English	\N
7266291	921689	4	English	\N
7266292	921690	4	English	\N
7266293	921691	4	English	\N
7266294	921692	4	English	\N
7266295	921693	4	English	\N
7266296	921694	4	English	\N
7266297	921695	4	English	\N
7266298	921696	4	English	\N
7266299	921697	4	English	\N
7266300	921698	4	English	\N
7266301	921699	4	English	\N
7266302	921700	4	English	\N
7266303	921701	4	English	\N
7266304	921702	4	English	\N
7266305	921703	4	English	\N
7266306	921704	4	English	\N
7266307	921705	4	English	\N
7266308	921706	4	English	\N
7266309	921707	4	English	\N
7266310	921708	4	English	\N
7266311	921709	4	English	\N
7266312	921710	4	English	\N
7266313	921711	4	English	\N
7266314	921712	4	English	\N
7266315	921713	4	English	\N
7266316	921714	4	English	\N
7266317	921715	4	English	\N
7266318	921716	4	English	\N
7266319	921717	4	English	\N
7266320	921718	4	English	\N
7266321	921719	4	English	\N
7266322	921720	4	English	\N
7266323	921721	4	English	\N
7266324	921722	4	English	\N
7266325	921723	4	English	\N
7266326	921724	4	English	\N
7266327	921725	4	English	\N
7266328	921726	4	English	\N
7266329	921727	4	English	\N
7266330	921728	4	English	\N
7266331	921729	4	English	\N
7266332	921730	4	English	\N
7266333	921731	4	English	\N
7266334	921732	4	English	\N
7266335	921733	4	English	\N
7266336	921734	4	English	\N
7266337	921735	4	English	\N
7266338	921736	4	English	\N
7266339	921737	4	English	\N
7266340	921738	4	English	\N
7266341	921739	4	English	\N
7266342	921740	4	English	\N
7266343	921741	4	English	\N
7266344	921742	4	English	\N
7266345	921743	4	English	\N
7266346	921744	4	English	\N
7266347	921745	4	English	\N
7266348	921746	4	English	\N
7266349	921747	4	English	\N
7266350	921748	4	English	\N
7266351	921749	4	English	\N
7266352	921750	4	English	\N
7266353	921751	4	English	\N
7266354	921752	4	English	\N
7266355	921753	4	English	\N
7266356	921754	4	English	\N
7266357	921755	4	English	\N
7266358	921756	4	English	\N
7266359	921757	4	English	\N
7266360	921758	4	English	\N
7266361	921759	4	English	\N
7266362	921760	4	English	\N
7266363	921761	4	English	\N
7266364	921762	4	English	\N
7266365	921763	4	English	\N
7266366	921764	4	English	\N
7266367	921765	4	English	\N
7266368	921766	4	English	\N
7266369	921767	4	English	\N
7266370	921768	4	English	\N
7266371	921769	4	English	\N
7266372	921770	4	English	\N
7266373	921771	4	English	\N
7266374	921772	4	English	\N
7266375	921773	4	English	\N
7266376	921774	4	English	\N
7266377	921775	4	English	\N
7266378	921776	4	English	\N
7266379	921777	4	English	\N
7266380	921778	4	English	\N
7266381	921779	4	English	\N
7266382	921780	4	English	\N
7266383	921781	4	English	\N
7266384	921782	4	English	\N
7266385	921783	4	English	\N
7266386	921784	4	English	\N
7266387	921785	4	English	\N
7266388	921786	4	English	\N
7266389	921787	4	English	\N
7266390	921788	4	English	\N
7266391	921789	4	English	\N
7266392	921790	4	English	\N
7266393	921791	4	English	\N
7266394	921792	4	English	\N
7266395	921793	4	English	\N
7266396	921794	4	English	\N
7266397	921795	4	English	\N
7266398	921796	4	English	\N
7266399	921797	4	English	\N
7266400	921798	4	English	\N
7266401	921799	4	English	\N
7266402	921800	4	English	\N
7266403	921801	4	English	\N
7266404	921802	4	English	\N
7266405	921803	4	English	\N
7266406	921804	4	English	\N
7266407	921805	4	English	\N
7266408	921806	4	English	\N
7266409	921807	4	English	\N
7266410	921808	4	English	\N
7266411	921809	4	English	\N
7266412	921810	4	English	\N
7266413	921811	4	English	\N
7266414	921812	4	English	\N
7266415	921813	4	English	\N
7266416	921814	4	English	\N
7266417	921815	4	English	\N
7266418	921816	4	English	\N
7266419	921817	4	English	\N
7266420	921818	4	English	\N
7266421	921819	4	English	\N
7266422	921820	4	English	\N
7266423	921821	4	English	\N
7266424	921822	4	English	\N
7266425	921823	4	English	\N
7266426	921824	4	English	\N
7266427	921825	4	English	\N
7266428	921826	4	English	\N
7266429	921827	4	English	\N
7266430	921828	4	English	\N
7266431	921829	4	English	\N
7266432	921830	4	English	\N
7266433	921831	4	English	\N
7266434	921832	4	English	\N
7266435	921833	4	English	\N
7266436	921834	4	English	\N
7266437	921835	4	English	\N
7266438	921836	4	English	\N
7266439	921837	4	English	\N
7266440	921838	4	English	\N
7266441	921839	4	English	\N
7266442	921840	4	English	\N
7266443	921841	4	English	\N
7266444	921842	4	English	\N
7266445	921843	4	English	\N
7266446	921844	4	English	\N
7266447	921845	4	English	\N
7266448	921846	4	English	\N
7266449	921847	4	English	\N
7266450	921848	4	English	\N
7266451	921849	4	English	\N
7266452	921850	4	English	\N
7266453	921851	4	English	\N
7266454	921852	4	English	\N
7266455	921853	4	English	\N
7266456	921854	4	English	\N
7266457	921855	4	English	\N
7266458	921856	4	English	\N
7266459	921857	4	English	\N
7266460	921858	4	English	\N
7266461	921859	4	English	\N
7266462	921860	4	English	\N
7266463	921861	4	English	\N
7266464	921862	4	English	\N
7266465	921863	4	English	\N
7266466	921864	4	English	\N
7266467	921865	4	English	\N
7266468	921866	4	English	\N
7266469	921867	4	English	\N
7266470	921868	4	English	\N
7266471	921869	4	English	\N
7266472	921870	4	English	\N
7266473	921871	4	English	\N
7266474	921872	4	English	\N
7266475	921873	4	English	\N
7266476	921874	4	English	\N
7266477	921875	4	English	\N
7266478	921876	4	English	\N
7266479	921877	4	English	\N
7266480	921878	4	English	\N
7266481	921879	4	English	\N
7266482	921880	4	English	\N
7266483	921881	4	English	\N
7266484	921882	4	English	\N
7266485	921883	4	English	\N
7266486	921884	4	English	\N
7266487	921885	4	English	\N
7266488	921886	4	English	\N
7266489	921887	4	English	\N
7266490	921888	4	English	\N
7266491	921889	4	English	\N
7266492	921890	4	English	\N
7266493	921891	4	English	\N
7266494	921892	4	English	\N
7266495	921893	4	English	\N
7266496	921894	4	English	\N
7266497	921895	4	English	\N
7266498	921896	4	English	\N
7266499	921897	4	English	\N
7266500	921898	4	English	\N
7266501	921899	4	English	\N
7266502	921900	4	English	\N
7266503	921901	4	English	\N
7266504	921902	4	English	\N
7266505	921903	4	English	\N
7266506	921904	4	English	\N
7266507	921905	4	English	\N
7266508	921906	4	English	\N
7266509	921907	4	English	\N
7266510	921908	4	English	\N
7266511	921909	4	English	\N
7266512	921910	4	English	\N
7266513	921911	4	English	\N
7266514	921912	4	English	\N
7266515	921913	4	English	\N
7266516	921914	4	English	\N
7266517	921915	4	English	\N
7266518	921916	4	English	\N
7266519	921917	4	English	\N
7266520	921918	4	English	\N
7266521	921919	4	English	\N
7266522	921920	4	English	\N
7266523	921921	4	English	\N
7266524	921922	4	English	\N
7266525	921923	4	English	\N
7266526	921924	4	English	\N
7266527	921925	4	English	\N
7266528	921926	4	English	\N
7266529	921927	4	English	\N
7266530	921928	4	English	\N
7266531	921929	4	English	\N
7266532	921930	4	English	\N
7266533	921931	4	English	\N
7266534	921932	4	English	\N
7266535	921933	4	English	\N
7266536	921934	4	English	\N
7266537	921935	4	English	\N
7266538	921936	4	English	\N
7266539	921937	4	English	\N
7266540	921938	4	English	\N
7266541	921939	4	English	\N
7266542	921940	4	English	\N
7266543	921941	4	English	\N
7266544	921942	4	English	\N
7266545	921943	4	English	\N
7266546	921944	4	English	\N
7266547	921945	4	English	\N
7266548	921946	4	English	\N
7266549	921947	4	English	\N
7266550	921948	4	English	\N
7266551	921949	4	English	\N
7266552	921950	4	English	\N
7266553	921951	4	English	\N
7266554	921952	4	English	\N
7266555	921953	4	English	\N
7266556	921954	4	English	\N
7266557	921955	4	English	\N
7266558	921956	4	English	\N
7266559	921957	4	English	\N
7266560	921958	4	English	\N
7266561	921959	4	English	\N
7266562	921960	4	English	\N
7266563	921961	4	English	\N
7266564	921962	4	English	\N
7266565	921963	4	English	\N
7266566	921964	4	English	\N
7266567	921965	4	English	\N
7266568	921966	4	English	\N
7266569	921967	4	English	\N
7266570	921968	4	English	\N
7266571	921969	4	English	\N
7266572	921970	4	English	\N
7266573	921971	4	English	\N
7266574	921972	4	English	\N
7266575	921973	4	English	\N
7266576	921974	4	English	\N
7266577	921975	4	English	\N
7266578	921976	4	English	\N
7266579	921977	4	English	\N
7266580	921978	4	English	\N
7266581	921979	4	English	\N
7266582	921980	4	English	\N
7266583	921981	4	English	\N
7266584	921982	4	English	\N
7266585	921983	4	English	\N
7266586	921984	4	English	\N
7266587	921985	4	English	\N
7266588	921986	4	English	\N
7266589	921987	4	English	\N
7266590	921988	4	English	\N
7266591	921989	4	English	\N
7266592	921990	4	English	\N
7266593	921991	4	English	\N
7266594	921992	4	English	\N
7266595	921993	4	English	\N
7266596	921994	4	English	\N
7266597	921995	4	English	\N
7266598	921996	4	English	\N
7266599	921997	4	English	\N
7266600	921998	4	English	\N
7266601	921999	4	English	\N
7266602	922000	4	English	\N
7266603	922001	4	English	\N
7266604	922002	4	English	\N
7266605	922003	4	English	\N
7266606	922004	4	English	\N
7266607	922005	4	English	\N
7266608	922006	4	English	\N
7266609	922007	4	English	\N
7266610	922008	4	English	\N
7266611	922009	4	English	\N
7266612	922010	4	English	\N
7266613	922011	4	English	\N
7266614	922012	4	English	\N
7266615	922013	4	English	\N
7266616	922014	4	English	\N
7266617	922015	4	English	\N
7266618	922016	4	English	\N
7266619	922017	4	English	\N
7266620	922018	4	English	\N
7266621	922019	4	English	\N
7266622	922020	4	English	\N
7266623	922021	4	English	\N
7266624	922022	4	English	\N
7266625	922023	4	English	\N
7266626	922024	4	English	\N
7266627	922025	4	English	\N
7266628	922026	4	English	\N
7266629	922027	4	English	\N
7266630	922028	4	English	\N
7266631	922029	4	English	\N
7266632	922030	4	English	\N
7266633	922031	4	English	\N
7266634	922032	4	English	\N
7266635	922033	4	English	\N
7266636	922034	4	English	\N
7266637	922035	4	English	\N
7266638	922036	4	English	\N
7266639	922037	4	English	\N
7266640	922038	4	English	\N
7266641	922039	4	English	\N
7266642	922040	4	English	\N
7266643	922041	4	English	\N
7266644	922042	4	English	\N
7266645	922043	4	English	\N
7266646	922044	4	English	\N
7266647	922045	4	English	\N
7266648	922046	4	English	\N
7266649	922047	4	English	\N
7266650	922048	4	English	\N
7266651	922049	4	English	\N
7266652	922050	4	English	\N
7266653	922051	4	English	\N
7266654	922052	4	English	\N
7266655	922053	4	English	\N
7266656	922054	4	English	\N
7266657	922055	4	English	\N
7266658	922056	4	English	\N
7266659	922057	4	English	\N
7266660	922058	4	English	\N
7266661	922059	4	English	\N
7266662	922060	4	English	\N
7266663	922061	4	English	\N
7266664	922062	4	English	\N
7266665	922063	4	English	\N
7266666	922064	4	English	\N
7266667	922065	4	English	\N
7266668	922066	4	English	\N
7266669	922067	4	English	\N
7266670	922068	4	English	\N
7266671	922069	4	English	\N
7266672	922070	4	English	\N
7266673	922071	4	English	\N
7266674	922072	4	English	\N
7266675	922073	4	English	\N
7266676	922074	4	English	\N
7266677	922075	4	English	\N
7266678	922076	4	English	\N
7266679	922077	4	English	\N
7266680	922078	4	English	\N
7266681	922079	4	English	\N
7266682	922086	4	English	\N
7266683	922087	4	English	\N
7266684	922088	4	English	\N
7266685	922089	4	English	\N
7266686	922090	4	English	\N
7266687	922091	4	English	\N
7266688	922092	4	English	\N
7266689	922093	4	English	\N
7266690	922094	4	English	\N
7266691	922095	4	English	\N
7266692	922096	4	English	\N
7266693	922097	4	English	\N
7266694	922098	4	English	\N
7266695	922099	4	English	\N
7266696	922100	4	English	\N
7266697	922101	4	English	\N
7266698	922102	4	English	\N
7266699	922103	4	English	\N
7266700	922104	4	English	\N
7266701	922105	4	English	\N
7266702	922106	4	English	\N
7266703	922107	4	English	\N
7266704	922108	4	English	\N
7266705	922109	4	English	\N
7266706	922110	4	English	\N
7266707	922111	4	English	\N
7266708	922112	4	English	\N
7266709	922113	4	English	\N
7266710	922114	4	English	\N
7266711	922115	4	English	\N
7266712	922116	4	English	\N
7266713	922117	4	English	\N
7266714	922118	4	English	\N
7266715	922119	4	English	\N
7266716	922120	4	English	\N
7266717	922121	4	English	\N
7266718	922122	4	English	\N
7266719	922123	4	English	\N
7266720	922124	4	English	\N
7266721	922125	4	English	\N
7266722	922126	4	English	\N
7266723	922127	4	English	\N
7266724	922128	4	English	\N
7266725	922129	4	English	\N
7266726	922130	4	English	\N
7266727	922131	4	English	\N
7266728	922132	4	English	\N
7266729	922133	4	English	\N
7266730	922134	4	English	\N
7266731	922135	4	English	\N
7266732	922136	4	English	\N
7266733	922137	4	English	\N
7266734	922138	4	English	\N
7266735	922139	4	English	\N
7266736	922140	4	English	\N
7266737	922141	4	English	\N
7266738	922142	4	English	\N
7266739	922143	4	English	\N
7266740	922144	4	English	\N
7266741	922145	4	English	\N
7266742	922146	4	English	\N
7266743	922147	4	English	\N
7266744	922148	4	English	\N
7266745	922149	4	English	\N
7266746	922150	4	English	\N
7266747	922151	4	English	\N
7266748	922152	4	English	\N
7266749	922153	4	English	\N
7266750	922154	4	English	\N
7266751	922155	4	English	\N
7266752	922156	4	English	\N
7266753	922157	4	English	\N
7266754	922158	4	English	\N
7266755	922159	4	English	\N
7266756	922160	4	English	\N
7266757	922161	4	English	\N
7266758	922162	4	English	\N
7266759	922163	4	English	\N
7266760	922164	4	English	\N
7266761	922165	4	English	\N
7266762	922166	4	English	\N
7266763	922167	4	English	\N
7266764	922168	4	English	\N
7266765	922169	4	English	\N
7266766	922170	4	English	\N
7266767	922171	4	English	\N
7266768	922172	4	English	\N
7266769	922173	4	English	\N
7266770	922174	4	English	\N
7266771	922175	4	English	\N
7266772	922176	4	English	\N
7266773	922177	4	English	\N
7266774	922178	4	English	\N
7266775	922179	4	English	\N
7266776	922180	4	English	\N
7266777	922181	4	English	\N
7266778	922182	4	English	\N
7266779	922183	4	English	\N
7266780	922184	4	English	\N
7266781	922185	4	English	\N
7266782	922186	4	English	\N
7266783	922187	4	English	\N
7266784	922188	4	English	\N
7266785	922189	4	English	\N
7266786	922190	4	English	\N
7266787	922191	4	English	\N
7266788	922192	4	English	\N
7266789	922193	4	English	\N
7266790	922194	4	English	\N
7266791	922195	4	English	\N
7266792	922196	4	English	\N
7266793	922197	4	English	\N
7266794	922198	4	English	\N
7266795	922199	4	English	\N
7266796	922200	4	English	\N
7266797	922201	4	English	\N
7266798	922202	4	English	\N
7266799	922203	4	English	\N
7266800	922204	4	English	\N
7266801	922205	4	English	\N
7266802	922206	4	English	\N
7266803	922207	4	English	\N
7266804	922208	4	English	\N
7266805	922209	4	English	\N
7266806	922210	4	English	\N
7266807	922211	4	English	\N
7266808	922212	4	English	\N
7266809	922213	4	English	\N
7266810	922214	4	English	\N
7266811	922215	4	English	\N
7266812	922216	4	English	\N
7266813	922217	4	English	\N
7266814	922218	4	English	\N
7266815	922219	4	English	\N
7266816	922220	4	English	\N
7266817	922221	4	English	\N
7266818	922222	4	English	\N
7266819	922223	4	English	\N
7266820	922224	4	English	\N
7266821	922225	4	English	\N
7266822	922226	4	English	\N
7266823	922227	4	English	\N
7266824	922228	4	English	\N
7266825	922229	4	English	\N
7266826	922230	4	English	\N
7266827	922231	4	English	\N
7266828	922232	4	English	\N
7266829	922233	4	English	\N
7266830	922234	4	English	\N
7266831	922235	4	English	\N
7266832	922236	4	English	\N
7266833	922237	4	English	\N
7266834	922238	4	English	\N
7266835	922239	4	English	\N
7266836	922240	4	English	\N
7266837	922241	4	English	\N
7266838	922242	4	English	\N
7266839	922243	4	English	\N
7266840	922244	4	English	\N
7266841	922245	4	English	\N
7266842	922246	4	English	\N
7266843	922247	4	English	\N
7266844	922248	4	English	\N
7266845	922249	4	English	\N
7266846	922250	4	English	\N
7266847	922251	4	English	\N
7266848	922252	4	English	\N
7266849	922253	4	English	\N
7266850	922254	4	English	\N
7266851	922255	4	English	\N
7266852	922256	4	English	\N
7266853	922257	4	English	\N
7266854	922258	4	English	\N
7266855	922259	4	English	\N
7266856	922260	4	English	\N
7266857	922261	4	English	\N
7266858	922262	4	English	\N
7266859	922263	4	English	\N
7266860	922264	4	English	\N
7266861	922265	4	English	\N
7266862	922266	4	English	\N
7266863	922267	4	English	\N
7266864	922268	4	English	\N
7266865	922269	4	English	\N
7266866	922270	4	English	\N
7266867	922271	4	English	\N
7266868	922272	4	English	\N
7266869	922273	4	English	\N
7266870	922274	4	English	\N
7266871	922275	4	English	\N
7266872	922276	4	English	\N
7266873	922277	4	English	\N
7266874	922278	4	English	\N
7266875	922279	4	English	\N
7266876	922280	4	English	\N
7266877	922281	4	English	\N
7266878	922282	4	English	\N
7266879	922283	4	English	\N
7266880	922284	4	English	\N
7266881	922285	4	English	\N
7266882	922286	4	English	\N
7266883	922287	4	English	\N
7266884	922288	4	English	\N
7266885	922289	4	English	\N
7266886	922290	4	English	\N
7266887	922291	4	English	\N
7266888	922292	4	English	\N
7266889	922293	4	English	\N
7266890	922294	4	English	\N
7266891	922295	4	English	\N
7266892	922296	4	English	\N
7266893	922297	4	English	\N
7266894	922298	4	English	\N
7266895	922299	4	English	\N
7266896	922300	4	English	\N
7266897	922301	4	English	\N
7266898	922302	4	English	\N
7266899	922303	4	English	\N
7266900	922304	4	English	\N
7266901	922305	4	English	\N
7266902	922306	4	English	\N
7266903	922307	4	English	\N
7266904	922308	4	English	\N
7266905	922309	4	English	\N
7266906	922310	4	English	\N
7266907	922311	4	English	\N
7266908	922312	4	English	\N
7266909	922313	4	English	\N
7266910	922314	4	English	\N
7266911	922315	4	English	\N
7266912	922316	4	English	\N
7266913	922317	4	English	\N
7266914	922318	4	English	\N
7266915	922319	4	English	\N
7266916	922320	4	English	\N
7266917	922321	4	English	\N
7266918	922322	4	English	\N
7266919	922323	4	English	\N
7266920	922324	4	English	\N
7266921	922325	4	English	\N
7266922	922326	4	English	\N
7266923	922327	4	English	\N
7266924	922328	4	English	\N
7266925	922329	4	English	\N
7266926	922330	4	English	\N
7266927	922331	4	English	\N
7266928	922332	4	English	\N
7266929	922333	4	English	\N
7266930	922334	4	English	\N
7266931	922335	4	English	\N
7266932	922336	4	English	\N
7266933	922337	4	English	\N
7266934	922338	4	English	\N
7266935	922339	4	English	\N
7266936	922340	4	English	\N
7266937	922341	4	English	\N
7266938	922342	4	English	\N
7266939	922343	4	English	\N
7266940	922344	4	English	\N
7266941	922345	4	English	\N
7266942	922346	4	English	\N
7266943	922347	4	English	\N
7266944	922348	4	English	\N
7266945	922349	4	English	\N
7266946	922350	4	English	\N
7266947	922351	4	English	\N
7266948	922352	4	English	\N
7266949	922353	4	English	\N
7266950	922354	4	English	\N
7266951	922355	4	English	\N
7266952	922356	4	English	\N
7266953	922357	4	English	\N
7266954	922358	4	English	\N
7266955	922359	4	English	\N
7266956	922360	4	English	\N
7266957	922361	4	English	\N
7266958	922362	4	English	\N
7266959	922363	4	English	\N
7266960	922364	4	English	\N
7266961	922365	4	English	\N
7266962	922366	4	English	\N
7266963	922367	4	English	\N
7266964	922368	4	English	\N
7266965	922369	4	English	\N
7266966	922370	4	English	\N
7266967	922371	4	English	\N
7266968	922372	4	English	\N
7266969	922373	4	English	\N
7266970	922374	4	English	\N
7266971	922375	4	English	\N
7266972	922376	4	English	\N
7266973	922377	4	English	\N
7266974	922378	4	English	\N
7266975	922379	4	English	\N
7266976	922380	4	English	\N
7266977	922381	4	English	\N
7266978	922382	4	English	\N
7266979	922383	4	English	\N
7266980	922384	4	English	\N
7266981	922385	4	English	\N
7266982	922386	4	English	\N
7266983	922387	4	English	\N
7266984	922388	4	English	\N
7266985	922389	4	English	\N
7266986	922390	4	English	\N
7266987	922391	4	English	\N
7266988	922392	4	English	\N
7266989	922393	4	English	\N
7266990	922394	4	English	\N
7266991	922395	4	English	\N
7266992	922396	4	English	\N
7266993	922397	4	English	\N
7266994	922398	4	English	\N
7266995	922399	4	English	\N
7266996	922400	4	English	\N
7266997	922401	4	English	\N
7266998	922402	4	English	\N
7266999	922403	4	English	\N
7267000	922404	4	English	\N
7267001	922405	4	English	\N
7267002	922406	4	English	\N
7267003	922407	4	English	\N
7267004	922408	4	English	\N
7267005	922409	4	English	\N
7267006	922410	4	English	\N
7267007	922411	4	English	\N
7267008	922412	4	English	\N
7267009	922413	4	English	\N
7267010	922414	4	English	\N
7267011	922415	4	English	\N
7267012	922416	4	English	\N
7267013	922417	4	English	\N
7267014	922418	4	English	\N
7267015	922419	4	English	\N
7267016	922420	4	English	\N
7267017	922421	4	English	\N
7267018	922422	4	English	\N
7267019	922423	4	English	\N
7267020	922424	4	English	\N
7267021	922425	4	English	\N
7267022	922426	4	English	\N
7267023	922427	4	English	\N
7267024	922428	4	English	\N
7267025	922429	4	English	\N
7267026	922430	4	English	\N
7267027	922431	4	English	\N
7267028	922432	4	English	\N
7267029	922433	4	English	\N
7267030	922434	4	English	\N
7267031	922435	4	English	\N
7267032	922436	4	English	\N
7267033	922437	4	English	\N
7267034	922438	4	English	\N
7267035	922439	4	English	\N
7267036	922440	4	English	\N
7267037	922441	4	English	\N
7267038	922442	4	English	\N
7267039	922443	4	English	\N
7267040	922444	4	English	\N
7267041	922445	4	English	\N
7267042	922446	4	English	\N
7267043	922447	4	English	\N
7267044	922448	4	English	\N
7267045	922449	4	English	\N
7267046	922450	4	English	\N
7267047	922451	4	English	\N
7267048	922452	4	English	\N
7267049	922453	4	English	\N
7267050	922454	4	English	\N
7267051	922455	4	English	\N
7267052	922456	4	English	\N
7267053	922457	4	English	\N
7267054	922458	4	English	\N
7267055	922459	4	English	\N
7267056	922460	4	English	\N
7267057	922461	4	English	\N
7267058	922462	4	English	\N
7267059	922463	4	English	\N
7267060	922464	4	English	\N
7267061	922465	4	English	\N
7267062	922466	4	English	\N
7267063	922467	4	English	\N
7267064	922468	4	English	\N
7267065	922469	4	English	\N
7267066	922470	4	English	\N
7267067	922471	4	English	\N
7267068	922472	4	English	\N
7267069	922473	4	English	\N
7267070	922474	4	English	\N
7267071	922475	4	English	\N
7267072	922476	4	English	\N
7267073	922477	4	English	\N
7267074	922478	4	English	\N
7267075	922479	4	English	\N
7267076	922480	4	English	\N
7267077	922481	4	English	\N
7267078	922482	4	English	\N
7267079	922483	4	English	\N
7267080	922484	4	English	\N
7267081	922485	4	English	\N
7267082	922486	4	English	\N
7267083	922487	4	English	\N
7267084	922488	4	English	\N
7267085	922489	4	English	\N
7267086	922490	4	English	\N
7267087	922491	4	English	\N
7267088	922492	4	English	\N
7267089	922493	4	English	\N
7267090	922494	4	English	\N
7267091	922495	4	English	\N
7267092	922496	4	English	\N
7267093	922497	4	English	\N
7267094	922498	4	English	\N
7267095	922499	4	English	\N
7267096	922500	4	English	\N
7267097	922501	4	English	\N
7267098	922502	4	English	\N
7267099	922503	4	English	\N
7267100	922504	4	English	\N
7267101	922505	4	English	\N
7267102	922506	4	English	\N
7267103	922507	4	English	\N
7267104	922508	4	English	\N
7267105	922509	4	English	\N
7267106	922510	4	English	\N
7267107	922511	4	English	\N
7267108	922512	4	English	\N
7267109	922513	4	English	\N
7267110	922514	4	English	\N
7267111	922515	4	English	\N
7267112	922516	4	English	\N
7267113	922517	4	English	\N
7267114	922518	4	English	\N
7267115	922519	4	English	\N
7267116	922520	4	English	\N
7267117	922521	4	English	\N
7267118	922522	4	English	\N
7267119	922523	4	English	\N
7267120	922524	4	English	\N
7267121	922525	4	English	\N
7267122	922526	4	English	\N
\.


--
-- Data for Name: movie_info_idx; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.movie_info_idx (id, movie_id, info_type_id, info, note) FROM stdin;
1	2	99	1000000103	\N
2	2	100	53	\N
3	2	101	4.0	\N
4	11	99	1..1..3.11	\N
5	11	100	6	\N
6	11	101	6.3	\N
7	24	99	1.11.1...4	\N
8	24	100	7	\N
9	24	101	3.3	\N
10	50	99	0000011112	\N
11	50	100	3030	\N
12	50	101	6.0	\N
13	51	99	00.0012201	\N
14	51	100	55	\N
15	51	101	6.8	\N
16	52	99	0..0012201	\N
17	52	100	43	\N
18	52	101	6.7	\N
19	53	99	0..0011111	\N
20	53	100	41	\N
21	53	101	6.5	\N
22	54	99	0.0.012101	\N
23	54	100	48	\N
24	54	101	6.9	\N
25	55	99	0...013101	\N
26	55	100	39	\N
27	55	101	6.9	\N
28	56	99	0.00012102	\N
29	56	100	42	\N
30	56	101	6.5	\N
31	57	99	00.0022111	\N
32	57	100	40	\N
33	57	101	6.3	\N
34	58	99	0..0013101	\N
35	58	100	33	\N
36	58	101	6.4	\N
37	59	99	0..0012101	\N
38	59	100	44	\N
39	59	101	6.4	\N
40	60	99	0.0.102202	\N
41	60	100	49	\N
42	60	101	7.0	\N
43	61	99	0000221101	\N
44	61	100	103	\N
45	61	101	5.9	\N
46	62	99	0..0012111	\N
47	62	100	42	\N
48	62	101	6.8	\N
49	63	99	0..0012011	\N
50	63	100	41	\N
51	63	101	6.5	\N
52	64	99	0.00021101	\N
53	64	100	48	\N
54	64	101	6.6	\N
55	65	99	0.00013201	\N
56	65	100	36	\N
57	65	101	6.5	\N
58	66	99	0...002212	\N
59	66	100	42	\N
60	66	101	6.8	\N
61	67	99	0.00111101	\N
62	67	100	68	\N
63	67	101	6.3	\N
64	68	99	0000012111	\N
65	68	100	50	\N
66	68	101	6.2	\N
67	69	99	2...1.2002	\N
68	69	100	13	\N
69	69	101	3.3	\N
70	82	99	00..2.2.03	\N
71	82	100	13	\N
72	82	101	5.8	\N
73	85	99	....021201	\N
74	85	100	12	\N
75	85	101	6.9	\N
76	86	99	2..10.0021	\N
77	86	100	13	\N
78	86	101	5.7	\N
79	106	99	.0...31003	\N
80	106	100	13	\N
81	106	101	6.5	\N
82	114	99	40010....3	\N
83	114	100	22	\N
84	114	101	2.3	\N
85	118	99	2000110002	\N
86	118	100	136	\N
87	118	101	6.0	\N
88	196	99	3000000.03	\N
89	196	100	45	\N
90	196	101	2.0	\N
91	211	99	..21.0.003	\N
92	211	100	13	\N
93	211	101	4.4	\N
94	228	99	00..1.0122	\N
95	228	100	17	\N
96	228	101	7.6	\N
97	272	99	..1.1.2003	\N
98	272	100	13	\N
99	272	101	5.6	\N
100	284	99	0000000124	\N
101	284	100	10125	\N
102	284	101	8.1	\N
103	285	99	0....02202	\N
104	285	100	23	\N
105	285	101	7.3	\N
106	286	99	0...002112	\N
107	286	100	26	\N
108	286	101	7.3	\N
109	287	99	...0.13102	\N
110	287	100	23	\N
111	287	101	7.8	\N
112	288	99	00.0.02212	\N
113	288	100	35	\N
114	288	101	7.7	\N
115	289	99	0...012102	\N
116	289	100	26	\N
117	289	101	7.7	\N
118	290	99	0..0000024	\N
119	290	100	58	\N
120	290	101	8.1	\N
121	291	99	.....03202	\N
122	291	100	21	\N
123	291	101	7.9	\N
124	292	99	0...001213	\N
125	292	100	29	\N
126	292	101	7.6	\N
127	293	99	0...002202	\N
128	293	100	25	\N
129	293	101	7.2	\N
130	294	99	.0...02103	\N
131	294	100	24	\N
132	294	101	7.8	\N
133	295	99	...0003102	\N
134	295	100	22	\N
135	295	101	7.6	\N
136	296	99	00.0001212	\N
137	296	100	50	\N
138	296	101	7.7	\N
139	297	99	0....01212	\N
140	297	100	31	\N
141	297	101	7.8	\N
142	298	99	0.0..02112	\N
143	298	100	32	\N
144	298	101	7.8	\N
145	299	99	..0..03202	\N
146	299	100	24	\N
147	299	101	7.8	\N
148	300	99	0....01222	\N
149	300	100	36	\N
150	300	101	8.1	\N
151	301	99	0.0...2222	\N
152	301	100	44	\N
153	301	101	7.9	\N
154	302	99	..0..03112	\N
155	302	100	25	\N
156	302	101	7.9	\N
157	303	99	0...001213	\N
158	303	100	32	\N
159	303	101	7.7	\N
160	304	99	0..0.01113	\N
161	304	100	33	\N
162	304	101	7.7	\N
163	305	99	0..0.02212	\N
164	305	100	33	\N
165	305	101	7.9	\N
166	306	99	0...0.3112	\N
167	306	100	30	\N
168	306	101	7.5	\N
169	307	99	1....02212	\N
170	307	100	27	\N
171	307	101	7.3	\N
172	308	99	...0.04101	\N
173	308	100	21	\N
174	308	101	7.5	\N
175	309	99	0....02122	\N
176	309	100	27	\N
177	309	101	7.5	\N
178	310	99	0....01222	\N
179	310	100	51	\N
180	310	101	7.7	\N
181	311	99	00..001202	\N
182	311	100	31	\N
183	311	101	7.5	\N
184	312	99	0..0.00212	\N
185	312	100	51	\N
186	312	101	7.6	\N
187	313	99	0...002222	\N
188	313	100	45	\N
189	313	101	7.7	\N
190	314	99	0.0.002222	\N
191	314	100	52	\N
192	314	101	8.1	\N
193	315	99	....0.4112	\N
194	315	100	21	\N
195	315	101	7.8	\N
196	316	99	0...0.2113	\N
197	316	100	32	\N
198	316	101	7.9	\N
199	317	99	0.0.002112	\N
200	317	100	25	\N
201	317	101	7.8	\N
202	318	99	0....01213	\N
203	318	100	36	\N
204	318	101	7.8	\N
205	319	99	0...0.2212	\N
206	319	100	31	\N
207	319	101	7.8	\N
208	320	99	0..0.02212	\N
209	320	100	25	\N
210	320	101	7.2	\N
211	321	99	0...002112	\N
212	321	100	31	\N
213	321	101	7.9	\N
214	322	99	0...002312	\N
215	322	100	71	\N
216	322	101	8.1	\N
217	323	99	..0..02202	\N
218	323	100	33	\N
219	323	101	7.8	\N
220	324	99	0...001123	\N
221	324	100	52	\N
222	324	101	8.2	\N
223	325	99	..0.002212	\N
224	325	100	22	\N
225	325	101	7.9	\N
226	326	99	000.001212	\N
227	326	100	51	\N
228	326	101	8.1	\N
229	327	99	0..0001212	\N
230	327	100	62	\N
231	327	101	7.9	\N
232	328	99	0...0.2212	\N
233	328	100	29	\N
234	328	101	7.7	\N
235	329	99	.....13211	\N
236	329	100	22	\N
237	329	101	7.7	\N
238	330	99	0..0..2122	\N
239	330	100	23	\N
240	330	101	7.4	\N
241	331	99	...00.2202	\N
242	331	100	32	\N
243	331	101	7.9	\N
244	332	99	0....02212	\N
245	332	100	28	\N
246	332	101	7.6	\N
247	333	99	000.001222	\N
248	333	100	68	\N
249	333	101	8.2	\N
250	334	99	0..0001113	\N
251	334	100	61	\N
252	334	101	7.9	\N
253	335	99	0.0...2022	\N
254	335	100	21	\N
255	335	101	7.8	\N
256	336	99	0....03112	\N
257	336	100	23	\N
258	336	101	7.3	\N
259	337	99	00.0001222	\N
260	337	100	57	\N
261	337	101	8.3	\N
262	338	99	....002202	\N
263	338	100	22	\N
264	338	101	7.8	\N
265	339	99	0....01212	\N
266	339	100	33	\N
267	339	101	7.9	\N
268	340	99	...0.03112	\N
269	340	100	26	\N
270	340	101	7.8	\N
271	341	99	0.0.001223	\N
272	341	100	104	\N
273	341	101	8.4	\N
274	342	99	0...002113	\N
275	342	100	37	\N
276	342	101	8.2	\N
277	343	99	0..0.02212	\N
278	343	100	42	\N
279	343	101	7.7	\N
280	344	99	....003302	\N
281	344	100	23	\N
282	344	101	7.8	\N
283	345	99	0..0001222	\N
284	345	100	63	\N
285	345	101	8.0	\N
286	346	99	0...001222	\N
287	346	100	54	\N
288	346	101	8.2	\N
289	347	99	.00.001213	\N
290	347	100	68	\N
291	347	101	8.3	\N
292	348	99	0..0.03013	\N
293	348	100	29	\N
294	348	101	7.4	\N
295	349	99	0..0001312	\N
296	349	100	79	\N
297	349	101	8.0	\N
298	350	99	..0..02212	\N
299	350	100	23	\N
300	350	101	7.5	\N
301	351	99	000.001213	\N
302	351	100	51	\N
303	351	101	7.9	\N
304	352	99	0...001222	\N
305	352	100	64	\N
306	352	101	7.9	\N
307	353	99	00.0000213	\N
308	353	100	61	\N
309	353	101	8.3	\N
310	354	99	0....01113	\N
311	354	100	37	\N
312	354	101	8.2	\N
313	355	99	0.0..02213	\N
314	355	100	30	\N
315	355	101	7.4	\N
316	357	99	....013112	\N
317	357	100	24	\N
318	357	101	7.7	\N
319	356	99	00..002113	\N
320	356	100	28	\N
321	356	101	7.7	\N
322	358	99	00.0.01113	\N
323	358	100	53	\N
324	358	101	8.4	\N
325	359	99	00...01222	\N
326	359	100	44	\N
327	359	101	7.7	\N
328	360	99	0..0002212	\N
329	360	100	35	\N
330	360	101	7.9	\N
331	361	99	....003202	\N
332	361	100	25	\N
333	361	101	7.6	\N
334	362	99	0...000322	\N
335	362	100	53	\N
336	362	101	8.1	\N
337	363	99	...0.03112	\N
338	363	100	25	\N
339	363	101	7.7	\N
340	364	99	00.0001212	\N
341	364	100	61	\N
342	364	101	8.4	\N
343	365	99	0.0..01222	\N
344	365	100	47	\N
345	365	101	7.9	\N
346	366	99	0....01223	\N
347	366	100	52	\N
348	366	101	8.5	\N
349	367	99	....003112	\N
350	367	100	21	\N
351	367	101	7.9	\N
352	368	99	0.0.001312	\N
353	368	100	55	\N
354	368	101	7.9	\N
355	369	99	....013211	\N
356	369	100	26	\N
357	369	101	7.9	\N
358	370	99	5...1....3	\N
359	370	100	6	\N
360	370	101	3.0	\N
361	371	99	2000000003	\N
362	371	100	121	\N
363	371	101	4.8	\N
364	403	99	3.......15	\N
365	403	100	6	\N
366	403	101	3.3	\N
367	405	99	1.00000113	\N
368	405	100	84	\N
369	405	101	6.4	\N
370	581	99	0000010113	\N
371	581	100	145	\N
372	581	101	7.0	\N
373	582	99	..4..14...	\N
374	582	100	9	\N
375	582	101	6.3	\N
376	583	99	0.3..011.1	\N
377	583	100	12	\N
378	583	101	6.7	\N
379	584	99	..2..13.01	\N
380	584	100	16	\N
381	584	101	6.8	\N
382	585	99	..5.2..2..	\N
383	585	100	8	\N
384	585	101	6.1	\N
385	586	99	241....1.1	\N
386	586	100	9	\N
387	586	101	5.2	\N
388	587	99	0.3..230..	\N
389	587	100	13	\N
390	587	101	6.3	\N
391	588	99	0.2..312.1	\N
392	588	100	20	\N
393	588	101	6.5	\N
394	589	99	1.3..200.0	\N
395	589	100	12	\N
396	589	101	6.0	\N
397	590	99	..3.12.000	\N
398	590	100	12	\N
399	590	101	6.4	\N
400	591	99	..4..13.11	\N
401	591	100	10	\N
402	591	101	6.9	\N
403	592	99	..31.4.1.1	\N
404	592	100	10	\N
405	592	101	6.0	\N
406	593	99	..3.11.1.0	\N
407	593	100	11	\N
408	593	101	6.2	\N
409	594	99	..3..011.1	\N
410	594	100	11	\N
411	594	101	6.8	\N
412	595	99	..4..3.2.1	\N
413	595	100	10	\N
414	595	101	6.5	\N
415	596	99	0000012101	\N
416	596	100	2606	\N
417	596	101	6.2	\N
418	597	99	...11221.2	\N
419	597	100	9	\N
420	597	101	6.4	\N
421	598	99	...112211.	\N
422	598	100	8	\N
423	598	101	6.2	\N
424	599	99	..2..24.2.	\N
425	599	100	5	\N
426	599	101	5.7	\N
427	600	99	....0042.0	\N
428	600	100	21	\N
429	600	101	7.1	\N
430	601	99	.1..23211.	\N
431	601	100	10	\N
432	601	101	5.6	\N
433	602	99	....412.1.	\N
434	602	100	7	\N
435	602	101	6.0	\N
436	603	99	....241..1	\N
437	603	100	7	\N
438	603	101	5.9	\N
439	604	99	....1113.1	\N
440	604	100	6	\N
441	604	101	7.2	\N
442	605	99	0..1.13101	\N
443	605	100	17	\N
444	605	101	7.5	\N
445	606	99	0.0.122201	\N
446	606	100	25	\N
447	606	101	7.0	\N
448	607	99	..11.131.1	\N
449	607	100	8	\N
450	607	101	6.8	\N
451	608	99	...0013201	\N
452	608	100	20	\N
453	608	101	7.1	\N
454	609	99	..1.111.11	\N
455	609	100	6	\N
456	609	101	6.3	\N
457	610	99	00..002211	\N
458	610	100	28	\N
459	610	101	7.7	\N
460	611	99	....004211	\N
461	611	100	27	\N
462	611	101	7.8	\N
463	612	99	....1.5.11	\N
464	612	100	7	\N
465	612	101	7.1	\N
466	613	99	.....411.2	\N
467	613	100	7	\N
468	613	101	7.4	\N
469	614	99	...0.05111	\N
470	614	100	29	\N
471	614	101	7.3	\N
472	615	99	..0.0223.0	\N
473	615	100	13	\N
474	615	101	7.1	\N
475	616	99	000...50.1	\N
476	616	100	12	\N
477	616	101	7.3	\N
478	617	99	.0000320.1	\N
479	617	100	22	\N
480	617	101	6.4	\N
481	618	99	.1..1221.2	\N
482	618	100	9	\N
483	618	101	5.9	\N
484	619	99	0....13211	\N
485	619	100	29	\N
486	619	101	7.5	\N
487	620	99	.0..131100	\N
488	620	100	22	\N
489	620	101	6.4	\N
490	621	99	...0103.21	\N
491	621	100	13	\N
492	621	101	6.7	\N
493	622	99	.00..02311	\N
494	622	100	28	\N
495	622	101	7.7	\N
496	623	99	....2.2121	\N
497	623	100	8	\N
498	623	101	6.4	\N
499	624	99	0.000121.1	\N
500	624	100	27	\N
501	624	101	6.8	\N
502	625	99	1.1.115...	\N
503	625	100	8	\N
504	625	101	5.9	\N
505	626	99	....1122.0	\N
506	626	100	11	\N
507	626	101	6.9	\N
508	627	99	.1.1.12..3	\N
509	627	100	8	\N
510	627	101	5.9	\N
511	628	99	.....12211	\N
512	628	100	7	\N
513	628	101	7.4	\N
514	629	99	...0.03211	\N
515	629	100	22	\N
516	629	101	7.5	\N
517	630	99	00.0.03.02	\N
518	630	100	12	\N
519	630	101	6.2	\N
520	631	99	..0.013200	\N
521	631	100	17	\N
522	631	101	7.1	\N
523	632	99	.....3311.	\N
524	632	100	8	\N
525	632	101	6.8	\N
526	633	99	..00.22101	\N
527	633	100	25	\N
528	633	101	7.2	\N
529	634	99	....0250.0	\N
530	634	100	13	\N
531	634	101	7.4	\N
532	635	99	00.0021112	\N
533	635	100	46	\N
534	635	101	7.3	\N
535	636	99	....033001	\N
536	636	100	19	\N
537	636	101	6.6	\N
538	637	99	0..0013110	\N
539	637	100	22	\N
540	637	101	7.1	\N
541	638	99	....024.21	\N
542	638	100	15	\N
543	638	101	7.2	\N
544	639	99	..0..32101	\N
545	639	100	16	\N
546	639	101	7.1	\N
547	640	99	....116..1	\N
548	640	100	8	\N
549	640	101	6.7	\N
550	641	99	.000.032.1	\N
551	641	100	13	\N
552	641	101	7.5	\N
553	642	99	0..0002211	\N
554	642	100	37	\N
555	642	101	7.7	\N
556	643	99	11.1.222.1	\N
557	643	100	10	\N
558	643	101	6.3	\N
559	644	99	....043.00	\N
560	644	100	13	\N
561	644	101	6.3	\N
562	645	99	.....26.1.	\N
563	645	100	8	\N
564	645	101	6.6	\N
565	646	99	...1221000	\N
566	646	100	17	\N
567	646	101	5.8	\N
568	647	99	.0.0022110	\N
569	647	100	15	\N
570	647	101	6.7	\N
571	648	99	..0..12210	\N
572	648	100	16	\N
573	648	101	7.3	\N
574	649	99	0.00003121	\N
575	649	100	34	\N
576	649	101	7.9	\N
577	650	99	..0..250.1	\N
578	650	100	19	\N
579	650	101	6.9	\N
580	651	99	.....11312	\N
581	651	100	29	\N
582	651	101	7.9	\N
583	652	99	.....15111	\N
584	652	100	26	\N
585	652	101	7.1	\N
586	653	99	..010010.2	\N
587	653	100	11	\N
588	653	101	5.9	\N
589	654	99	....012211	\N
590	654	100	29	\N
591	654	101	7.5	\N
592	655	99	......8..2	\N
593	655	100	5	\N
594	655	101	7.0	\N
595	656	99	0..2032.0.	\N
596	656	100	15	\N
597	656	101	6.1	\N
598	657	99	.....43.11	\N
599	657	100	9	\N
600	657	101	6.5	\N
601	658	99	0..0001312	\N
602	658	100	36	\N
603	658	101	7.8	\N
604	659	99	1...001311	\N
605	659	100	28	\N
606	659	101	7.7	\N
607	660	99	.....52.11	\N
608	660	100	8	\N
609	660	101	6.6	\N
610	661	99	.1...13221	\N
611	661	100	10	\N
612	661	101	7.1	\N
613	662	99	.0...25..0	\N
614	662	100	12	\N
615	662	101	6.5	\N
616	663	99	.0..0.3311	\N
617	663	100	33	\N
618	663	101	7.7	\N
619	664	99	....012201	\N
620	664	100	27	\N
621	664	101	7.4	\N
622	665	99	.....02302	\N
623	665	100	28	\N
624	665	101	7.8	\N
625	666	99	...0110102	\N
626	666	100	12	\N
627	666	101	6.9	\N
628	667	99	0..12021..	\N
629	667	100	12	\N
630	667	101	5.5	\N
631	668	99	....0150.0	\N
632	668	100	11	\N
633	668	101	6.8	\N
634	669	99	00.0012201	\N
635	669	100	34	\N
636	669	101	7.5	\N
637	670	99	...0012110	\N
638	670	100	21	\N
639	670	101	7.4	\N
640	671	99	0.0..03111	\N
641	671	100	31	\N
642	671	101	7.5	\N
643	672	99	2....22.2.	\N
644	672	100	8	\N
645	672	101	5.9	\N
646	673	99	0....03211	\N
647	673	100	34	\N
648	673	101	7.5	\N
649	674	99	...0011312	\N
650	674	100	19	\N
651	674	101	7.6	\N
652	675	99	...0.03211	\N
653	675	100	25	\N
654	675	101	7.7	\N
655	676	99	.1...2211.	\N
656	676	100	7	\N
657	676	101	6.3	\N
658	677	99	.....13211	\N
659	677	100	29	\N
660	677	101	7.6	\N
661	679	99	1....14.11	\N
662	679	100	7	\N
663	679	101	2.3	\N
664	681	99	00.0000213	\N
665	681	100	60	\N
666	681	101	7.6	\N
667	684	99	1....1411.	\N
668	684	100	7	\N
669	684	101	6.2	\N
670	685	99	......531.	\N
671	685	100	6	\N
672	685	101	7.9	\N
673	688	99	1....1.321	\N
674	688	100	8	\N
675	688	101	6.3	\N
676	691	99	1....2131.	\N
677	691	100	8	\N
678	691	101	6.8	\N
679	695	99	1...212.22	\N
680	695	100	10	\N
681	695	101	6.4	\N
682	419	99	00.0100312	\N
683	419	100	23	\N
684	419	101	5.5	\N
685	429	99	000.002311	\N
686	429	100	107	\N
687	429	101	7.0	\N
688	463	99	.2...1121.	\N
689	463	100	7	\N
690	463	101	3.1	\N
691	469	99	00.0031101	\N
692	469	100	93	\N
693	469	101	5.7	\N
694	710	99	.2...020.3	\N
695	710	100	12	\N
696	710	101	5.1	\N
697	696	99	00...01221	\N
698	696	100	61	\N
699	696	101	6.7	\N
700	752	99	1..21122.1	\N
701	752	100	10	\N
702	752	101	6.0	\N
703	813	99	...0101.03	\N
704	813	100	11	\N
705	813	101	5.8	\N
706	815	99	100.1110.4	\N
707	815	100	20	\N
708	815	101	3.7	\N
709	902	99	0.....1204	\N
710	902	100	16	\N
711	902	101	6.7	\N
712	860	99	0...001213	\N
713	860	100	25	\N
714	860	101	6.9	\N
715	907	99	0000112112	\N
716	907	100	134	\N
717	907	101	6.9	\N
718	910	99	....1313..	\N
719	910	100	6	\N
720	910	101	6.2	\N
721	918	99	....222..4	\N
722	918	100	5	\N
723	918	101	7.6	\N
724	934	99	0000012112	\N
725	934	100	646	\N
726	934	101	7.1	\N
727	935	99	....1.24.1	\N
728	935	100	7	\N
729	935	101	7.2	\N
730	936	99	......4222	\N
731	936	100	5	\N
732	936	101	7.4	\N
733	937	99	......4121	\N
734	937	100	7	\N
735	937	101	7.6	\N
736	938	99	.....33.11	\N
737	938	100	6	\N
738	938	101	6.5	\N
739	939	99	......62.2	\N
740	939	100	5	\N
741	939	101	7.4	\N
742	940	99	......*...	\N
743	940	100	5	\N
744	940	101	7.0	\N
745	941	99	.....26..2	\N
746	941	100	5	\N
747	941	101	6.8	\N
748	942	99	.....16..1	\N
749	942	100	6	\N
750	942	101	6.9	\N
751	943	99	.....132.3	\N
752	943	100	9	\N
753	943	101	7.3	\N
754	944	99	......6..3	\N
755	944	100	6	\N
756	944	101	7.1	\N
757	945	99	.....151.1	\N
758	945	100	6	\N
759	945	101	7.4	\N
760	946	99	...2.24..2	\N
761	946	100	5	\N
762	946	101	6.6	\N
763	947	99	....1.32.2	\N
764	947	100	8	\N
765	947	101	7.2	\N
766	948	99	1....02112	\N
767	948	100	14	\N
768	948	101	6.1	\N
769	949	99	.....36...	\N
770	949	100	6	\N
771	949	101	7.0	\N
772	950	99	......6.11	\N
773	950	100	6	\N
774	950	101	7.1	\N
775	951	99	.....15..3	\N
776	951	100	6	\N
777	951	101	6.9	\N
778	952	99	.....133.1	\N
779	952	100	6	\N
780	952	101	6.9	\N
781	953	99	....2.31.2	\N
782	953	100	8	\N
783	953	101	6.7	\N
784	954	99	.....231.2	\N
785	954	100	8	\N
786	954	101	6.9	\N
787	955	99	.....15..2	\N
788	955	100	7	\N
789	955	101	6.9	\N
790	956	99	......51.3	\N
791	956	100	8	\N
792	956	101	7.5	\N
793	957	99	.....16..2	\N
794	957	100	15	\N
795	957	101	6.8	\N
796	958	99	......61.1	\N
797	958	100	6	\N
798	958	101	7.0	\N
799	959	99	......7.11	\N
800	959	100	7	\N
801	959	101	7.0	\N
802	960	99	.....26..2	\N
803	960	100	5	\N
804	960	101	6.8	\N
805	961	99	.....46...	\N
806	961	100	5	\N
807	961	101	6.9	\N
808	962	99	.....142.1	\N
809	962	100	7	\N
810	962	101	7.2	\N
811	963	99	0000022101	\N
812	963	100	195	\N
813	963	101	6.6	\N
814	964	99	....2.422.	\N
815	964	100	5	\N
816	964	101	6.8	\N
817	965	99	1....421..	\N
818	965	100	7	\N
819	965	101	5.9	\N
820	974	99	.....242.2	\N
821	974	100	5	\N
822	974	101	7.2	\N
823	979	99	0000012210	\N
824	979	100	68	\N
825	979	101	6.7	\N
826	989	99	1....1.7..	\N
827	989	100	8	\N
828	989	101	5.9	\N
829	990	99	....2.33..	\N
830	990	100	8	\N
831	990	101	7.1	\N
832	1092	99	0000001212	\N
833	1092	100	81	\N
834	1092	101	7.3	\N
835	1094	99	.....35..1	\N
836	1094	100	6	\N
837	1094	101	6.3	\N
838	1098	99	.....142.1	\N
839	1098	100	7	\N
840	1098	101	6.7	\N
841	1101	99	....21.121	\N
842	1101	100	7	\N
843	1101	101	5.3	\N
844	1106	99	....42..22	\N
845	1106	100	5	\N
846	1106	101	6.5	\N
847	1110	99	....1..511	\N
848	1110	100	6	\N
849	1110	101	5.9	\N
850	1111	99	....3.1.13	\N
851	1111	100	6	\N
852	1111	101	6.0	\N
853	1113	99	....2.24.2	\N
854	1113	100	5	\N
855	1113	101	5.6	\N
856	1114	99	0000012202	\N
857	1114	100	145	\N
858	1114	101	6.8	\N
859	1141	99	3...211.12	\N
860	1141	100	10	\N
861	1141	101	5.4	\N
862	1144	99	0..0001103	\N
863	1144	100	41	\N
864	1144	101	4.8	\N
865	1158	99	03000..1.1	\N
866	1158	100	12	\N
867	1158	101	2.9	\N
868	1181	99	1000000123	\N
869	1181	100	1007	\N
870	1181	101	7.7	\N
871	1188	99	0000000115	\N
872	1188	100	220	\N
873	1188	101	7.5	\N
874	1334	99	0000001123	\N
875	1334	100	504	\N
876	1334	101	7.6	\N
877	1335	99	00..111004	\N
878	1335	100	30	\N
879	1335	101	5.3	\N
880	1347	99	1.11.4...1	\N
881	1347	100	7	\N
882	1347	101	5.5	\N
883	1148	99	111....1.3	\N
884	1148	100	6	\N
885	1148	101	4.3	\N
886	1186	99	1......313	\N
887	1186	100	6	\N
888	1186	101	2.5	\N
889	1333	99	..002202.0	\N
890	1333	100	14	\N
891	1333	101	6.0	\N
892	1379	99	0..0.11112	\N
893	1379	100	42	\N
894	1379	101	6.7	\N
895	1389	99	2...22...4	\N
896	1389	100	5	\N
897	1389	101	5.9	\N
898	1417	99	0.00111002	\N
899	1417	100	52	\N
900	1417	101	5.8	\N
901	1465	99	0000122100	\N
902	1465	100	110	\N
903	1465	101	5.9	\N
904	1494	99	22....21.1	\N
905	1494	100	8	\N
906	1494	101	2.4	\N
907	1535	99	....011301	\N
908	1535	100	21	\N
909	1535	101	6.8	\N
910	1537	99	0001121000	\N
911	1537	100	42	\N
912	1537	101	5.5	\N
913	1549	99	01.0.212.1	\N
914	1549	100	18	\N
915	1549	101	5.5	\N
916	1550	99	11...1.1.3	\N
917	1550	100	6	\N
918	1550	101	3.0	\N
919	1551	99	1000000112	\N
920	1551	100	125	\N
921	1551	101	6.6	\N
922	1565	99	2...1...15	\N
923	1565	100	9	\N
924	1565	101	5.6	\N
925	1570	99	1..1.1.1.4	\N
926	1570	100	7	\N
927	1570	101	5.8	\N
928	1576	99	0000001103	\N
929	1576	100	733	\N
930	1576	101	5.8	\N
931	1577	99	0.0.011011	\N
932	1577	100	12	\N
933	1577	101	6.5	\N
934	1578	99	1....12321	\N
935	1578	100	10	\N
936	1578	101	7.5	\N
937	1579	99	0..0.02012	\N
938	1579	100	12	\N
939	1579	101	7.0	\N
940	1580	99	0...012.21	\N
941	1580	100	12	\N
942	1580	101	7.4	\N
943	1581	99	1...212.11	\N
944	1581	100	14	\N
945	1581	101	6.5	\N
946	1582	99	1...122.01	\N
947	1582	100	13	\N
948	1582	101	6.4	\N
949	1583	99	1...011.11	\N
950	1583	100	11	\N
951	1583	101	7.1	\N
952	1584	99	2.0.111001	\N
953	1584	100	16	\N
954	1584	101	6.2	\N
955	1585	99	0....03.21	\N
956	1585	100	11	\N
957	1585	101	7.5	\N
958	1586	99	1...012.01	\N
959	1586	100	11	\N
960	1586	101	6.4	\N
961	1587	99	1...221.22	\N
962	1587	100	10	\N
963	1587	101	6.9	\N
964	1588	99	0100300.01	\N
965	1588	100	25	\N
966	1588	101	6.1	\N
967	1589	99	5....10.02	\N
968	1589	100	32	\N
969	1589	101	4.3	\N
970	1590	99	0.0.011001	\N
971	1590	100	11	\N
972	1590	101	6.9	\N
973	1591	99	1...112131	\N
974	1591	100	10	\N
975	1591	101	7.0	\N
976	1592	99	0..0011.11	\N
977	1592	100	11	\N
978	1592	101	6.6	\N
979	1593	99	00...01013	\N
980	1593	100	12	\N
981	1593	101	7.6	\N
982	1594	99	0...011.12	\N
983	1594	100	11	\N
984	1594	101	7.1	\N
985	1595	99	1....22113	\N
986	1595	100	10	\N
987	1595	101	7.3	\N
988	1596	99	1...002011	\N
989	1596	100	12	\N
990	1596	101	6.8	\N
991	1597	99	0.0.020012	\N
992	1597	100	13	\N
993	1597	101	6.4	\N
994	1598	99	00..112110	\N
995	1598	100	16	\N
996	1598	101	6.6	\N
997	1599	99	1...011.32	\N
998	1599	100	15	\N
999	1599	101	6.6	\N
1000	1600	99	00..001013	\N
\.


--
-- Data for Name: movie_keyword; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.movie_keyword (id, movie_id, keyword_id) FROM stdin;
1	2	1
2	11	2
3	22	2
4	44	3
5	24	2
6	50	4
7	50	5
8	50	6
9	50	7
10	50	8
11	51	9
12	51	10
13	51	11
14	51	12
15	51	13
16	51	14
17	51	15
18	51	16
19	51	17
20	51	18
21	51	19
22	51	20
23	51	21
24	51	22
25	51	23
26	51	24
27	51	25
28	51	26
29	51	27
30	51	28
31	51	29
32	64	30
33	64	31
34	64	32
35	64	33
36	64	34
37	64	35
38	64	36
39	64	37
40	64	38
41	64	39
42	64	40
43	64	41
44	64	42
45	64	43
46	64	44
47	64	45
48	64	46
49	69	47
50	69	1
51	69	48
52	69	49
53	82	1
54	84	1
55	85	47
56	85	1
57	86	50
58	86	51
59	86	52
60	86	1
61	86	53
62	86	54
63	106	55
64	114	56
65	114	57
66	114	1
67	114	58
68	114	59
69	118	60
70	118	61
71	118	62
72	118	63
73	118	64
74	118	55
75	118	65
76	118	1
77	118	66
78	211	50
79	211	67
80	211	68
81	227	63
82	227	65
83	227	47
84	227	1
85	227	48
86	228	69
87	228	70
88	228	47
89	228	1
90	284	71
91	284	72
92	284	73
93	284	74
94	284	75
95	284	76
96	284	77
97	284	78
98	284	79
99	284	80
100	284	81
101	284	82
102	284	83
103	284	84
104	284	84
105	284	84
106	284	37
107	284	85
108	284	86
109	284	87
110	284	88
111	284	89
112	284	90
113	284	91
114	284	92
115	284	93
116	284	94
117	284	95
118	284	96
119	284	97
120	284	98
121	284	99
122	284	100
123	284	101
124	284	102
125	284	103
126	284	104
127	284	105
128	284	25
129	284	106
130	284	107
131	284	108
132	284	109
133	284	110
134	284	111
135	284	112
136	284	113
137	284	114
138	284	115
139	302	116
140	318	117
141	327	118
142	327	119
143	334	1
144	357	120
145	371	121
146	371	122
147	371	123
148	371	124
149	371	108
150	371	125
151	387	126
152	387	127
153	387	128
154	388	129
155	389	130
156	398	3
157	415	1
158	581	131
159	581	132
160	581	133
161	581	134
162	581	135
163	581	136
164	581	137
165	581	138
166	581	139
167	581	140
168	582	141
169	582	142
170	582	143
171	582	144
172	582	145
173	582	146
174	582	147
175	582	148
176	585	148
177	586	148
178	587	149
179	587	150
180	587	151
181	587	152
182	587	153
183	587	154
184	587	155
185	587	156
186	587	157
187	587	158
188	587	159
189	587	160
190	588	161
191	589	148
192	590	162
193	590	163
194	590	164
195	590	165
196	590	166
197	590	167
198	590	168
199	590	169
200	590	170
201	590	148
202	591	171
203	591	172
204	591	173
205	591	174
206	591	175
207	591	176
208	591	177
209	591	178
210	591	148
211	591	179
212	592	148
213	593	180
214	593	181
215	593	182
216	593	183
217	593	184
218	593	185
219	593	148
220	594	186
221	594	187
222	594	188
223	594	189
224	594	190
225	594	191
226	594	192
227	594	193
228	594	194
229	594	195
230	594	196
231	594	197
232	594	198
233	594	199
234	594	128
235	594	200
236	595	201
237	595	202
238	595	203
239	595	204
240	595	205
241	595	206
242	595	207
243	595	208
244	595	209
245	596	210
246	596	211
247	596	212
248	596	213
249	596	214
250	596	215
251	596	216
252	596	217
253	596	218
254	596	219
255	596	220
256	596	221
257	596	222
258	596	223
259	596	224
260	596	225
261	596	226
262	596	227
263	596	228
264	596	18
265	596	229
266	596	55
267	596	230
268	596	231
269	596	232
270	596	233
271	596	234
272	596	235
273	596	236
274	596	237
275	596	238
276	596	239
277	596	240
278	596	241
279	596	242
280	596	243
281	596	244
282	596	245
283	596	135
284	596	246
285	596	247
286	596	248
287	596	249
288	596	250
289	596	251
290	596	252
291	596	253
292	596	254
293	596	255
294	596	256
295	596	257
296	596	108
297	596	258
298	596	259
299	596	184
300	596	260
301	596	261
302	596	262
303	596	263
304	647	186
305	647	264
306	647	265
307	651	266
308	651	267
309	651	268
310	654	269
311	654	270
312	654	271
313	654	272
314	654	273
315	654	274
316	654	275
317	654	276
318	654	277
319	654	278
320	654	279
321	654	280
322	654	281
323	654	282
324	654	283
325	654	284
326	654	285
327	654	286
328	654	287
329	654	288
330	654	289
331	654	290
332	654	291
333	654	292
334	654	293
335	654	294
336	654	295
337	654	296
338	654	297
339	654	298
340	654	299
341	654	300
342	654	301
343	654	128
344	654	302
345	654	303
346	654	304
347	654	305
348	654	306
349	654	307
350	658	308
351	679	309
352	681	310
353	683	311
354	683	312
355	691	313
356	691	314
357	691	315
358	691	316
359	691	317
360	691	318
361	691	319
362	691	320
363	691	110
364	691	321
365	399	322
366	399	323
367	399	324
368	399	325
369	399	326
370	399	327
371	399	328
372	399	235
373	399	329
374	399	330
375	399	331
376	399	332
377	399	333
378	399	334
379	399	335
380	399	336
381	399	337
382	399	338
383	399	339
384	399	340
385	418	341
386	418	47
387	418	342
388	418	263
389	417	343
390	417	341
391	417	344
392	417	342
393	419	62
394	419	1
395	429	1
396	464	345
397	465	345
398	466	345
399	467	345
400	468	345
401	469	77
402	469	346
403	469	347
404	469	247
405	723	47
406	728	348
407	750	349
408	750	350
409	750	351
410	813	352
411	813	353
412	813	354
413	813	355
414	813	356
415	813	357
416	813	358
417	818	3
418	826	117
419	901	1
420	902	359
421	860	3
422	887	47
423	903	360
424	903	1
425	903	361
426	903	362
427	907	363
428	907	364
429	907	365
430	907	366
431	907	367
432	907	368
433	907	369
434	907	370
435	907	371
436	907	372
437	907	373
438	907	374
439	908	363
440	908	364
441	908	365
442	909	363
443	909	364
444	909	365
445	910	363
446	910	364
447	910	365
448	911	363
449	911	364
450	911	365
451	912	363
452	912	364
453	912	365
454	913	363
455	913	364
456	913	365
457	914	363
458	914	364
459	914	365
460	915	363
461	915	364
462	915	365
463	916	363
464	916	364
465	916	365
466	917	363
467	917	364
468	917	365
469	918	363
470	918	364
471	918	365
472	919	363
473	919	364
474	919	365
475	920	363
476	920	364
477	920	365
478	921	363
479	921	364
480	921	365
481	922	363
482	922	364
483	922	365
484	923	363
485	923	364
486	923	365
487	924	363
488	924	364
489	924	365
490	925	363
491	925	364
492	925	365
493	926	363
494	926	364
495	926	365
496	927	363
497	927	364
498	927	365
499	928	363
500	928	364
501	928	365
502	929	363
503	929	364
504	929	365
505	930	363
506	930	364
507	930	365
508	931	363
509	931	364
510	931	365
511	932	363
512	932	364
513	932	365
514	933	363
515	933	364
516	933	365
517	934	363
518	934	375
519	934	376
520	934	377
521	934	365
522	934	378
523	934	379
524	934	380
525	934	367
526	934	381
527	934	347
528	934	382
529	934	383
530	934	384
531	934	385
532	934	386
533	934	387
534	934	388
535	934	389
536	934	374
537	934	390
538	934	391
539	934	392
540	935	363
541	936	363
542	937	363
543	938	363
544	939	363
545	940	363
546	941	363
547	942	363
548	943	363
549	944	363
550	945	363
551	946	363
552	947	363
553	948	363
554	950	363
555	951	363
556	952	363
557	953	363
558	954	363
559	955	363
560	956	363
561	957	363
562	958	363
563	959	363
564	960	363
565	962	363
566	963	363
567	963	365
568	963	393
569	963	394
570	963	395
571	963	396
572	963	332
573	963	397
574	963	374
575	963	398
576	964	363
577	965	363
578	966	363
579	967	363
580	968	363
581	969	363
582	970	363
583	971	363
584	972	363
585	973	363
586	974	363
587	975	363
588	977	382
589	977	399
590	977	196
591	977	1
592	977	335
593	978	1
594	979	400
595	979	401
596	979	213
597	979	402
598	979	117
599	979	403
600	979	404
601	979	64
602	979	405
603	979	406
604	979	407
605	979	408
606	979	409
607	979	1
608	979	410
609	979	411
610	979	412
611	980	117
612	981	117
613	982	117
614	983	117
615	984	117
616	985	117
617	986	117
618	987	117
619	989	413
620	989	414
621	989	415
622	989	416
623	989	117
624	989	417
625	990	117
626	991	117
627	992	117
628	996	355
629	996	47
630	996	1
631	999	418
632	999	419
633	999	420
634	999	421
635	1000	418
636	1000	422
637	1000	423
638	1000	421
639	1002	418
640	1003	418
641	1003	424
642	1003	425
643	1006	418
644	1006	426
645	1006	427
646	1006	419
647	1012	428
648	1012	418
649	1012	423
650	1007	418
651	1007	429
652	1007	419
653	1007	421
654	1008	430
655	1008	431
656	1008	432
657	1008	418
658	1008	433
659	1010	430
660	1010	418
661	1011	418
662	1011	423
663	1013	418
664	1013	434
665	1013	435
666	1014	418
667	1014	419
668	1015	418
669	1015	436
670	1015	437
671	1015	423
672	1016	418
673	1016	438
674	1017	418
675	1017	437
676	1017	423
677	1018	439
678	1018	418
679	1018	440
680	1018	423
681	1020	441
682	1020	323
683	1020	442
684	1024	443
685	1024	418
686	1024	423
687	1021	430
688	1021	432
689	1021	418
690	1023	430
691	1023	444
692	1023	432
693	1023	418
694	1023	423
695	1025	418
696	1025	445
697	1025	423
698	1026	446
699	1026	418
700	1026	442
701	1026	423
702	1027	446
703	1027	418
704	1028	430
705	1028	447
706	1028	432
707	1029	418
708	1029	436
709	1029	437
710	1029	423
711	1030	430
712	1030	418
713	1030	448
714	1030	423
715	1031	418
716	1031	449
717	1031	423
718	1032	450
719	1032	451
720	1032	418
721	1033	418
722	1033	419
723	1033	420
724	1033	423
725	1034	418
726	1034	442
727	1034	423
728	1035	418
729	1035	452
730	1035	423
731	1038	418
732	1038	453
733	1040	418
734	1040	427
735	1040	419
736	1040	454
737	1041	418
738	1041	436
739	1041	455
740	1041	423
741	1042	456
742	1042	418
743	1042	423
744	1044	444
745	1044	418
746	1044	423
747	1045	457
748	1045	418
749	1045	458
750	1046	447
751	1046	444
752	1046	432
753	1046	418
754	1046	453
755	1046	423
756	1047	430
757	1047	418
758	1047	423
759	1048	418
760	1048	426
761	1048	423
762	1049	430
763	1049	432
764	1050	418
765	1050	459
766	1050	460
767	1050	461
768	1050	423
769	1051	430
770	1051	432
771	1051	418
772	1051	462
773	1051	433
774	1051	453
775	1052	418
776	1052	463
777	1052	464
778	1052	423
779	1054	465
780	1054	466
781	1054	418
782	1057	418
783	1057	467
784	1057	423
785	1058	468
786	1058	418
787	1058	436
788	1058	423
789	1059	469
790	1059	418
791	1059	470
792	1059	471
793	1059	472
794	1060	430
795	1060	418
796	1060	453
797	1060	423
798	1061	418
799	1061	436
800	1061	437
801	1061	423
802	1062	456
803	1062	418
804	1062	473
805	1062	423
806	1063	418
807	1063	440
808	1064	418
809	1064	474
810	1064	423
811	1065	418
812	1065	475
813	1065	423
814	1066	418
815	1066	476
816	1066	419
817	1066	423
818	1067	430
819	1067	418
820	1067	423
821	1068	477
822	1068	430
823	1068	432
824	1068	418
825	1068	423
826	1069	418
827	1069	478
828	1069	436
829	1069	437
830	1069	423
831	1070	456
832	1070	418
833	1070	423
834	1071	479
835	1071	418
836	1072	418
837	1072	480
838	1072	423
839	1073	418
840	1073	436
841	1073	423
842	1074	418
843	1074	453
844	1074	423
845	1075	418
846	1075	481
847	1075	423
848	1076	418
849	1076	449
850	1077	430
851	1077	418
852	1077	448
853	1077	423
854	1078	418
855	1078	482
856	1078	427
857	1078	423
858	1079	418
859	1079	436
860	1079	423
861	1080	479
862	1080	418
863	1080	440
864	1080	483
865	1081	469
866	1081	418
867	1081	458
868	1082	418
869	1082	484
870	1083	418
871	1083	485
872	1083	421
873	1085	383
874	1085	486
875	1085	487
876	1086	488
877	1086	418
878	1087	489
879	1087	446
880	1087	418
881	1089	418
882	1089	490
883	1089	423
884	1090	491
885	1090	418
886	1090	492
887	1091	1
888	1092	493
889	1092	1
890	1092	494
891	1140	1
892	1140	3
893	1141	1
894	1141	3
895	1142	1
896	1144	495
897	1144	245
898	1144	1
899	1144	496
900	1158	1
901	1179	1
902	1187	497
903	1187	498
904	1187	499
905	1187	500
906	1187	501
907	1188	502
908	1188	503
909	1188	504
910	1188	62
911	1188	505
912	1188	506
913	1188	498
914	1188	507
915	1188	508
916	1188	509
917	1188	39
918	1188	510
919	1188	500
920	1188	511
921	1188	512
922	1188	513
923	1188	1
924	1188	514
925	1188	515
926	1188	257
927	1335	47
928	1335	1
929	1148	1
930	1148	48
931	1149	1
932	1149	48
933	1333	516
934	1333	47
935	1333	1
936	1333	342
937	1352	1
938	1369	3
939	1380	517
940	1380	518
941	1380	519
942	1380	520
943	1380	521
944	1389	1
945	1396	1
946	1400	117
947	1400	1
948	1417	1
949	1417	48
950	1465	522
951	1465	523
952	1465	47
953	1465	1
954	1465	48
955	1535	1
956	1535	3
957	1537	465
958	1537	47
959	1537	1
960	1545	524
961	1545	525
962	1545	526
963	1545	527
964	1545	528
965	1545	529
966	1545	530
967	1545	531
968	1545	532
969	1545	533
970	1547	1
971	1549	1
972	1550	47
973	1550	1
974	1551	534
975	1551	1
976	1551	66
977	1554	401
978	1554	266
979	1554	535
980	1554	536
981	1554	537
982	1554	538
983	1554	539
984	1554	540
985	1554	541
986	1554	542
987	1554	543
988	1554	544
989	1554	545
990	1554	546
991	1554	547
992	1554	548
993	1554	549
994	1554	550
995	1554	551
996	1554	552
997	1557	553
998	1557	554
999	1557	555
1000	1557	556
\.


--
-- Data for Name: movie_link; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.movie_link (id, movie_id, linked_movie_id, link_type_id) FROM stdin;
1	2	619801	6
2	50	1450538	10
3	50	257907	6
4	50	260637	6
5	50	766538	6
6	50	1102086	6
7	50	1303972	6
8	50	1425713	6
9	50	2342274	6
10	50	825167	8
11	53	1605183	5
12	53	2221955	5
13	53	670713	7
14	54	329187	5
15	55	1365902	5
16	57	2264395	5
17	58	2310522	5
18	59	572671	5
19	60	550482	5
20	64	529100	5
21	64	2447271	5
22	85	1946415	6
23	114	870705	13
24	118	764247	6
25	118	1834714	6
26	272	1719483	6
27	284	255424	10
28	284	327865	10
29	284	1423039	10
30	284	1611167	10
31	284	1952862	10
32	284	2002506	10
33	284	2153674	10
34	284	2454886	10
35	284	2371032	10
36	284	2496495	10
37	284	2514007	10
38	284	2348802	2
39	284	2407485	2
40	284	20479	6
41	284	185796	6
42	284	255424	6
43	284	542794	6
44	284	571360	6
45	284	968002	6
46	284	1054840	6
47	284	1439701	6
48	284	1465238	6
49	284	1648738	6
50	284	1654169	6
51	284	1783935	6
52	284	1952862	6
53	284	2407485	6
54	284	2423216	6
55	284	1633021	12
56	284	473276	8
57	284	786379	8
58	287	2197518	5
59	288	2407485	10
60	288	2373344	5
61	324	2216504	5
62	334	2407485	10
63	343	2407485	10
64	348	2407485	10
65	351	1330115	5
66	354	2407485	10
67	356	1745745	5
68	356	1901335	5
69	358	2407485	10
70	358	2407485	6
71	358	2374603	7
72	363	1745745	5
73	363	2379257	5
74	366	2407485	10
75	366	2407485	6
76	371	2021013	1
77	371	1866067	6
78	415	1885005	6
79	581	2431770	6
80	587	2216845	5
81	596	468938	6
82	596	1304949	6
83	596	1582586	6
84	599	165567	5
85	614	2310522	5
86	619	865520	5
87	619	1265371	5
88	619	2248081	5
89	619	2248100	5
90	619	2248101	5
91	620	1900233	5
92	622	848623	5
93	622	1295942	5
94	622	1938935	5
95	633	304077	5
96	633	627961	5
97	633	629027	5
98	633	1098074	5
99	633	1134529	5
100	651	685913	5
101	651	913358	5
102	651	2265125	5
103	654	1761898	5
104	654	2230317	5
105	656	1788966	5
106	656	1903725	5
107	656	2413074	5
108	658	1575520	5
109	662	1376991	5
110	664	2432099	9
111	665	453927	5
112	670	764216	5
113	670	1845488	5
114	681	2267134	10
115	695	760246	13
116	695	1239703	13
117	419	2202504	15
118	419	1623135	10
119	419	240097	2
120	419	2202504	6
121	419	429	4
122	420	431	4
123	421	433	4
124	423	439	4
125	424	446	4
126	425	451	4
127	426	436	4
128	428	1017969	6
129	428	461	4
130	429	328554	10
131	429	327926	10
132	429	327832	10
133	429	327844	10
134	429	328041	10
135	429	328118	10
136	429	328007	6
137	429	419	3
138	431	420	3
139	433	324409	5
140	433	421	3
141	436	426	3
142	439	423	3
143	446	424	3
144	451	425	3
145	461	428	3
146	469	1484067	3
147	814	1948697	9
148	814	2345020	9
149	860	1421642	13
150	860	2415996	13
151	907	1634291	2
152	907	1634292	2
153	907	1634294	2
154	907	934	1
155	907	963	1
156	907	1634290	1
157	907	1634303	1
158	907	1634305	1
159	907	1634306	1
160	934	676284	10
161	934	907	2
162	934	963	2
163	934	1634290	2
164	934	1634291	2
165	934	1634292	2
166	934	1634294	2
167	934	1634302	2
168	934	1634303	2
169	934	1634304	2
170	934	1634305	2
171	934	1634306	2
172	934	1634290	6
173	934	2253591	6
174	934	2516108	6
175	934	1634297	12
176	963	907	2
177	963	1634291	2
178	963	1634292	2
179	963	1634294	2
180	963	934	1
181	963	1634290	1
182	963	1634303	1
183	963	1634305	1
184	963	1634306	1
185	1091	6815	13
186	1091	54168	13
187	1091	1523213	13
188	1144	1629778	10
189	1144	2215710	10
190	1144	195529	6
191	1144	2215709	6
192	1144	8459	11
193	1179	740429	13
194	1334	700253	13
195	1334	815770	13
196	1334	1106075	13
197	1334	1123589	13
198	1334	1519788	13
199	1334	1519827	13
200	1370	1450417	10
201	1148	1149	13
202	1148	1157	13
203	1148	1417	13
204	1148	1465	13
205	1149	1148	13
206	1149	1157	13
207	1149	1417	13
208	1149	1465	13
209	1157	1148	13
210	1157	1149	13
211	1157	1417	13
212	1157	1465	13
213	1379	1971860	13
214	1413	1005207	10
215	1417	1036385	10
216	1417	1582318	6
217	1417	1148	13
218	1417	1149	13
219	1417	1157	13
220	1417	1465	13
221	1421	1456727	5
222	1423	2339786	5
223	1429	1144027	5
224	1447	1582306	5
225	1465	11121	10
226	1465	1927859	10
227	1465	1349976	6
228	1465	1582495	6
229	1465	1148	13
230	1465	1149	13
231	1465	1157	13
232	1465	1417	13
233	1537	1633837	8
234	1537	1547	13
235	1547	1537	13
236	1549	10238	13
237	1549	358166	13
238	1549	1522017	13
239	1561	2495238	5
240	1564	304077	5
241	1565	1570	1
242	1570	1565	2
243	1633	2053116	6
244	1636	1634679	2
245	1674	2496495	10
246	1760	2399527	10
247	1865	180202	10
248	1865	1450454	10
249	1865	1450825	10
250	1865	1767259	1
251	1889	254369	7
252	1889	865771	7
253	2025	1634838	1
254	2025	1717850	6
255	2025	1634838	11
256	2026	498932	5
257	2026	1711584	5
258	2028	1394139	5
259	2028	1916434	5
260	2028	2245832	5
261	2029	1229453	5
262	2029	2280732	5
263	2031	1046886	5
264	2031	1708057	5
265	2031	1732333	5
266	2031	2398001	5
267	2031	2508593	5
268	2030	315481	5
269	2030	1405588	5
270	2030	1440807	5
271	2032	15711	5
272	2032	550482	5
273	2032	1918731	5
274	2032	2159685	5
275	2033	875508	5
276	2033	891166	5
277	2033	2248101	5
278	2033	2413592	5
279	2034	1369290	5
280	2034	1903725	5
281	2034	2245279	7
282	2035	7383	5
283	2035	824382	5
284	2035	1144027	5
285	2035	2447271	5
286	2036	1440097	5
287	2036	1930676	5
288	2036	2006899	5
289	2036	2291275	5
290	2037	846246	5
291	2037	1938944	5
292	2037	2376232	5
293	2038	1923855	5
294	2038	2121975	5
295	2038	2310581	5
296	2038	2490166	5
297	2039	440572	5
298	2039	812142	5
299	2039	1761343	5
300	2039	2373344	5
301	2039	2445639	5
302	2040	1046886	5
303	2040	1846684	5
304	2040	2006991	5
305	2040	2100909	5
306	2040	2291275	5
307	2040	2310581	5
308	2040	2367745	5
309	2040	2455451	5
310	2041	1420203	5
311	2042	831499	5
312	2042	2310522	5
313	2042	2319361	5
314	2043	653772	5
315	2043	1503704	5
316	2043	1284778	7
317	2044	8805	5
318	2044	1124384	5
319	2045	383079	5
320	2045	752369	5
321	2045	1279105	5
322	2045	1342803	5
323	2045	1356576	5
324	2045	2310522	5
325	2045	2419110	5
326	2076	1131858	10
327	2076	1131859	10
328	2076	141554	6
329	2076	2349481	6
330	1826	1949184	5
331	2279	2280	1
332	2280	2279	2
333	2417	1869871	6
334	2417	509963	8
335	2578	1956230	5
336	2579	1956228	5
337	2608	126283	9
338	2608	138084	9
339	2608	898205	9
340	2608	1181799	9
341	2608	1413155	9
342	2608	1893991	9
343	2608	1897136	9
344	2608	2263380	9
345	2608	2492990	9
346	2638	1131857	10
347	2649	1165681	5
348	2649	2091640	5
349	2651	138929	9
350	2651	1175216	9
351	2651	536744	5
352	2651	1531116	5
353	2652	300725	9
354	2652	1938000	9
355	2652	2169573	9
356	2652	2173128	9
357	2652	2250852	9
358	2652	2313916	9
359	2652	1289444	5
360	2652	2292805	5
361	2652	2334483	5
362	2653	188871	9
363	2653	670713	9
364	2653	1631186	5
365	2654	2268810	9
366	2654	2381188	9
367	2654	1692334	5
368	2654	1926704	5
369	2654	2373344	5
370	2655	1737669	9
371	2655	2159591	9
372	2655	128671	5
373	2655	244970	5
374	2655	1643295	5
375	2660	1731085	5
376	2661	2006991	5
377	2663	1015917	5
378	2663	1536773	5
379	2663	1741592	5
380	2663	2059231	5
381	2664	1029869	9
382	2664	1708057	5
383	2665	613288	9
384	2665	2101296	9
385	2665	942208	5
386	2665	1009081	5
387	2665	1673834	5
388	2665	2444013	5
389	2666	1960398	9
390	2666	578770	5
391	2666	1817167	5
392	2667	1934756	5
393	2668	760557	5
394	2668	1140377	5
395	2668	1934756	5
396	2669	1140377	5
397	2669	1144027	5
398	2670	133643	5
399	2670	2263380	5
400	2671	1814226	5
401	2672	1869903	5
402	2672	2012989	5
403	2672	2205804	5
404	2672	2254593	5
405	2672	2313916	5
406	2672	2381617	5
407	2672	2434426	5
408	2673	1908635	5
409	2673	2310573	5
410	2675	1908160	5
411	2675	2328100	5
412	2676	587140	5
413	2676	995199	5
414	2676	1934756	5
415	2676	2296840	5
416	2682	793763	9
417	2682	133643	5
418	2682	715500	5
419	2682	1511525	5
420	2682	1911420	5
421	2682	2006899	5
422	2683	524905	5
423	2683	764216	5
424	2683	902993	5
425	2683	905182	5
426	2683	1215811	5
427	2683	1681290	5
428	2683	1791052	5
429	2683	2430389	5
430	2786	468465	17
431	2909	1635540	2
432	2909	1635540	6
433	2910	2163844	1
434	2918	2920	13
435	2920	2918	13
436	2931	2360547	6
437	3201	1264453	10
438	3201	1635320	11
439	3201	2175448	11
440	3258	1295942	5
441	3258	1315456	5
442	3258	1417866	5
443	3258	2231581	5
444	3320	3327	3
445	3327	3320	4
446	3327	1635370	13
447	3329	1635355	4
448	3329	1635375	4
449	3329	1635377	4
450	3342	11235	6
451	3342	223038	6
452	3342	1295521	6
453	3342	1448011	6
454	3342	2302825	6
455	3342	1124836	8
456	3585	1132875	6
457	3585	1475533	6
458	3681	4033	2
459	3681	4455	2
460	3682	1929181	10
461	4033	4455	2
462	4033	3681	1
463	4209	2455262	1
464	4039	4041	4
465	4041	4039	3
466	4288	1693247	10
467	4288	1184907	11
468	4440	1635752	3
469	4440	1992027	3
470	4440	2015638	3
471	4440	2053452	3
472	4440	2311339	8
473	4440	1635651	13
474	4440	1635752	13
475	4440	1635753	13
476	4440	1635959	13
477	4440	1635956	13
478	4440	1668873	13
479	4440	1805482	13
480	4440	1849713	13
481	4440	1992027	13
482	4440	2015638	13
483	4440	2033073	13
484	4440	2053452	13
485	4440	2291441	13
486	4440	2422085	13
487	4440	2522419	13
488	4445	1035541	6
489	4455	3681	1
490	4455	4033	1
491	4482	2362524	15
492	4566	4609	1
493	4609	4566	2
494	4609	2225713	8
495	4634	2262132	5
496	4714	748669	11
497	4729	1643220	1
498	4731	4739	11
499	4734	2323024	10
500	4734	2222831	6
501	4745	256741	10
502	4745	1131857	10
503	4738	4739	11
504	4739	4731	12
505	4739	4738	12
506	4859	138736	10
507	4859	138813	10
508	4859	138855	10
509	4859	138836	6
510	4859	138874	6
511	4859	227144	6
512	4859	227254	6
513	4859	675083	6
514	4859	1065953	6
515	4859	1124553	6
516	4859	1124814	6
517	4859	1303939	6
518	4859	1432248	6
519	4859	1432510	6
520	4859	1432912	6
521	4859	1432937	6
522	4859	1491770	6
523	4859	2473196	6
524	4859	1125020	8
525	4859	1432404	8
526	4921	1258557	1
527	4950	5192	2
528	4992	227195	10
529	4992	1433108	10
530	4992	1433133	10
531	4992	1433140	10
532	4992	599418	6
533	4992	825135	8
534	5022	260872	6
535	5022	1071884	6
536	5022	1124625	6
537	5022	1124768	6
538	5022	1432236	6
539	5022	1636754	12
540	5192	4950	1
541	5229	2275466	11
542	5378	1123647	2
543	5494	878820	10
544	5515	5520	2
545	5515	5527	2
546	5520	5527	2
547	5520	5515	1
548	5527	5515	1
549	5527	5520	1
550	5547	446227	6
551	5547	1041699	6
552	5591	1041702	10
553	5591	446227	6
554	5591	1041699	6
555	5618	1197102	6
556	5639	1742001	15
557	5639	2313539	15
558	5712	446227	6
559	5764	1742001	15
560	5764	1041702	10
561	5764	446227	6
562	5764	1041699	6
563	5764	2313539	6
564	5772	1041702	10
565	5778	1041686	10
566	5797	1041678	10
567	5830	1041686	10
568	5873	5891	2
569	5873	5913	2
570	5873	5932	2
571	5873	5952	2
572	5873	7751	2
573	5873	1637357	2
574	5873	1637376	2
575	5873	1637581	2
576	5873	1638445	2
577	5873	1638497	2
578	5873	1636792	1
579	5873	2506545	1
580	5873	2506546	1
581	5891	5913	2
582	5891	5932	2
583	5891	5952	2
584	5891	7751	2
585	5891	1637357	2
586	5891	1637376	2
587	5891	1637581	2
588	5891	1638445	2
589	5891	1638497	2
590	5891	5873	1
591	5891	1636792	1
592	5891	2506545	1
593	5891	2506546	1
594	5902	1041678	10
595	5902	1763248	10
596	5910	15711	5
597	5913	5932	2
598	5913	5952	2
599	5913	7751	2
600	5913	1637357	2
601	5913	1637376	2
602	5913	1637581	2
603	5913	1638445	2
604	5913	1638497	2
605	5913	5873	1
606	5913	5891	1
607	5913	1636792	1
608	5913	2506545	1
609	5913	2506546	1
610	5932	1041678	10
611	5932	5952	2
612	5932	7751	2
613	5932	1637357	2
614	5932	1637376	2
615	5932	1637581	2
616	5932	1638445	2
617	5932	1638497	2
618	5932	5873	1
619	5932	5891	1
620	5932	5913	1
621	5932	1636792	1
622	5932	2506545	1
623	5932	2506546	1
624	5936	1041686	10
625	5944	1041686	10
626	5952	1041678	10
627	5952	1763248	10
628	5952	1888365	10
629	5952	1910055	10
630	5952	7751	2
631	5952	1637357	2
632	5952	1637376	2
633	5952	1637581	2
634	5952	1638445	2
635	5952	1638497	2
636	5952	5873	1
637	5952	5891	1
638	5952	5913	1
639	5952	5932	1
640	5952	1636792	1
641	5952	2506545	1
642	5952	2506546	1
643	5952	11219	6
644	5952	446227	6
645	5952	1041699	6
646	5952	2065490	6
647	5952	2357555	6
648	5978	890735	10
649	5979	1409348	5
650	5979	1793730	5
651	5991	6023	2
652	6023	5991	1
653	6045	852191	11
654	6065	1041686	10
655	6073	1409348	5
656	6083	10561	10
657	6109	1409348	5
658	6110	1409348	5
659	6112	10581	10
660	6126	7718	2
661	6126	1637600	2
662	6126	1637630	2
663	6126	1638389	2
664	6126	1638570	2
665	6126	1638721	2
666	6126	1637214	1
667	6126	1637232	1
668	6126	1637251	1
669	6126	1637273	1
670	6126	1637295	1
671	6126	1637319	1
672	6126	1637336	1
673	6126	1637352	1
674	6126	1637369	1
675	6126	1637392	1
676	6126	1637422	1
677	6126	1637439	1
678	6126	1637455	1
679	6126	1637484	1
680	6126	1637503	1
681	6126	1637522	1
682	6126	1637548	1
683	6132	8046	2
684	6132	8066	2
685	6132	1268086	2
686	6132	1268096	2
687	6142	1041686	10
688	6198	2288073	10
689	6340	2276653	5
690	6370	1085019	6
691	6370	1085032	6
692	6370	1085037	6
693	6370	1085069	6
694	6370	1085080	6
695	6433	1064643	10
696	6578	697882	5
697	6597	227257	10
698	6597	260548	6
699	6597	675065	6
700	6597	868633	6
701	6597	1124799	6
702	6597	1392550	6
703	6597	1432897	6
704	6597	1432949	6
705	6597	1491805	6
706	6597	1581254	6
707	6597	825172	8
708	6597	1304920	8
709	6600	1894592	5
710	6601	2120965	5
711	6601	2385726	7
712	6604	765020	10
713	6605	1088054	5
714	6606	52894	5
715	6606	796570	5
716	6606	1851357	5
717	6610	1708057	5
718	6612	288963	5
719	6612	550482	5
720	6612	632181	5
721	6612	1688429	5
722	6612	2310522	5
723	6612	2495584	5
724	6613	1761343	5
725	6613	2498675	5
726	6616	346879	5
727	6617	768288	5
728	6618	670713	5
729	6620	509067	5
730	6620	627817	5
731	6624	1181799	5
732	6624	1735202	5
733	6625	1131934	5
734	6625	1583175	5
735	6626	577922	5
736	6626	686755	5
737	6626	1681159	5
738	6626	1761898	5
739	6626	2412346	5
740	6627	2310522	5
741	6627	2339030	5
742	6627	2373367	5
743	6627	2392833	5
744	6628	329187	5
745	6628	2232891	5
746	6628	2367748	5
747	6629	180602	5
748	6629	1181799	5
749	6630	766471	10
750	6631	605162	5
751	6631	2518791	5
752	6632	1481593	5
753	6632	2265125	5
754	6632	2278472	5
755	6632	2487769	5
756	6632	1404901	7
757	6635	752827	5
758	6635	2413592	5
759	6635	2438934	5
760	6636	2137345	5
761	6636	2264502	5
762	6636	2326006	5
763	6636	2404748	5
764	6637	1082953	5
765	6641	1756122	5
766	6641	2263380	5
767	6641	2302013	5
768	6641	2372921	5
769	6642	829065	5
770	6642	1771985	5
771	6642	1991774	5
772	6642	2120965	5
773	6642	2265984	5
774	6642	2310581	5
775	6646	675702	5
776	6646	2353258	5
777	6646	2411124	5
778	6727	583610	10
779	6727	1415720	1
780	6739	1664680	5
781	6739	2203859	5
782	6753	2365137	7
783	6815	813202	4
784	6815	1091	13
785	6815	54168	13
786	6815	1523213	13
787	7279	1638265	4
788	7302	1427940	9
789	7302	1648540	9
790	7302	1659801	9
791	7302	1692334	9
792	7302	1692415	9
793	7302	1703418	9
794	7302	1715497	9
795	7302	1744277	9
796	7302	1761898	9
797	7302	1788292	9
798	7302	1793730	9
799	7302	1811349	9
800	7302	1834182	9
801	7302	1834312	9
802	7302	1844175	9
803	7302	1851357	9
804	7302	1889101	9
805	7302	1899268	9
806	7302	1916434	9
807	7302	1916691	9
808	7302	1919906	9
809	7302	1923289	9
810	7302	1923317	9
811	7302	1923855	9
812	7302	1924419	9
813	7302	1997177	9
814	7302	1999081	9
815	7302	2135631	9
816	7302	2172188	9
817	7302	2173226	9
818	7302	2174229	9
819	7302	2209887	9
820	7302	2221955	9
821	7302	2222831	9
822	7302	2248081	9
823	7302	2265125	9
824	7302	2276984	9
825	7302	2280291	9
826	7302	2310522	9
827	7302	2319361	9
828	7302	2334537	9
829	7302	2342696	9
830	7302	2351090	9
831	7302	2354968	9
832	7302	2365137	9
833	7302	2373344	9
834	7302	2382255	9
835	7302	2387681	9
836	7302	2392547	9
837	7302	2412582	9
838	7302	2413074	9
839	7302	2413673	9
840	7302	2415653	9
841	7302	2419110	9
842	7302	2421731	9
843	7302	2427608	9
844	7302	2438179	9
845	7302	2443131	9
846	7302	2486802	9
847	7302	2495584	9
848	7302	152916	5
849	7302	1277087	5
850	7302	1643295	5
851	7302	1885397	5
852	7303	16802	9
853	7303	279622	9
854	7303	304077	9
855	7303	392756	9
856	7303	806746	9
857	7303	887264	9
858	7303	920989	9
859	7303	1481193	9
860	7303	1706976	9
861	7303	1727013	9
862	7303	1793730	9
863	7303	1877038	9
864	7303	1882250	9
865	7303	1893991	9
866	7303	2078222	9
867	7303	2197818	9
868	7303	2230317	9
869	7303	2433945	9
870	7303	2506221	9
871	7303	1633054	5
872	7303	1737708	5
873	7303	1909852	5
874	7303	2093444	5
875	7303	2233737	5
876	7303	2514837	5
877	7305	126968	9
878	7305	141334	9
879	7305	277661	9
880	7305	442101	9
881	7305	426055	9
882	7305	866384	9
883	7305	1124384	9
884	7305	1459905	9
885	7305	1481193	9
886	7305	1569808	9
887	7305	1641532	9
888	7305	1703430	9
889	7305	1762263	9
890	7305	1768148	9
891	7305	1768149	9
892	7305	1827186	9
893	7305	1844175	9
894	7305	1870095	9
895	7305	1874404	9
896	7305	1914314	9
897	7305	2052965	9
898	7305	2056353	9
899	7305	2085021	9
900	7305	2132092	9
901	7305	2175256	9
902	7305	2226756	9
903	7305	2263380	9
904	7305	2327039	9
905	7305	2342658	9
906	7305	2392547	9
907	7305	2411917	9
908	7305	2429795	9
909	7305	2430389	9
910	7305	2477923	9
911	7305	2508619	9
912	7305	1488641	5
913	7305	2222831	5
914	7306	1477549	9
915	7306	1703418	9
916	7306	2155087	9
917	7306	2370967	9
918	7306	2408892	9
919	7306	279622	5
920	7307	1670861	9
921	7307	1674610	9
922	7307	1681355	9
923	7307	1703430	9
924	7307	1740617	9
925	7307	1741164	9
926	7307	1744277	9
927	7307	1773690	9
928	7307	1884751	9
929	7307	1889101	9
930	7307	2073974	9
931	7307	2121654	9
932	7307	2222215	9
933	7307	2327039	9
934	7307	2342638	9
935	7307	2351024	9
936	7307	2370967	9
937	7307	2413074	9
938	7307	2430389	9
939	7307	2501106	9
940	7307	2504666	9
941	7307	1674791	5
942	7308	1654252	9
943	7308	1674610	9
944	7308	1674814	9
945	7308	1703418	9
946	7308	1771765	9
947	7308	1796087	9
948	7308	1844333	9
949	7308	1844340	9
950	7308	1901335	9
951	7308	1901341	9
952	7308	1903720	9
953	7308	1903725	9
954	7308	1922177	9
955	7308	1922712	9
956	7308	1928392	9
957	7308	1928395	9
958	7308	1934756	9
959	7308	1987586	9
960	7308	1997177	9
961	7308	2020394	9
962	7308	2020396	9
963	7308	2020397	9
964	7308	2104674	9
965	7308	2153790	9
966	7308	2160299	9
967	7308	2215081	9
968	7308	2221955	9
969	7308	2233737	9
970	7308	2350065	9
971	7308	2350819	9
972	7308	2369807	9
973	7308	2369808	9
974	7308	2388527	9
975	7308	2413074	9
976	7308	2455451	9
977	7308	2121654	5
978	7308	2199439	5
979	7308	2323856	5
980	7308	2412582	5
981	7309	223619	9
982	7309	883241	9
983	7309	953521	9
984	7309	1137836	9
985	7309	1183804	9
986	7309	1394139	9
987	7309	1468129	9
988	7309	1605183	9
989	7309	1673809	9
990	7309	1681356	9
991	7309	1713087	9
992	7309	1740617	9
993	7309	1746975	9
994	7309	1768148	9
995	7309	1768149	9
996	7309	1794536	9
997	7309	1870095	9
998	7309	1904639	9
999	7309	2132092	9
1000	7309	2155087	9
\.


--
-- Data for Name: name; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.name (id, name, imdb_tiny_index, imdb_tiny_id, gender, name_pcode_cf, name_pcode_nf, surname_pcode, md5sum) FROM stdin;
3343	Abela, Mike	\N	\N	m	A1452	M214	A14	61f733c0298a7cb5a461fd787a655d70
446	A., David	\N	\N	m	A313	D13	A	cf45e7b42fbc800c61462988ad1156d2
126	-Alverio, Esteban Rodriguez	\N	\N	m	A4162	E2315	A416	f5c410bff6839b545d04c531f776e8f2
1678	Abbas, Athar	\N	\N	m	A1236	A3612	A12	cf230f6ed718a330dc688c20b8d741d3
3610	Aberer, Leo	\N	\N	m	A164	L16	A16	05684f16b84db387e613d3de57eca5b7
506	A.J.	II	\N	m	A2	\N	\N	c63baf59b537e471b6ec4b68c5d1373e
465	A., Narayana Rao	\N	\N	m	A5656	N656	A	c7a6b13ba56547bd0a1c352171b2d0c2
3612	Aberg, Siv Marta	\N	\N	m	A1621	S1563	A162	eda04e0a59f7548878f2663eeb02164e
1932	Abbot Jr., Greg	\N	\N	m	A1326	G6213	\N	f3c72bdb04a43aae7af1424c261d50ff
2266	Abdalla, Isam	\N	\N	m	A1342	I2513	A134	22eb3783f3ff2ec3554311899f152960
3495	Abelló, Pere	\N	\N	m	A1416	P614	A14	32fe0093331bbac8cffaac6260b35d23
2364	Abdel, Neder	\N	\N	m	A1345	N3613	A134	650043b0567c05a6671bfe63b0e13160
3468	Abelle, Fidel	\N	\N	m	A1413	F3414	A14	54117abdacef0c430339e80dd77039b6
2945	Abduller, Abdumin	\N	\N	m	A1346	A1351	\N	cc6e673a092793548021aea271ae0a49
1438	Abarbanell, Eric	\N	\N	m	A1615	E6216	\N	1c5d69bac758bd93e8752cbb64f8de60
746	Aames, Bruce	\N	\N	m	A5216	B6252	A52	2c456bea1597e3291a30e4b40972aaa8
2138	Abbott, Reece	\N	\N	m	A1362	R213	A13	446f5e31d53e84abbede328c0374cd6b
3475	Abellira, Remi	\N	\N	m	A1465	R5146	A146	e36f700ab78865590b68fbaf1eddd4e2
373	78 Plus	\N	\N	m	P42	\N	\N	1740dc46b0120dc8fd73af48c658430f
1175	Abad, Andrew	\N	\N	m	A1353	A5361	A13	e64742d4900b8954aed9497139f23eab
1293	Abadii, Eksander	\N	\N	m	A1325	E2536	A13	39f5936e2f268ee3790eb45aba43ddd8
2923	Abdullayev, Elvin	\N	\N	m	A1341	E4151	\N	966904fe0f031b6865b1adbe2e1a00fe
906	Aaron, James	II	\N	m	A6525	J5265	A65	f9bc627c4dbe9e4b87e05e63e8c58deb
1461	Abarno, José María	\N	\N	m	A1652	J2561	A165	3312cb678052ecfed74c18ab3551ea6c
175	10CC	\N	\N	m	C2	\N	\N	fef9ccd06e5a016078ac9d9ca705507f
132	., Daniyar	\N	\N	m	D56	\N	\N	5e50f0de347425b9c7b76695cc136ba0
1479	Abascal, José Manuel	\N	\N	m	A1242	J2541	A124	369ac8ce4b3d67b757d98d661350ed69
2442	Abdelkader, Ghannam	\N	\N	m	A1342	G5134	\N	2222c78c133b9b75e7747daf7b3ac002
2259	Abdalla, Abrahão	\N	\N	m	A1341	A1613	A134	ec5de1fba38c334082fa447e0fe62930
1554	Abatiell, Robert	\N	\N	m	A1346	R1631	A134	3e384becc5593f997298bddec9346ce4
809	Aaren, Leslie	\N	\N	m	A6542	L2465	A65	28a047523ef05688e3999e63c40b0397
2525	Abderahmane, Slimane Hadj	\N	\N	m	A1365	S4532	\N	948e31eaa324e27b3f98b68413d8ff3d
2406	Abdelgani, Hassan	\N	\N	m	A1342	H2513	\N	6f64b9a0796e9fa9f011d38ab034f2b3
400	A El Rahim, Ahmed	\N	\N	m	A4653	A5346	A465	9698c31ec0eb8b38172ae89e8c67b028
3516	Abelson, Arthur	\N	\N	m	A1425	A6361	\N	f928320c2a7a7bed50ce782fb256c276
2503	Abdelnour, Miranda	\N	\N	m	A1345	M6531	\N	699eccee2b46311e4575ec59e32e8e97
580	Aafaq	\N	\N	m	A12	\N	\N	1072898cd814fabd0b58e8399e7c9487
3628	Aberle, Norbert	\N	\N	m	A1645	N6163	A164	7be02e5a22667f99171528bc0f6774c1
133	., Dian Aisyah	\N	\N	m	D52	\N	\N	7107d4dce877b981e996078631bff681
3589	Abercrombie, John	\N	\N	m	A1626	J5162	\N	d8282bd038fd46b8af3d32ff8b1fbe57
242	2Mex	\N	\N	m	M2	\N	\N	9908e29f69fdd0ce98c50b69215846ec
2272	Abdalla, Seif	\N	\N	m	A1342	S134	A134	45325dcb13de7517d8fef049847c29b2
3634	Aberman, Larry	II	\N	m	A1654	L6165	A165	806b07df90a06586cf3831e06a61ab5d
2433	Abdelhussein, Uday Hussein	\N	\N	m	A1342	U3251	\N	4360aabe130a4932f017acc520df6a44
2757	Abdul-Khaliq, Asad	\N	\N	m	A1342	A2313	\N	db45f72ef56d1979e021feb479869ae2
221	2000, Spoiler	\N	\N	m	S146	\N	\N	ade2aad58b662b680f650b0d9f28bb52
399	A Camp	\N	\N	m	A251	\N	\N	136467262063314d518405f98405e671
3380	Abelenda, Federico	\N	\N	m	A1453	F3621	\N	38f0c79fb7daef087f8280fab216e224
35	'El Happy' Lora, Miguel	\N	\N	m	E4146	M2414	\N	4d04196e6b407211a1685f2556fd8da3
1126	Aatsinki, Aarne	\N	\N	m	A3252	A6532	\N	29e673ba4ce4812cdf0538f23bea8ce3
1981	Abbott, Brady	\N	\N	m	A1316	B6313	A13	1a2f450f56aea631aff2aedbbf99116d
1380	Abalos Reznak, Julia	\N	\N	m	A1426	J4142	\N	0a01f5d7887b72f7d5fbca53fdbb608f
1621	Abazoglu, Cengiz	\N	\N	m	A1242	C5212	A124	c84cc2037adfd1096e6d96b330a663a1
3097	Abe, Shirô	\N	\N	m	A126	S61	A1	e4666f8098ee46ee56429c349881f04c
2112	Abbott, Michael	XII	\N	m	A1352	M2413	A13	a56b7b7cac4f1be7d7cea0d056fe9d3c
23	'Chincheta', Eloy	\N	\N	m	C5234	E4252	C523	4464187c8580d534a512650e985e3c26
3267	Abel, Jean-Luc	\N	\N	m	A1425	J5421	A14	5b100a9d2589b0f8934b9e077e749ee7
1866	Abbey, Carfax	\N	\N	m	A1261	C6121	A1	a16b8233c82de153805a01a3ccf645eb
1724	Abbas, Qamar	\N	\N	m	A1256	Q5612	A12	4b8c8e7901e0425fb1efae662f3927ab
2981	Abdurachman, A.	\N	\N	m	A1362	\N	\N	e7a52a4bf9ef6a08a3c14ca170ec48bd
3492	Abellán, José Antonio	I	\N	m	A1452	J2535	A145	e57dff57084000ca865b9a4869e5c9ec
1520	Abata, Billie	\N	\N	m	A1314	B413	A13	a808220db977673c39578bc298a99c01
1012	Aarseth, Øystein	\N	\N	m	A6232	Y2356	A623	0f7dda0d0a75d5de3d3a77b11897a17a
2006	Abbott, Craig	\N	\N	m	A1326	C6213	A13	d93a9cfee0619f3c7bdae146ff4ff698
1180	Abad, Arthur	\N	\N	m	A1363	A6361	A13	99bc0c691bab5a86ccd0199888f70f27
2674	Abdu'allah, Faisal	\N	\N	m	A1341	F2413	A134	7b37c92db7b8e535847a3ffcb3b12807
658	Aalija	\N	\N	m	A42	\N	\N	fe3912f7111e7074d767d8e036214a69
957	Aaron, Tommie	\N	\N	m	A6535	T565	A65	6415a18998fdb9fdbd17436be462af66
96	't Hout, Rogier in	\N	\N	m	T3626	R2653	T3	88eeaea4b9b55576950fc4a407a33363
1789	Abbaszade, Fuad	\N	\N	m	A1231	F3123	A123	a55611977c5bd77388d40b5c6bcab696
2828	Abdullaev, Allovuddin	\N	\N	m	A1341	A4135	\N	b101f906445dda9d9e5e0a562475467b
3318	Abel, Tommy	\N	\N	m	A1435	T514	A14	175225d2059a3bbf86739c49f82b8c32
359	666, Portia	\N	\N	m	P63	\N	\N	fc73c448deeb400b177cfc9211d18309
240	2K, Charon	\N	\N	m	K265	C652	K	17d1583f1f546b1731d80742a107f1b8
309	4Granted	\N	\N	m	G653	\N	\N	813a1adc8d19c272cf9322ffbcbe1238
3441	Abella, Gene	IV	\N	m	A1425	G514	A14	7d16344779dcfa7f00c0dc415c95afe7
3481	Abello, John	\N	\N	m	A1425	J514	A14	87453157f6e15379b73e2d4f14e943cc
421	A-Ha	\N	\N	m	A	\N	\N	6adbd3552c41454a35217369753f0be1
1104	Aasheim, Erik	\N	\N	m	A2562	E625	A25	8c2664bcb69bf603014057546e712982
3389	Abeles, Ethan	\N	\N	m	A1423	E3514	A142	c6fd4a13aec360f5c9ee278bcd5a3a96
1566	Abatzis, T.	\N	\N	m	A1323	T132	A132	573e5bfed7b1d133277a81a1fb51ada2
3456	Abellan, Alejandro	\N	\N	m	A1454	A4253	A145	bf61be49952dd081fb1b79f64a1d504a
32	'El Galgo PornoStar', Blanquito	\N	\N	m	E4242	B4523	\N	719cc1f79b6d97ade3e37fe8a19d7084
1387	Abalos, Jorge	\N	\N	m	A1426	J6214	A142	6c6ec8da7c56abfa138a5235a606fb07
1522	Abatayo, Eman	\N	\N	m	A135	E513	A13	7b8c8d081627065428acde3753543691
1692	Abbas, Hanneen	\N	\N	m	A125	H512	A12	7f7caa660ed33220c91b184e5398c32e
1221	Abad, Manuel	\N	\N	m	A1354	M5413	A13	f42503b7de3bb1923a6353a01812c94a
1540	Abate, Renato	\N	\N	m	A1365	R5313	A13	c7184923280113e9481b84cc564799e9
2794	Abdulhamid, Ammar	\N	\N	m	A1345	A5613	\N	6219175cf90567f0a79392ab2f001cbe
2159	Abbott, Steve	I	\N	m	A1323	S313	A13	e1976a0105d88ebb4fb2c99d86b5d7e8
1627	Abazovic, Hamid	\N	\N	m	A1212	H5312	\N	72d537337ac0f5396cf43fd50b8cf6b5
108	'Ulaleo, Ka'olelo	\N	\N	m	U424	K4	U4	62266e353ae2c862d981cd2bb388d5eb
271	33 1/3	\N	\N	m	\N	\N	\N	889c14a55236851f4bf9674b90d36bf1
2486	Abdelmajid, Drifi	\N	\N	m	A1345	D6134	\N	45b725bd6becd60f96340359da99f946
1557	Abato, Paul V.	\N	\N	m	A1314	P413	A13	6ba58b5479415e8388fb92c6be446467
3211	Abeghraz, Rachid	\N	\N	m	A1262	R2312	\N	2b054445d528ca9f6994adedd9db9722
2129	Abbott, Percy	\N	\N	m	A1316	P6213	A13	7992faa0fc9acd53bebbb68549f9360a
1167	Abacan, Jose Mari	\N	\N	m	A1252	J2561	A125	06f8d8a8e7df8e7887ea7e7c7a671b8c
331	5, Channel	\N	\N	m	C54	\N	\N	4db55ab39bb71cbe53eda4eacb768705
2482	Abdellnebi, Bachir	\N	\N	m	A1345	B2613	\N	27768f67fc42d4b61ff5ed1032edf03b
3430	Abella, Benjamin	\N	\N	m	A1415	B5251	A14	d2ba235e22a3d3e6616af5b85bd70a22
3566	Aber, Johnny	\N	\N	m	A1625	J516	A16	39ead6bf297bae4508ac1d9e86071e85
1160	Ababei, Claudiu	\N	\N	m	A1243	C431	A1	465beb76b239efe7c93434c5b2336d83
1502	Abasolo, Roland T.	\N	\N	m	A1246	R4531	A124	222a7171fc4c2c3d1ac7a79cd0010ae0
540	Aabear, Jim	\N	\N	m	A1625	J516	A16	8a2399fbc6fd356ba14bb2896e6ee909
1062	Aas, Harald	\N	\N	m	A2643	H6432	A2	4cf2d085ce81026b36f6364842590098
546	Aabentoft, Palle	\N	\N	m	A1531	P4153	\N	68da7beba50a40c825a547fde0526c3a
1408	Abandoned Pools	\N	\N	m	A1535	\N	\N	aa3107f01c213dea8627c1245eba55bd
224	2004-2005 City Year New York Corps Members	\N	\N	m	C3656	\N	\N	ab909bc372fafa6de5f87b6a5e4beddc
2695	Abdul Al-Khabyyr, Nasyr	\N	\N	m	A1342	N2613	\N	eb0b6e9bb93fdd56ca0ade28eda495fe
3266	Abel, Jean	\N	\N	m	A1425	J514	A14	98eec373871ff14ca9d72b845f2f21b7
3350	Abelanski, Lionel	\N	\N	m	A1452	L5414	\N	59bca78216fdab5d512e1baccdfa79a8
2451	Abdelke, Yusef	\N	\N	m	A1342	Y2134	\N	c8448f8f24eeebc0eb7a4993394b83f5
1118	Aasli, Samir	\N	\N	m	A2425	S5624	A24	6b4660ebafff850ae06c624b74364215
1988	Abbott, Bryan	\N	\N	m	A1316	B6513	A13	bd896bd4a2f561d520e57666c545cb50
926	Aaron, Mark	II	\N	m	A6562	M6265	A65	12ecdc79d796be0454241693aa32696d
1690	Abbas, Ghulam	I	\N	m	A1245	G4512	A12	6198d0a4ca4beeb479c3eb401582e571
2109	Abbott, Matthew	II	\N	m	A1353	M313	A13	402a80f11db272e8d1ad83e3a54321e2
3045	Abe, Hotaka	\N	\N	m	A132	H321	A1	6d9abd8b144b2596466ff180bf7abd3a
316	4th U.S. Artillery Regimental Brass Band, The	\N	\N	m	T2634	T3263	\N	11cf634efc38ac8fbedf4fd1ee181d05
1780	Abbasova, Sövkat	\N	\N	m	A1212	S1231	A121	b15fe6f4b81dd69b4cab9a4e4ffd1b48
3055	Abe, Kelly	\N	\N	m	A124	K41	A1	3e6d256696173306d1a878278768615f
1556	Abato, Paul	\N	\N	m	A1314	P413	A13	420d8e0d932b4fe95da272adb30f65ad
1064	Aas, Knut	\N	\N	m	A253	K532	A2	795eb4141462235600b03c0b8b5ca00f
3403	Abelin, Philip	\N	\N	m	A1451	P4145	A145	31aa7bb34e555e7ed5336b1c7942da67
2593	Abdilmarik	\N	\N	m	A1345	\N	\N	3a9e3b9e7eaeaaa85287d253946284a7
404	A'Barrow, Neal	\N	\N	m	A1654	N416	A16	d649bb700359b3a3c7238ef5e31c2af3
2114	Abbott, Mike	II	\N	m	A1352	M213	A13	6fad1517a0f7a7df57a6efb3251b1659
2855	Abdullah, Basheer	\N	\N	m	A1341	B2613	A134	2382174aadcaae27b8b057267bd9aec0
3601	Abercrombie, Walter	\N	\N	m	A1626	W4361	\N	a838c005e278d61e35da3ba1b038089b
3244	Abel, Chris	I	\N	m	A1426	C6214	A14	477628cba682864ac15b8afa44dbe801
1111	Aasie, G.S.	\N	\N	m	A2	G2	\N	b31955aa5df9b72cdd948b9bba81ff89
1628	Abazyan, G.	\N	\N	m	A1252	G125	A125	91453be58a00eaeed2d1d3e676fbad2b
1260	Abadeza, Dante	\N	\N	m	A1323	D5313	A132	91b523f725bdc5b5f87484c3a52a5ba1
2887	Abdullah, Neil Malik	\N	\N	m	A1345	N4542	A134	8b2f2a14213031c52323a7a304253a33
2748	Abdul-Jabbar, Kareem	I	\N	m	A1342	K6513	\N	a223462e983d4847878f9eda34040f46
2747	Abdul-Haqq, Ben	\N	\N	m	A1342	B5134	\N	0eb64634af7be9ef54f9643c261a6391
2889	Abdullah, R.	\N	\N	m	A1346	R134	A134	e9108acf8c11c882b324daee8054a053
1078	Aase, Don	\N	\N	m	A235	D52	A2	f2afd75f2e9df59a1cccf14bd8d297be
2668	Abdrash, Inkar	\N	\N	m	A1362	I5261	\N	202ed037998aa052c487af1b90edf4d0
837	Aarniokoski, Hunter	\N	\N	m	A6525	H5365	A652	f1d7eeeebb2afe76e19f4caf7fe93747
3411	Abell, Christopher	I	\N	m	A1426	C6231	A14	6f11bc8d34c26b48523a2c1f20efa7d9
1215	Abad, Jp	\N	\N	m	A1321	J13	A13	104b4c917bc84e96e45754e91b6e550d
2208	Abbrecht, Todd	\N	\N	m	A1623	T3162	\N	a0747b4c698d5e8420ba9dffd3c34ec6
495	A.D., Fear	\N	\N	m	A316	F63	A3	873a5cfe765cf7a79f8086ddbe8dec54
1328	Abagunde, Balogun	\N	\N	m	A1253	B4251	\N	6fa5d310309f302dd173d4a5d80f5d37
2616	Abdo, Orlando	\N	\N	m	A1364	O6453	A13	1539d43b982742f4017fca55a132036a
3428	Abella, Alex	\N	\N	m	A142	A4214	A14	9cded74c304ddbb17b7b64d7fed88c9b
1188	Abad, Dani	\N	\N	m	A135	D513	A13	c15349226657e3fc42db3ceb02a547ba
3182	Abedi, Javed	\N	\N	m	A1321	J1313	A13	453e6ffdee00e38ea0257ad5efe94d45
1591	Abayan, Beauty	\N	\N	m	A1513	B315	A15	224183cbc420496a5acb1e87a23fc7e7
3452	Abella, Rafael	\N	\N	m	A1461	R1414	A14	39a6377de700b0a7569b3b61eebbc6d4
760	Aamoum, Saïd	\N	\N	m	A523	S35	A5	88520b51ec58de8b36ba7ad2deb9b003
1886	Abbey, Paul	I	\N	m	A14	P41	A1	7081360f67866f116df2a4de76d3f007
2898	Abdullah, Sayyid	\N	\N	m	A1342	S3134	A134	8b273050df021a3e503324c00f35b792
1708	Abbas, Master	\N	\N	m	A1252	M2361	A12	b0edd21fcd8a1e2deb11579e319afc26
541	Aabed, Essam Abu	\N	\N	m	A1325	E2513	A13	4713a634e635d9a9650bf7e640ea5415
1410	Abanes, Francis	\N	\N	m	A1521	F6521	A152	99a4c8725401695922624ec3fdde7869
963	Aaronbayev, Michael	\N	\N	m	A6515	M2465	A651	b2faf05f2b2cd78c7b754c65688a29fa
2599	Abdirakhmanov, M.	\N	\N	m	A1362	M1362	\N	80dd8eb1315c0008d60253ffecd783b0
329	5 Star Dance Machine, The	\N	\N	m	S3635	T2363	\N	91a70d8b4bf32f7018a9c949640832e6
2648	Abdou, Ahamed	\N	\N	m	A1353	A5313	A13	b6c976bec1066406c26bfbee75f027a9
2724	Abdul, Kazeem	\N	\N	m	A1342	K2513	A134	72b3666591ab7b2cd30a5a04351fcd26
1758	Abbasi, Mughni	\N	\N	m	A1252	M2512	A12	4c253855ee67fa9ff517309dde5e63ba
3228	Abel, Alan	I	\N	m	A145	A4514	A14	cca43dd0cab1649a3aa50cac0ce9a6e7
259	3 Whippets, The	\N	\N	m	W1323	T132	W132	461ee8083b9338a6a93ed121a3dce739
1083	Aase, Ronny Brede	\N	\N	m	A2651	R5163	A2	46976302b464341c43bb016dc445bd0a
2551	Abdhi, Salam	\N	\N	m	A1324	S4513	A13	b384d2ad344c8fa0705156b240efbdc3
2212	Abbruzzese, Dave	\N	\N	m	A1623	D162	A162	44e26c95b8fa16cfa5bfcbfc802b35d4
917	Aaron, Josh	\N	\N	m	A652	J265	A65	b586734d92f3872fa350f41356077d1d
1132	Aav, Tõnu	\N	\N	m	A135	T51	A1	e3149feed15fed79e6afa66ee7d89372
677	Aalto, Markus	\N	\N	m	A4356	M6243	A43	233d0cd6d3778ef26ba8faf07a276f40
1066	Aas, Mart	\N	\N	m	A2563	M632	A2	64e898f5a8a1eb4a1e9c4fe0a6a1683e
3126	Abe, Yasuyuki	\N	\N	m	A12	Y21	A1	1902a2192be5bb0d78c749eea52130ea
367	6th Sense	\N	\N	m	T252	\N	\N	54141aaa96178d156439ee3f96df44a9
3520	Abelson, Jamie	\N	\N	m	A1425	J5142	\N	8db7edc681b3b1dc088296ec8aa37b6d
1372	Abalde, Eugenio	\N	\N	m	A1432	E2514	A143	2283ac63669aa5e7362a2f350dbfb2ed
620	Aakel, Tiran	\N	\N	m	A2436	T6524	A24	c74088b2f26e10c4af5b7cc0f2cb6687
3584	Abercrombie, David	II	\N	m	A1626	D1316	\N	d422dce8af62718e41e3f0e0cc1c4d17
3069	Abe, Masafumi	\N	\N	m	A1521	M2151	A1	72c3c1fed1a51422133aca675dedc54a
2992	Abdurrafi, Su'Ad	\N	\N	m	A1361	S3136	\N	12d628fbe61111b13bc31c0f5f4af296
1764	Abbasi, Shamoon	\N	\N	m	A125	S512	A12	9bbd6a2d5d942f7dd98bd4e1227ed703
552	Aabhas	\N	\N	m	A12	\N	\N	b635941c8d691e3e63d4d7df13653614
1613	Abazi, Refet	\N	\N	m	A1261	R1312	A12	893b528887439640c62af5e8cdd45b54
860	Aaron Gonzales' Orchestra	\N	\N	m	A6525	\N	\N	971efd52a6a31bd1b96372755b2104fd
1183	Abad, Cayetano	\N	\N	m	A1323	C3513	A13	bb629e1fb2e9578cc320c54625de5b99
1985	Abbott, Brin	\N	\N	m	A1316	B6513	A13	4a695ae21ace3a8bad0fef3607214ca2
473	A., Righteous Reverend	\N	\N	m	A6232	R2326	A	5a4b38eb5257ca8c5fcddfc1c0861786
3091	Abe, Saori	\N	\N	m	A126	S61	A1	621bd1ad0c90295135abfecbc6fc818b
767	Aanderson, Chris	\N	\N	m	A5362	C6253	\N	669f503f69470bba0e749a4e885f950b
631	Aakko, Matti	\N	\N	m	A253	M32	A2	cd201ff75d0e983314c2d1bb0981bb8b
2664	Abdous, Kamel	\N	\N	m	A1325	K5413	A132	43a7da8c2bb072e2ab1c1c3c07b45197
3170	Abed, Sabah	\N	\N	m	A1321	S13	A13	3de3a326e145f69c6c064fa82f69ec52
449	A., Hernandez 'Ka' Carlos	\N	\N	m	A6532	H6532	A	8283a5b8463ed305f1ffc2929f38891d
2407	Abdelgani, Hussein	\N	\N	m	A1342	H2513	\N	8d50a7c37a0d54077d74013b88271590
510	A.J.	V	\N	m	A2	\N	\N	09210d73a0692c92202854441f6d7a3f
1264	Abadi, Ebrahim	\N	\N	m	A1316	E1651	A13	04f30234c202c24fe88fd7cad0cdc462
1915	Abbiw, Raymond W.	\N	\N	m	A1653	R531	A1	97ad1f1a5f5330af561a69612ce13fb4
949	Aaron, Steve	I	\N	m	A6523	S3165	A65	311543407dde1b9d1839fadde4efbe42
3598	Abercrombie, Richard	\N	\N	m	A1626	R2631	\N	95d4a22aea71ab4e1b2840a5d8418dc8
2775	Abdula, Deniz	\N	\N	m	A1343	D5213	A134	95c7e306292f14aa5431e6fa5ed70d90
532	A.S.F. Dancers, The	\N	\N	m	A2135	T2135	\N	e7aa42d7a99d7d2849e11b3ae07c931e
932	Aaron, Michael	IV	\N	m	A6524	M2465	A65	f40da21f7b2e86f01feaa24ac080f7f3
2330	Abdel Ghani, Ahmad Said	\N	\N	m	A1342	A5323	\N	016774fc74c3b5e5f32dc02449a98cc5
3011	Abdykadyrov, Nurdan	\N	\N	m	A1323	N6351	\N	10763ada46fbc611d57d542bb893aa4c
1074	Aasa, Marko	\N	\N	m	A2562	M62	A2	3d45f565746bb9d8eadbe477d4621c91
1230	Abad, Ricardo	\N	\N	m	A1362	R2631	A13	a4c2bcb8609767f0204938e5ff07754d
2342	Abdel Monem, Alim	\N	\N	m	A1345	A4513	\N	7efc32a7895847a48acbd7ea7cdfa380
2580	Abdiel	\N	\N	m	A134	\N	\N	568a99496da2d8b03a552e0ef1b9b936
645	Aalbersberg, Pieter-Jaap	\N	\N	m	A4162	P3621	\N	57a630ec44b774cd29a423efe2d73f70
1620	Abazoglou, Angelo	\N	\N	m	A1245	A5241	A124	69aaec81739aebd0c395869f06413658
3643	Abernathy, David	\N	\N	m	A1653	D1316	\N	d84db9df4bc8bdba6c5be17a819b0b28
2833	Abdullah	III	\N	m	A134	\N	\N	6898b2855c25e447f4c77fa8904bbed3
1539	Abate, Michael	II	\N	m	A1352	M2413	A13	502c8aa0a9a785c0e3e4fb907a75576f
2788	Abdulayev, M.	\N	\N	m	A1341	M1341	\N	0fad996a633063be76c4d5f9a1aa816a
3030	Abe, Atsushi	I	\N	m	A132	A321	A1	c5b63e7a31973ea72966a69e986c1186
2968	Abdulrazak, Asaad	\N	\N	m	A1346	A2313	\N	cb11a2c6b82488e5d39d53211a51e2a7
2627	Abdolaziz, Fadavi Zezo	\N	\N	m	A1342	F3121	\N	d367beb8d7c7570e262577a48613de10
2521	Abderahim, Ben Zbiri	\N	\N	m	A1365	B5216	\N	557d261901665ec0bca4be332da62c98
3446	Abella, Joaquin	\N	\N	m	A1425	J2514	A14	f8daf590df774a191830f67893a140ee
2418	Abdelhafez, Amr	\N	\N	m	A1341	A5613	\N	8cd0139af5ec2a207d118dcc9d85ecf0
1977	Abbott, Bill	I	\N	m	A1314	B413	A13	a757d029e06653b131dab59fe51d9af1
867	Aaron, Art	\N	\N	m	A6563	A6365	A65	f361b009e4952e80b026d2870c616f33
904	Aaron, Jack	\N	\N	m	A652	J265	A65	c495f385c1b0e1ef3ce127250cb68f18
1146	Aazmi, Habib	\N	\N	m	A251	H125	A25	7231b84b618ce1baf1365b0a0b01e2a1
613	Aakash	I	\N	m	A2	\N	\N	afa521474fe97d6ddd54f8b20eb5131c
1910	Abbiss, Alex	\N	\N	m	A1242	A4212	A12	4a572d487f0a7e566d714e43afcff416
33	'El Gato', Félix	\N	\N	m	E4231	F4242	E423	0888a83d3fcb0d1a23fc64c724487b9d
3505	Abels, Dustin	\N	\N	m	A1423	D2351	A142	bf7cd04bc5d6915e44838435e6c1632a
3635	Abernathy III, Ralph	\N	\N	m	A1653	R4165	\N	8777aa99108267ed517202b345d2c44a
2830	Abdullaev, Sardor	\N	\N	m	A1341	S6361	\N	cc836de7da42fe3bb19427405c83e498
1820	Abbatiello, Albert	\N	\N	m	A1341	A4163	A134	99887b44bf3c8894f759cb5eab4654ae
3099	Abe, Shozaburo	\N	\N	m	A1216	S2161	A1	298bc846ad4aac3f017d30836ce39db7
507	A.J.	III	\N	m	A2	\N	\N	0852d7ad140fccebada98a02cc7dc49b
1731	Abbas, Shezad	\N	\N	m	A123	S2312	A12	654bdd367b7b2590a91e7bb84601bc35
105	'Til Tuesday	\N	\N	m	T4323	\N	\N	00076f693cbb28c476d1586a6b4b54d1
791	Aaras, Lalit	\N	\N	m	A6243	L4362	A62	59f968b3825e69fc526af8d6483f6c16
2353	Abdel Wahab, Fathy	\N	\N	m	A1341	F3134	\N	b49c469a16512bd86f6ac9c3222c3832
1309	Abady, Solomon	\N	\N	m	A1324	S4513	A13	ee958f2738acedb0da24402f6ead5c79
563	Aadhe, Bensouda	\N	\N	m	A3152	B523	A3	c5125a0e58b66a105d4365f79cd3e0b1
1190	Abad, Darío	\N	\N	m	A136	D613	A13	f0df9165212f900fa42f001193ba87b6
558	Aabye, Thomas	\N	\N	m	A1352	T521	A1	b67f2360cb24292841ab3ccf52304b00
2318	Abdel Ahmid, Sabdi	\N	\N	m	A1345	S1313	\N	fa3e459391c85961d54ef32013b18569
2510	Abdelsamad, Muftah	\N	\N	m	A1342	M1313	\N	403976dae59d24a794e89ac28dce2ec3
2343	Abdel Monen, Sabri	\N	\N	m	A1345	S1613	\N	70d6f67ed8d1991b33cd1c433ecc1666
2590	Abdilmanov, B.	\N	\N	m	A1345	B1345	\N	3eefb7c5e1c317a748f65adf283f153a
584	Aagaard, Carl Powl	\N	\N	m	A2632	C6414	A263	a2f0242ad9db08b07874073d2154d5ae
1604	Abaza, Fekry	\N	\N	m	A1212	F2612	A12	44cde8678012034734620891d4d9a4b8
1961	Abbott II, William	\N	\N	m	A1345	W4513	A13	e6676b54cd3f50edd04e411dd5d5b535
1525	Abate, Andrea	\N	\N	m	A1353	A5361	A13	19474b40f1e3664b108377bb48ee7175
887	Aaron, Dane	\N	\N	m	A6535	D565	A65	3d0b12557bcc7dd4b5026e96cee0a3d9
1370	Abal, Francho	\N	\N	m	A1416	F6521	A14	3ad8c5922b3aec5094d345706e063e8b
2867	Abdullah, Hussain	\N	\N	m	A1342	H2513	A134	8af44d93d4a10acdf4c99cce17dac7f9
892	Aaron, Dayna	\N	\N	m	A6535	D565	A65	e9caed24de351a3f424a8bf4836e067b
509	A.J.	IX	\N	m	A2	\N	\N	58c126e661ccdc218098d942766b9578
886	Aaron, Damon	\N	\N	m	A6535	D565	A65	1789f8c189c8785578aa0416630d9d6b
1288	Abadie, Laurent	\N	\N	m	A1346	L6531	A13	1eeabb5cf80f2674db23cd6e94aa04c6
3184	Abedi-Amin, Bamshad	\N	\N	m	A1351	B5231	A135	ef1359ec5cdadd4053f0377c19bfad34
3000	Abdus-Samad, Hadis	\N	\N	m	A1325	H3213	\N	da8d2bd69419b05f68dd5c799d5d02da
1953	Abbot, Robin	\N	\N	m	A1361	R1513	A13	18500650311dc38737a0ec3ee82e6ddd
1507	Abassa, Oussama	\N	\N	m	A125	O2512	A12	24ba69cc6937412686f3dd1459f0d2de
3202	Abeel, Nick	\N	\N	m	A1452	N214	A14	614a54b34baed1a6b2644ffe71be911e
3597	Abercrombie, Patrick	\N	\N	m	A1626	P3621	\N	7f99a0f53af00cde0567a33b5c2313d7
2163	Abbott, Steve	VI	\N	m	A1323	S313	A13	c42dfc17151864ae8ca3bf2ec8d75065
2048	Abbott, Greg	I	\N	m	A1326	G6213	A13	b24ce4f9bdae83bbb07f7271e2ec2140
508	A.J.	IV	\N	m	A2	\N	\N	231fdd6bf9afdb57dbbe9f127633719f
3204	Abegaze, Leah	I	\N	m	A124	L12	A12	74eb6d1dc2b4aeb3adfe3343469c9909
2996	Abdurrazzaq, Adel	\N	\N	m	A1362	A3413	\N	874cfe20c345da85067cf6127b8a95fb
3265	Abel, Jake	\N	\N	m	A142	J214	A14	8cbcf96750b3cceacdb06f4f7b5d1c41
2967	Abdulrasool, Yahya	\N	\N	m	A1346	Y1346	\N	5fb7ef4b689d5479a6ef0f1170c666b3
536	A.X.L.	\N	\N	m	A24	\N	\N	0415cb0c26b7b524ab1b97ff1376bd6d
519	A.M., Four	\N	\N	m	A516	F65	A5	ce7e16b6aaadb39833796d4d5b17af10
2811	Abdulla, Baraa	\N	\N	m	A1341	B6134	A134	000c3ef075da676eaed190971c63b74e
281	4 Cats	\N	\N	m	C32	\N	\N	0da56688e732f1dec23d9875b1c03a6f
2278	Abdallah, Amar Ben	\N	\N	m	A1345	A5615	A134	dff4df25d8bd87084581b173d59c2b2a
606	Aagesen, Larry	\N	\N	m	A2546	L625	A25	47836036e2374a94a85d1b1e50ec0baa
2924	Abdullayev, Farhod	\N	\N	m	A1341	F6313	\N	6c516998a9ddbc610506c101556f97d9
470	A., Prasad	\N	\N	m	A1623	P623	A	91c749057f33ab2594030dc00daf889b
930	Aaron, Maurice	\N	\N	m	A6562	M6265	A65	159f27b377ad18c641e3194d319518a9
1611	Abazi, Hamza	\N	\N	m	A1252	H5212	A12	6bb7b73bdd3f578cc119e304a224bf19
701	Aaltonen, Honey	\N	\N	m	A435	H5435	\N	150c8ca780785500ca629c06ef6b7e3c
3247	Abel, Dieudonne S.	\N	\N	m	A1435	D3521	A14	602eaf02ca8a0c92fcd3e750f11bdd6c
800	Aardewijn, Pepijn	\N	\N	m	A6325	P1256	\N	b30d87ed84fd7b53ab86e6d0050b1df1
462	A., Master	\N	\N	m	A5236	M236	A	59bf95082a938ac99da520bb419285c9
992	Aaronson, Kyle	\N	\N	m	A6525	K4652	\N	b77c30af337ce47bf5905ed915b705f1
972	Aarons, Colin	II	\N	m	A6524	C4565	A652	86d2b1ec0d90660e3973af2411738b32
2292	Abdallah, Mohammed Ahmed	\N	\N	m	A1345	M5353	A134	ad68fb74e009518e0a345dcef31da436
627	Aakil-Bey, Zero	\N	\N	m	A2412	Z6241	A241	b48d47f73492e2109311bbd4a0a104f8
782	Aapro, Esa	\N	\N	m	A162	E216	A16	2d7158b9654540ae5ffb184f74d28346
113	*NSYNC	\N	\N	m	N252	\N	\N	b968a9b7ce2a374b178b80070284c7c3
2841	Abdullah, Ahmad	II	\N	m	A1345	A5313	A134	d1393369c6632ca357ef188c78bae306
156	.357s, The	\N	\N	m	S3	T2	S	6a1b9da2155a993e02b75cb6efc55c20
2908	Abdullah, Zauther	\N	\N	m	A1342	Z3613	A134	9a67289e04fec6ab6cceefea2a4056f9
3217	Abeille, Jacques	I	\N	m	A142	J214	A14	b40abfd8f7155f2dcd67dd061bdc2d8b
3573	Aberasturi, Sergio	\N	\N	m	A1623	S6216	\N	9bbf126ac29aacb4b4ffc0a212374b88
3394	Abelesz, Israel	\N	\N	m	A1426	I2641	A142	cf3a5b3e5241b5a498790ee34c1da240
112	'Ô', Oswald	\N	\N	m	O243	\N	\N	b7cdc810edc381b24cc13b2b76a6e5d5
3263	Abel, Ingo	\N	\N	m	A1452	I5214	A14	363177bd7970dae15044b0529ec3f6ef
2685	Abduh, Muhammad	\N	\N	m	A1353	M5313	A13	4013e57948aecad5b8d4bfee083a35f4
1665	Abbas	VI	\N	m	A12	\N	\N	2dc042848c80ea3cef4061ecd1bff568
2176	Abbott, Troy	\N	\N	m	A136	T613	A13	495841af87a565d5924a5041b1d9b287
2374	Abdel-Khaliq, Hussein	\N	\N	m	A1342	H2513	\N	8dfcb726b7c29202a21c6be774bf0d82
3320	Abel, Willi	\N	\N	m	A14	W414	\N	95921e244794f06b0346fba4549fe04a
2722	Abdul, Ibrahim	\N	\N	m	A1341	I1651	A134	519c523a9407e204b0401723e37e7f6c
864	Aaron, Alex	\N	\N	m	A6542	A4265	A65	05157ff02d9c6cf5b3e0d4fe21505a60
1482	Abascal, Martín	\N	\N	m	A1245	M6351	A124	3ed1bee1ad3518c544ada95a28529d17
2014	Abbott, David	I	\N	m	A1313	D1313	A13	0582593149cf49e694bd66de81156704
1661	Abbara, Saif Al-Deen	\N	\N	m	A1621	S1435	A16	6027d9c7a63c8497bf2f0c53ac577f8d
1307	Abado, Rick	\N	\N	m	A1362	R213	A13	675952047e4fcf2dcf3706f62695fe29
1087	Aasekjær, Henrik	\N	\N	m	A2656	H5626	A26	d462f7c678afdf20168a80e2948758f0
2025	Abbott, Donald R.	\N	\N	m	A1354	D5436	A13	3d4f01f214cc29e3297c3c8f3500f5e2
2065	Abbott, James	VII	\N	m	A1325	J5213	A13	8e8ee36f4a397ac2d5d1809cae010544
3246	Abel, Derrick	\N	\N	m	A1436	D6214	A14	0d8ff8efe3b8a6e1549927b9e97a67e5
3541	Abendroth, Michael	\N	\N	m	A1536	M2415	\N	1816f9ef3bcb2eb63f22299c592a7c58
2011	Abbott, Dan-San	\N	\N	m	A1352	D5251	A13	c55f9ea17aff05ada3393c52121f1c50
1533	Abate, Ivan	\N	\N	m	A1315	I1513	A13	c5f47159b48f9617f0fbb7a075b644ec
3083	Abe, Osamu	I	\N	m	A125	O251	A1	cb7cb736b0587ca616fc8ba83e6a30d3
2463	Abdellah, Karim	\N	\N	m	A1342	K6513	A134	b1c94313aea4a59eea99eb386bb3a2ca
1945	Abbot, Jerry	\N	\N	m	A1326	J613	A13	96c4ce713de1da06d433b189a3fe7339
3594	Abercrombie, Landon	\N	\N	m	A1626	L5351	\N	62b3b8510aa4be4e2cc40b0deae582e2
420	A, Yunga	\N	\N	m	A52	Y52	A	4b5f92139556fd1170f1e66a492b2d40
594	Aagaard, Lasse	\N	\N	m	A2634	L263	A263	5218d63a5f31c799293416689a35533b
2592	Abdilmanov, Bulat	\N	\N	m	A1345	B4313	\N	48475584889029162a548c7f2103f63b
3493	Abellán, Miguel	\N	\N	m	A1452	M2414	A145	58c7863f99a58680da5c6ac6043c70b0
1959	Abbot, Tommy	\N	\N	m	A135	T513	A13	f4f39408ed1c9359d81aa97632ab23be
3605	Aberdeen, Robert	\N	\N	m	A1635	R1631	\N	a741b0fe2c43ffcaae62c79687c9b5fb
2096	Abbott, Kingsley	\N	\N	m	A1325	K5241	A13	768f194bfa9ae0d85fbc456fabbaadab
3583	Abercrombie, Craig	\N	\N	m	A1626	C6216	\N	79d61f6a907c0545ec377e71ebef9370
875	Aaron, Brett	\N	\N	m	A6516	B6365	A65	ddd7f3914416d126f82ffc73bdcd7fcf
2890	Abdullah, Rabih	\N	\N	m	A1346	R134	A134	3202740cdfb83fec7f23ea7c5bedefcc
848	Aaron	VIII	\N	m	A65	\N	\N	71f5bdc9c4fd125fc232f661e654fffe
929	Aaron, Matthew	IV	\N	m	A653	M365	A65	5437997d24b76e718221d9b84fd96f77
190	16Down	\N	\N	m	D5	\N	\N	f9e2f0c74041aa78c73ab156e3e6f252
1424	Abanoudis, Stratis	\N	\N	m	A1532	S3632	\N	63012e2bcd2c44eb89fff6cdfac916a7
2849	Abdullah, Ali M.	\N	\N	m	A1345	A4513	A134	51e5e67c34cb19912bf68dc4ee60ff9b
93	't Hooft, Gerard	\N	\N	m	T1326	G6313	T13	b357e4153e196a110eedf6ca18f795bb
2762	Abdul-Matin, Talib	\N	\N	m	A1345	T4134	\N	e95c8bd7b904873502b024d98c2be896
3078	Abe, Naoyuki	\N	\N	m	A152	N21	A1	d08cff4ab142c028d8d2b9d97da17c3b
2598	Abdirahman, Sahara	\N	\N	m	A1365	S6136	\N	1746b3fc0632abfa1afbfdcd54650d13
2435	Abdelialil, Annabi	\N	\N	m	A1345	A5134	A134	e8852646a1d08c776ba4be2110d1fe3d
494	A.D., Easy	\N	\N	m	A32	E23	A3	c5811e1871faf6f7ab511541534923dc
1003	Aarrestad, Kaja Halden	\N	\N	m	A6232	K2435	A623	d429ce0bbc04bf3ac22032e8d692ed1b
1139	Aavik, Evald	\N	\N	m	A1214	E1431	A12	e0942655a69a6b7cab70c99373d42c93
1538	Abate, Massimo	\N	\N	m	A1352	M2513	A13	0401f99f3d3a34e0083c0ec1bae507a1
1575	Abay, Korhan	\N	\N	m	A1265	K651	A1	6af1a1206296002d5dd1ae274918a49e
1255	Abades, Oscar	\N	\N	m	A1326	O2613	A132	2643dc3ca6746a0c42cf4d71315f6a0f
2150	Abbott, Roger	\N	\N	m	A1362	R2613	A13	36c1b58642b1314ed38b0b50d56d29d7
3125	Abe, Yasunori	\N	\N	m	A1256	Y2561	A1	80f89a9590ed1e3a6f422efaa5d676fb
1587	Abaya, Matthew	\N	\N	m	A153	M31	A1	1df9db20420cd528dd4f1c7d3b22ccaf
1238	Abad, Ángel	\N	\N	m	A1352	N2413	A13	e614587fa9890a39abe364b3225b6de4
422	A-Hito	\N	\N	m	A3	\N	\N	4429c116576e2935b8274806290dec53
2395	Abdelaziz, Lasgaa	\N	\N	m	A1342	L2134	\N	b68cccbd0db555178a8bc2dbb3dd106a
481	A., Wei	\N	\N	m	A	W	\N	148866d09b1af1ddc4ce4b7088dff8c4
212	2, Cope	\N	\N	m	C1	\N	\N	d7593f8ff18224144f11d6d75cfe47df
619	Aakef, Tareq	\N	\N	m	A2136	T621	A21	2228948fb7146313fa880360249215a3
924	Aaron, Luke	\N	\N	m	A6542	L265	A65	96a45cabf1ead08c5d71da8562e5a1af
2408	Abdelghafour, El Hasnaoui	\N	\N	m	A1342	E4251	\N	0eaf45a638c00e0ec600e87181bac8a2
1703	Abbas, Khudair	\N	\N	m	A1236	K3612	A12	29e1557eee8de546a088c6785b8d3758
2538	Abderrazak, Mahmoud	\N	\N	m	A1362	M5313	\N	0ed808fa518cfc9c255cf00a17552a63
111	'Zafar, Kamran	\N	\N	m	Z1625	K5652	Z16	84c58a8053e7db58986c75d085a45db4
2843	Abdullah, Ahmed Izzath	\N	\N	m	A1345	A5323	A134	74d210a88f71ee531350cf297b931bed
1352	Abaka, Ahmed Mahammed	\N	\N	m	A1253	A5353	A12	e9c94d3a2392c52111e61e9a090bd59e
2291	Abdallah, Mohamed	\N	\N	m	A1345	M5313	A134	e194da3090f9147e193183a1a3f615de
1355	Abakar, M.M.	\N	\N	m	A1265	M5126	A126	69b1acb5af6e761b9c7082f4f0e7edc0
2953	Abdulmun'em, Tamer	\N	\N	m	A1345	T5613	\N	6c8689bb0e0f2da30f727b17d3280118
2005	Abbott, Claude	\N	\N	m	A1324	C4313	A13	d2eab348512c7094a4466da31346693e
2502	Abdelnor, Eduardo	\N	\N	m	A1345	E3631	\N	d9ea12f8f94382602ebd94712289d0d9
2162	Abbott, Steve	V	\N	m	A1323	S313	A13	87618e06c7ea9f2ad6beedd649f13568
1110	Aasie, C.S.	\N	\N	m	A2	C2	\N	13ecdc2c1da5b3f6b44eb6c36cd25e92
70	'Mr. Cool', Achyutan	\N	\N	m	M6242	A2356	M624	461a6ca5b7d92f947d365696fc128a7d
3627	Aberle, Marshall	\N	\N	m	A1645	M6241	A164	7b414e0f5fce549091dbe8a497a21e7c
882	Aaron, Clyde	\N	\N	m	A6524	C4365	A65	4a59cc1c22cfbf0db6a84c79d69c2423
3522	Abelson, Robert	\N	\N	m	A1425	R1631	\N	d43d908ab6b9f1e7f649aee74b1af811
2074	Abbott, Jerry	I	\N	m	A1326	J613	A13	ab98f45b9bb72627e7c3def22d9684ab
99	't Wout, Rogier	\N	\N	m	T3626	R263	T3	f8d4fa50a7b861b7ce83e456b447bc5e
7	& Dollar Furado, Caio Corsalette	\N	\N	m	D4616	C2624	\N	379e2ec3525c8a0746825ce35b3d89c6
3289	Abel, Morten	\N	\N	m	A1456	M6351	A14	0859e855b981c57632088a671ad226f8
3324	Abel, Zachary	II	\N	m	A1426	Z2614	A14	ef9b8403f0b52fc9e9eb5c64ae617532
2437	Abdeljabar, Elkhayat	\N	\N	m	A1342	E4231	\N	00a4342eb0e9a4f6790097ac8a530466
3029	Abe, Akina	\N	\N	m	A125	A251	A1	50e8e9bc9928e6fabf07ad11575ca145
2581	Abdigapparov, Daulet	\N	\N	m	A1321	D4313	\N	a8f46aed6936e220f3015d89770cd2a0
1845	Abbeele, Stefaan Vanden	\N	\N	m	A1423	S3151	A14	768f8a5c3e64a0db8a12348d352d6280
2075	Abbott, Jerry	IV	\N	m	A1326	J613	A13	44fa639db70253adb8bbfa44e32cf2dd
106	'Trash' Temperill, P.	\N	\N	m	T6235	P3623	\N	ad3af224c1994d78600365463ed2d2ae
2151	Abbott, Samuel	\N	\N	m	A1325	S5413	A13	2ae883bc8d3842797ea06649b5ebd86a
678	Aalto, Ossi	\N	\N	m	A432	O243	A43	2e526f9cf4020efbcd0bfae9084d7567
2682	Abdual	\N	\N	m	A134	\N	\N	b04d1843a46e49fb32ee0dfcdb9a50c7
295	4-Tay, Rappin'	\N	\N	m	T615	R153	T	32c406fa322cdd1754788c70c7a577d8
2495	Abdelmonaâm Chouayet, Ahmed	\N	\N	m	A1345	A5313	\N	bdc3e0ec7c1f6f6985cbd662f240f81b
3448	Abella, José Ramón	\N	\N	m	A1426	J2651	A14	0df9b461241c80b482b9f503681a1483
1743	Abbas, Zafar	\N	\N	m	A1216	Z1612	A12	64ceae39cb4c32913f4dd375900e3bf1
2246	Abdala, Esteban	\N	\N	m	A1342	E2315	A134	f63aecb7e94e748bf319825b84fd0c91
1420	Abankwa, Emmanuel	\N	\N	m	A1525	E5415	A152	822286a3f53a154174db388122802883
2196	Abboud, Ali	\N	\N	m	A134	A413	A13	dde6ddff465641304668cba0b2986b86
2938	Abdullayev, V.	\N	\N	m	A1341	V1341	\N	98a933d6e5657301fdddf0495b19d551
3491	Abellán, Joan Lluís	\N	\N	m	A1452	J5421	A145	f97acde9195bd5b8d9f6d3d44259ac3e
966	Aaronovitch, David	\N	\N	m	A6513	D1365	\N	d20c5c714444e9d489c1ec8982215de1
1921	Abboaizio, Augustus	\N	\N	m	A1232	A2321	A12	3796f9c7f9e70d686ba57000b8549a15
2450	Abdelke, Youssef	\N	\N	m	A1342	Y2134	\N	a285ae8bdb9b725782e2fa2a5a25e68f
812	Aarestrup, Carsten	\N	\N	m	A6236	C6235	\N	5091ef0db1f24a539c222494667369f1
262	3, Utai	\N	\N	m	U3	\N	\N	f5283038d9d6dbb8f08c06cb017b1993
896	Aaron, Edmond	\N	\N	m	A6535	E3536	A65	e20a0f9ade769e516f580b3370279369
2441	Abdelkader, Aizzoune	\N	\N	m	A1342	A2513	\N	af72ce414a16407e8e8a258ecc0b2b89
2305	Abdalov, Pavel	\N	\N	m	A1341	P1413	\N	c2cf5228cd0d443341c597dd54770c4c
74	'Potbelly' Rodger, Jason	\N	\N	m	P3146	J2513	\N	e1890ae53c41fe49c4c1317d39aa6638
696	Aaltonen, Anssi	\N	\N	m	A4352	A5243	A435	3fbe76085328bc7525f3275dd740672c
1117	Aasland, Derek	\N	\N	m	A2453	D6245	\N	d81e4f54256ac8abfc78cf03697950b5
1980	Abbott, Bob	\N	\N	m	A131	B13	A13	0f58fd6348d5da31f2d3d3487a6dc2c0
3415	Abell, Jeffrey	I	\N	m	A1421	J1614	A14	822ab49a174d8e761c515c619d5ed9c7
2276	Abdallah, Ahmed Samy	\N	\N	m	A1345	A5325	A134	87f0b90bf2870573d44e45c4d8556092
1101	Aaserud, Tor-Fabian	\N	\N	m	A2636	T6152	A263	046a6d24271605b560e40e0817cd1cb6
2384	Abdela, Khazi	\N	\N	m	A1342	K2134	A134	0e83f2b6b2cd0fd113db333cd094e60b
1957	Abbot, Ted	\N	\N	m	A13	T313	\N	7bde4db02b409322e558d57552653329
3016	Abdykalykov, Sabit	\N	\N	m	A1324	S1313	\N	b219262055f8d1723563a0199f489561
3156	Abed El-Hai, Akab	\N	\N	m	A1342	A2134	A134	65c42da23147e27f722d2d698f416246
2540	Abdeslam, Chayb	\N	\N	m	A1324	C1324	\N	d40f9371a0ec74552a5f0df11dea1997
1492	Abashidze, Levan	\N	\N	m	A1232	L1512	\N	721d0d13ad03f20f71cc979710d68c2d
2411	Abdelghani, Zouad	\N	\N	m	A1342	Z3134	\N	dc8e165ee3c03629acde8cb8509cc88e
2470	Abdellatif, Aâtif	\N	\N	m	A1343	A3134	\N	8c973552e54b447cb2936557bbf6f55c
3329	Abela, Christian	\N	\N	m	A1426	C6235	A14	0b87428a3abe9a6482b53afae7d8dbf5
1617	Abazid, Alexander	\N	\N	m	A1234	A4253	A123	3dc39ee9557fd640b266c22ace39aedc
1477	Abascal, Antonio	\N	\N	m	A1245	A5351	A124	06277984c013a70a30400332be14f547
2194	Abboub, Khalid	\N	\N	m	A1243	K431	A1	5f110b8b78263aa36eb9290a86a57096
2184	Abbott-Dallamora, Jesse	\N	\N	m	A1345	J2134	\N	44587f616a65b2fc128df4bb01f4f715
2383	Abdel-Shehid, Gamal	\N	\N	m	A1342	G5413	\N	e597e05c2ac316a656bccde97bc1a082
1816	Abbate, Tony	\N	\N	m	A135	T513	A13	d6b94c7c79d2fc6549155db35bed1c77
2957	Abdulov, Vitaliy	\N	\N	m	A1341	V3413	\N	0d660f95d258458851b088c7111075f6
2202	Abboud, Kevin	\N	\N	m	A1321	K1513	A13	d3f951adc10fde62a48a16155cc1e0fa
2125	Abbott, Paul	I	\N	m	A1314	P413	A13	325a5ee219edad28d29eb281e58bbceb
269	31, Articolo	\N	\N	m	A6324	\N	\N	cdbca8145e992b85dc4686d5be5ac6bb
764	Aamundson, John	\N	\N	m	A5325	J5325	\N	2de27b337461b66fe9b5af4f1a31a63b
2262	Abdalla, Alex	\N	\N	m	A1342	A4213	A134	dfcfaa4c18b513eab2e955a08d9c0cf3
3028	Abe Lyman Orchestra	\N	\N	m	A1456	\N	\N	3319aa6c5d2a6dd021710346271b10f2
641	Aalbeck, Freddy	\N	\N	m	A4121	F6341	A412	269314ed07d02e16007c0f95fde8b7de
725	Aaltonen, Remu	\N	\N	m	A4356	R5435	A435	275cc8a6472d47cc7e7b502b08c35ccc
1431	Abaou, Hammou	\N	\N	m	A15	H51	A1	c53aa554e0d4ee7e5c4aca7fe7c4d945
131	., Ceschino	\N	\N	m	C25	\N	\N	b1f8eb105e2d74d3175da4ad8c4f16f7
2739	Abdul-Ahad, Akbar	\N	\N	m	A1343	A2161	\N	94165d431f6373f404ebea666241d5bf
1156	Aba-Gana, Ibrahim	\N	\N	m	A1251	I1651	A125	7e26f8cb65820bd830ec915f0c7cac8d
2206	Abboy, Venkatesh	\N	\N	m	A1523	V5232	A1	4b256e62d07fcb4e10445d67f35547d6
1986	Abbott, Bruce	I	\N	m	A1316	B6213	A13	503a1d9eda50d941a3f940ddbf40a276
2235	Abd Elrahim, Fatih	\N	\N	m	A1346	F3134	\N	c3b6039d31bdc3c724f20d6ec3630f51
943	Aaron, Sam	I	\N	m	A6525	S565	A65	4da703e39e78ce3bbfe5b50f16063267
1080	Aase, Geir	\N	\N	m	A26	G62	A2	69a9cc3ec4fa88215080abce2dd995f4
110	'West Side Story' Cast, The	\N	\N	m	W2323	T2323	\N	32ea6985d7158d6e9699eb98bb328ba7
1600	Abaz, Emir	\N	\N	m	A1256	E5612	A12	fb3820179695be015002583487332c15
1058	Aas, Bjørnar Myhre	\N	\N	m	A2126	B2656	A2	a8bd4c9093a11810ed75c15c1da13580
698	Aaltonen, Arvid	\N	\N	m	A4356	A6134	A435	6203ac2a49391ba471d3535cf5513eca
85	'Stretch' Cox Troupe	\N	\N	m	S3632	\N	\N	4824c132062de8caf212ea5ce593624b
643	Aalbers, Chris	\N	\N	m	A4162	C6241	\N	e71a8efaa6b773f7902b1503c5539106
2829	Abdullaev, Rihsitilla	\N	\N	m	A1341	R2341	\N	ef207e07659353ef03b53758b7b8aa89
3526	Abelyan, Armen	\N	\N	m	A1456	A6514	A145	6b270f4a91dc41f320a4d1b1bf938ed9
2346	Abdel Nabi, Saleh	\N	\N	m	A1345	S4134	\N	563946cc639813c1c098a76e5b2b716b
1319	Abafana	\N	\N	m	A15	\N	\N	cc77533a1a545de44a96d6f1dc3df45b
1594	Abayev, M.	\N	\N	m	A15	M1	A1	194ec0a917821c170a2226a3a9faf936
3482	Abello, Jorge Enrique	\N	\N	m	A1426	J6256	A14	7ba58695b2486725ac40d6782f586541
1636	Abba, Maimunatu	\N	\N	m	A153	M531	A1	a5503da5d372ff59129cf9a32354c17f
1733	Abbas, Taufik	\N	\N	m	A1231	T1212	A12	eb5fe59c0207df944b944feb05ec07d3
1840	Abbe, Spencer	\N	\N	m	A1215	S1526	A1	fdf1c329b4c9f4acfc78e803d00c7567
1952	Abbot, Paul	\N	\N	m	A1314	P413	A13	374f932fbbff32d9c64902024df323d6
569	Aadithya	\N	\N	m	A3	\N	\N	5087af76a725e8fb67f1b5f58531be79
2216	Abbs, Malcolm	\N	\N	m	A1254	M4245	A12	b5cd7a4bf4bbccbab879596bec41916f
1182	Abad, Butch	\N	\N	m	A1313	B3213	A13	fba3f6829134baf12bad268a8d0f9ded
477	A., Santeri	\N	\N	m	A2536	S536	A	e1a379251c726f154466e08116258302
2462	Abdellah, Aourik	\N	\N	m	A1346	A6213	A134	f9a60e0a0882e4de6eab1c506e88c89c
204	1st Indian Air Force Band, The	\N	\N	m	S3535	T2353	\N	3182094a2a88c371ed060320ea6b5761
3588	Abercrombie, Joe	II	\N	m	A1626	J1626	\N	9dce77f33c878b4e36e01f2d71cc6b30
1402	Aban, John	\N	\N	m	A1525	J515	A15	8a83105ba554126f15c04194ab95669d
616	Aakash	IV	\N	m	A2	\N	\N	85e721f895f73d26ef93d1e84053b20d
1869	Abbey, Francis	\N	\N	m	A1652	F6521	A1	4c5e1608a7fe0768a3989e7c9daf8774
285	4 Mont-Réal, Les	\N	\N	m	M5364	L2536	\N	e61df25158455b1ee7e9e9cbb88c47b7
2691	Abdul	V	\N	m	A134	\N	\N	8cef5e8eafafa2eedc911029fbc17447
1799	Abbate, Giusy	\N	\N	m	A132	G213	A13	b7e13afb2701f694318350d46b353c52
1745	Abbas, Zaheer	I	\N	m	A126	Z612	A12	16e68b0b1d9e999ac96449916bdeb726
2658	Abdoulaye, Zingare	\N	\N	m	A1342	Z5261	A134	e5855f76ff06301a50068151143c76f8
1768	Abbasi-Shavazi, Mohammad Jalal	\N	\N	m	A1212	M5324	\N	b31077f5ffc9719f324c47459010962f
2508	Abdelrasoul, Khalid	\N	\N	m	A1346	K4313	\N	077a5235d9dbd87bd836fc346dfa9ec3
1469	Abarrientos, Johnny	\N	\N	m	A1653	J5165	\N	3e28180b206da06158b91299e6f3581d
3187	Abedin, Kaosar	\N	\N	m	A1352	K2613	A135	998950de9e811f200af650e035e5a13d
109	'Vietnam'Carswell, Leon	\N	\N	m	V3526	L5135	\N	e3b77888fb7e487210e9d165741f6aaf
2669	Abdrashitov, Vadim	\N	\N	m	A1362	V3513	\N	10a3bb1359aae93c24096dbaa57ae931
19	'Buguelo' Neto, Alderico	\N	\N	m	B2453	A4362	\N	4ea5f5dd2420ab443fd01c52a7c6785e
1300	Abadinski, Howard	\N	\N	m	A1352	H6313	\N	eb9fd9fb67d37b6b7c0138ece0f8b14d
408	A'Court, Mark	\N	\N	m	A2635	M6263	A263	af703d1bcfeaae793b51cd877a31e551
502	A.G.	\N	\N	m	A2	\N	\N	99279dddf25de9ca7056d00990af0454
169	100, St. Augustine Marching	\N	\N	m	S3235	\N	\N	793a8c6399a949bcd5cd7f78b54ea404
3161	Abed, Bassam	\N	\N	m	A1312	B2513	A13	c4d682b09ee80c2809fcb5752a0fc035
2993	Abdurrahamn, Umar	\N	\N	m	A1365	U5613	\N	3afee56b8c70892fd212cb95fb69b484
1603	Abaza, Ahmed	\N	\N	m	A1253	A5312	A12	90a6ccdbfd82a7ba7c7a8f591e8879c7
3395	Abelew, Alan	\N	\N	m	A145	A4514	A14	178c76366018dd5647631bf2c13eb4f3
3195	Abedz, Nader	\N	\N	m	A1325	N3613	A132	e79fb90cc112df7062aec264fee1d154
1151	Ab, Brian	\N	\N	m	A165	B651	A1	7d1f986d0565cfbba71ac8f6680ef0c6
1201	Abad, Gabriel G.	\N	\N	m	A1321	G1642	A13	9ec1704e793f1f4db7aa163995b25511
3173	Abed, Tarek	\N	\N	m	A1362	T6213	A13	6a06d765f7b5d06ad92108fde658253a
94	't Hooft, Maarten	\N	\N	m	T1356	M6353	T13	3fa0d5d36bdeff08a26a0674b6fcfc26
1868	Abbey, Evan	\N	\N	m	A15	E151	A1	ad2259f8a4735aee3f48ef0b0a660428
784	Aar, Kenneth	\N	\N	m	A6253	K536	A6	963e5a8a9434021466f77c8d267277f2
2298	Abdallah, Said	\N	\N	m	A1342	S3134	A134	03344356cf9f076f47239cef3629fd8e
2885	Abdullah, Munaim	\N	\N	m	A1345	M5134	A134	dc1ffb27f54690bd35817c647187b336
330	5 Starr, DJ	\N	\N	m	S3632	D236	S36	fc93782bc8fe48815eed448f62110c81
2926	Abdullayev, Farkhot	\N	\N	m	A1341	F6231	\N	bed53759bec828d53d5415d8384b082b
2143	Abbott, Riviera	\N	\N	m	A1361	R1613	A13	83dc6ed6e95e8b5bb94832aab1059972
1108	Aashish	\N	\N	m	A2	\N	\N	ed74c08090d9990f14dacbd19634a9e4
49	'Gasparyan', Zohrab Bek-Gasparents	\N	\N	m	G2165	Z6121	\N	af3b74ed02baa8d9dfc553c8f535635e
2990	Abdurazakova, Roza	\N	\N	m	A1362	R2136	\N	2302a156483539b47efcbab522cc8c18
597	Aagaard-Williams, Sebastian	\N	\N	m	A2634	S1235	\N	6889cf6040403e14f2dc988691fd0ac6
1453	Abargil, Yaniv	\N	\N	m	A1624	Y5162	\N	85239ac7398ee793ad18307dad6674ba
3545	Abene, Mike	\N	\N	m	A152	M215	A15	0a30b6806f2b59b4b903c004f2b9bd1a
3423	Abell, Sam	\N	\N	m	A1425	S514	A14	7453aafa33518c9e6a846e4d1b2f88e8
781	Aapeli	I	\N	m	A14	\N	\N	1dd41a155793ff76a7c021425d57e2a2
2222	Abbà, Lorenzo	\N	\N	m	A1465	L6521	A1	ed310238615307b37df98ce8ec4b495e
2618	Abdo, Tamim	\N	\N	m	A135	T513	A13	6414e06fe43c26ae2d38917b4cddcd0b
2333	Abdel Hamid, Hassan	\N	\N	m	A1345	H2513	\N	2818d5a864e128569cbf9621ef6b51c7
2973	Abdur, Joshua	\N	\N	m	A1362	J2136	A136	a3b1ca84422b451203a9b105d3ade98c
2883	Abdullah, Mohsin	\N	\N	m	A1345	M2513	A134	c5fb1fd953f2ec1c8c33dac3f803ac29
853	Aaron	XVI	\N	m	A65	\N	\N	48f481d4867ca94dab086e97d091eaa1
881	Aaron, Chuck	\N	\N	m	A652	C265	A65	b373fa1c821e3dc322e82b07a78ae4b7
3433	Abella, Cornelio	\N	\N	m	A1426	C6541	A14	4adbcee5cf0a9d58cfc6aa7953ca2533
1449	Abarca, Paul	I	\N	m	A1621	P4162	A162	703ec0d8e2428178caa61b5332910a8a
721	Aaltonen, Mikko	II	\N	m	A4352	M2435	A435	434d93ad9d6342944a1c51ebcbe9f7ff
3633	Aberman, Larry	I	\N	m	A1654	L6165	A165	4898328d42035104886cf03b187045bf
657	Aali-Taleb, Suilma	\N	\N	m	A4341	S4543	\N	f4b8c0f8150bc3660d7e3cd81f2a7c78
1250	Abaddi, Danny	\N	\N	m	A135	D513	A13	49d008b8e227cea8fa064e9eb91b0445
1472	Abary, Ray	\N	\N	m	A16	R16	\N	16555474df4922db0a406a5f881d7339
3485	Abello, Niel Carlo	\N	\N	m	A1454	N4264	A14	5c6d63e23ddcd3f7457f4c37d00fcbc5
883	Aaron, Cody	\N	\N	m	A6523	C365	A65	2646a5af1d61c423e2345768e38419cc
2103	Abbott, Mark	I	\N	m	A1356	M6213	A13	ea69a0dbea91552a04cb029ad29583df
3134	Abea, Baduk	\N	\N	m	A132	B321	A1	0af649b7533ea474e217254b117dbcff
396	? & The Mysterians	\N	\N	m	T5236	\N	\N	fc2005e5020a2d92a0f2d3ad8f739457
63	'Lucky' Hudson, Scott	\N	\N	m	L2325	S2342	\N	14fdd469de1876745916209b4dfd31b8
2823	Abdulla, Raji	\N	\N	m	A1346	R2134	A134	d954ce38f0ecbdd4db9c23d909022d2b
1682	Abbas, Eduardo	\N	\N	m	A1236	E3631	A12	4c960f82c925488061d8f8812a2320ab
1747	Abbas, Zahra	\N	\N	m	A126	Z612	A12	9dadeb3a5d9f61f8624a940c84a1998d
2012	Abbott, Dave	II	\N	m	A131	D13	A13	d89270ba5a126c9f54078eb4defdd634
2319	Abdel Al, Ali	\N	\N	m	A134	A4134	\N	fd10a46a50fc421d66be1e027a31f639
372	77, Attaque	\N	\N	m	A32	\N	\N	c8f0b1b5263876e8d97ac3f048c5931e
1883	Abbey, Matthew	\N	\N	m	A153	M31	A1	8e5dccabb517fa93c998b4acc6331c28
694	Aaltonen, Aimo	II	\N	m	A435	A5435	\N	12886e4c12dfa970155efb08923ddbb8
3449	Abella, Jun	\N	\N	m	A1425	J514	A14	09c684d9f719b7988b9455d882542a7b
363	69, Jyrki	\N	\N	m	J62	\N	\N	9fad7cb655a08bb53d09ba7b92576496
633	Aal, Kareem	\N	\N	m	A4265	K654	A4	b8f5e1a1ecf3ea2faa5ea7659f37fda2
505	A.J.	I	\N	m	A2	\N	\N	7cdcc689c3eaf6f4fe2e769d25089f0c
196	19, Jimbo	\N	\N	m	J51	\N	\N	b016d0aa9c9e7c7fa3f81963cbf2f4b6
1571	Abaunza, Jorge	\N	\N	m	A1526	J6215	A152	91bca17746cfbd88abe7757104fd97ee
720	Aaltonen, Mikko	I	\N	m	A4352	M2435	A435	4f6168ae9877dd595c1dd7697209f6da
1142	Aawat, Tawfiq	\N	\N	m	A312	T123	A3	9416c6e5a593c14f8fef692dd50c41db
2422	Abdelhak, Belmjahed	\N	\N	m	A1342	B4523	\N	f6851eea9a3e504dbb881423688e0e54
1401	Aban, Janus	\N	\N	m	A1525	J5215	A15	8454d0b0241598607e715bb05836614c
2244	Abdagic, Nakib	\N	\N	m	A1325	N2132	A132	e907e431aedfe6feb19583ef57f41644
1698	Abbas, Ibrahim	\N	\N	m	A1216	I1651	A12	0922ef6af978b0aa87730e8dcf9d386f
3416	Abell, Joey	\N	\N	m	A142	J14	A14	a500d7ae490f349cde3fea2335a9751f
3618	Aberkane, Mounir	\N	\N	m	A1625	M5616	\N	8f468908e44ff001b6514b5a6e8b6ba7
1234	Abad, Tim	\N	\N	m	A135	T513	A13	e2af764ac23455ef9b125a3f86679e8e
2854	Abdullah, Ashik	\N	\N	m	A1342	A2134	A134	749f4de5500f12b1e5e2c2a113ca5a90
2169	Abbott, Thom	\N	\N	m	A135	T513	A13	6c4e9a2be7e25fb3a140038577385bb8
2937	Abdullayev, Sirzad	\N	\N	m	A1341	S6231	\N	c7907472be542efef0498852fc887744
9	& Fabiano, César Menotti	\N	\N	m	F1526	C2653	F15	6d205a291e82fe07344c68a5282916e5
2622	Abdol Monaem, Hossam	\N	\N	m	A1345	H2513	\N	9980ce49aa08c87e747b74e9346bea3d
3119	Abe, Tsuyoshi	II	\N	m	A132	T21	A1	f6a9d0b1c3e43cb939997960e286c92d
1966	Abbott, Aaron	IV	\N	m	A1365	A6513	A13	009326edfee297dc7ca662bfd2d070a3
454	A., Joe	\N	\N	m	A2	J	A	d61896d337d673eef238a1b1b6791b0d
1302	Abadié, Luis	\N	\N	m	A1342	L213	A13	9f363ae9ef8b6df7538322f8fc001a30
1273	Abadia, Oscar	\N	\N	m	A1326	O2613	A13	b3a5e5417bb93ba6ca5107311fcf5ab0
1096	Aasen, Sondre	\N	\N	m	A2525	S5362	A25	9e01b790975ff4eeae1559e9f2c48ff2
1982	Abbott, Brandon	\N	\N	m	A1316	B6535	A13	f2619c97a47f4c989042ae3a3d511346
2603	Abdo, Cameron	\N	\N	m	A1325	C5651	A13	a38059303431771db33f6b66bc1228f6
639	Aalami, Arash	\N	\N	m	A4562	A6245	A45	f1cb5ce57f733ac30392d2e938f90500
173	101, Kab	\N	\N	m	K1	\N	\N	ac5793602f69c569c98a4cac28fddd08
907	Aaron, Jason	\N	\N	m	A6525	J2565	A65	2255f140854ae7727d902c651abf0460
248	2X, Benjamin	\N	\N	m	X1525	B5252	X	792ede9ac46334e60f128be5db78eb0b
1655	Abban, Ekow	\N	\N	m	A152	E215	A15	d983c0d807a1cc381c92d07009e4b4cc
1931	Abbort, Michael	\N	\N	m	A1635	M2416	A163	6dc927d0aa0fd2d39079bb6781b8f47b
1374	Abaliel, Orlan	\N	\N	m	A1464	O6451	A14	ef974fbb41e92f6d6831c3c374b2528b
503	A.G., Vinod	\N	\N	m	A2153	V532	A2	3b8e294afdd939b41c3a7d598540a17f
368	7 Rascals, The	\N	\N	m	R2423	T6242	R242	2b53132c658775a00876faca56dd1248
174	104, Dave	\N	\N	m	D1	\N	\N	3c416f9440ee82c1fb8daef01551966a
3285	Abel, Mike	II	\N	m	A1452	M214	A14	d9e63f77a0eff6b09f1257a98963f292
1610	Abazcal, Lorenzo	\N	\N	m	A1246	L6521	A124	27ae2f10a091e6798863db2f0ad93683
3630	Aberlin, Noah	\N	\N	m	A1645	N1645	\N	8243e44a5d97e67140b8dc618921887a
3629	Aberle, Stephen	\N	\N	m	A1642	S3151	A164	6b41cb87f1a7f919b0eb413f305d3d4b
2873	Abdullah, Jordan	\N	\N	m	A1342	J6351	A134	d8acf269362b82b7e483801c166f21b3
103	'The Welder' Phinney, Frank	\N	\N	m	T4361	F6523	\N	220be866b234f6e66f22844218e90fa3
3198	Abee, Steve	\N	\N	m	A1231	S31	A1	5757d5aee5e220c26b85c37bafd58cc3
2897	Abdullah, Salem	\N	\N	m	A1342	S4513	A134	23844a9d7252c286b1bd02cdd8334b4f
2661	Abdoun, Ali	\N	\N	m	A1354	A4135	A135	98c3b33f5e723caef7892edecd2d84d4
1757	Abbasi, Mohammad	\N	\N	m	A1253	M5312	A12	33928488c48147a3986f970a61fffe98
2876	Abdullah, M. Subash	\N	\N	m	A1345	M2121	A134	197484657f6ebe3e8366c13e2eacd658
1536	Abate, Luca	\N	\N	m	A1342	L213	A13	c6b0181ceb083e1d82da4827cc0ce31b
3345	Abela, Paul	\N	\N	m	A1414	P414	A14	3fcf8b48fac852ba80f99e72793363f6
1555	Abatiello, Tiziano	\N	\N	m	A1343	T2513	A134	9816f9e6294f772f61fcf6b9187eeb1a
447	A., Dominique	\N	\N	m	A352	D52	A	1da660486427c9380b667835de1c33fe
1218	Abad, Kike	\N	\N	m	A132	K213	A13	9c80130d0867cf42a32ba4051c3abaf1
1217	Abad, Julen	\N	\N	m	A1324	J4513	A13	f94185a52cd3671116580e78af881537
2660	Abdouloiev, Allaouldine	\N	\N	m	A1341	A4351	\N	c66a200a884ad85237cc506d69d5da6a
1514	Abastillas, Ryan	\N	\N	m	A1234	R5123	\N	ea49fe9df43e6faf38fa5bd3186a305b
378	80's Enuff	\N	\N	m	S51	\N	\N	358dd2026de2ad30c81da5ac85c948a1
2864	Abdullah, Haji	\N	\N	m	A1342	H2134	A134	a04b3750420a7853f80e8c5f948b8b18
1623	Abazopulo, Vladimir	\N	\N	m	A1214	V4356	\N	c6a5174c50a685be018f0cff0a2ba82f
40	'El Pescaíto', Antonio	\N	\N	m	E4123	A5354	\N	39c28aafc2e7ab181d8fcb5edd861d76
1817	Abbatemarco, Anthony	\N	\N	m	A1356	A5351	\N	a424d57f2c23f4cc2910b09e56a92a62
2381	Abdel-Samad, Avasser	\N	\N	m	A1342	A1261	\N	98e1c86c65ac3f454df261cd40b62961
1884	Abbey, Nao	\N	\N	m	A15	N1	A1	b9d2f3e81c0016e7c8d1bc4eab8791d3
993	Aaronson, Marc	\N	\N	m	A6525	M6265	\N	3b3b7adafb4ae48a728b542f9684ad5b
2635	Abdollahi, Babak	\N	\N	m	A1341	B1213	A134	d3ea36d12da9ab95390f54c34a755d7f
3580	Abercrombie, Brian	\N	\N	m	A1626	B6516	\N	0e2e044488764266bc1a679d142b5de3
67	'Mixerman' Sarafin, Eric	\N	\N	m	M2652	E6252	\N	4562fc3fd75c77eb59e989fcc329b9dc
1754	Abbasi, Kevin	\N	\N	m	A1215	K1512	A12	3e87b490d5cba5df0fde2549550204e7
2731	Abdul, Shari	\N	\N	m	A1342	S6134	A134	414e0bed164504a37a17ac73f575c770
2822	Abdulla, R.	\N	\N	m	A1346	R134	A134	fb46df1646819b1dc1c6f9213a40e6ac
22	'Casper' Brown, Jesse	\N	\N	m	C2161	J2161	\N	2267d3b3b52eb4d540e5cde61f4a9bc9
2166	Abbott, Tenikki	\N	\N	m	A1352	T5213	A13	b678f75b0747a07be2eb94357b83c4ef
406	A'Beckett, Arthur	\N	\N	m	A1236	A6361	A123	58ae0b4b252120dfc8a60fc7d16467d2
2409	Abdelghafour, Hatim	\N	\N	m	A1342	H3513	\N	4b6fd5ebaf35b50d10819e9543ea621c
635	Aalam, Bijan	\N	\N	m	A4512	B2545	A45	4dfbe8711e374e7a4d34624b14268cc9
191	17 Hippies	\N	\N	m	H12	\N	\N	810fc320d8ae448dd690f95d8745e0c1
264	3.72, Vibrato	\N	\N	m	V163	\N	\N	416722abbcbb9618062fd9df8580989f
2301	Abdallah, Tahir	\N	\N	m	A1343	T6134	A134	80a48ab90c9487ba041d42d64e90552f
216	2-Ply	\N	\N	m	P4	\N	\N	3994af2f43a53afe6341c8fe2c3d6b45
545	Aabel, Per	I	\N	m	A1416	P614	A14	722f669559a2e816723ec3415c6ed29c
1589	Abaya, Roger	\N	\N	m	A1626	R261	A1	1d900ba2a44cbea1c3b3e98817fb2e3f
1059	Aas, Daneil Steven	\N	\N	m	A2354	D5423	A2	be5eb60081d64b403e3e8f8b505ce1f5
355	600 Block	\N	\N	m	B42	\N	\N	aefde6d9d0c3f28116cd1fdbcc007b6a
1822	Abbatiello, Don	\N	\N	m	A1343	D5134	A134	09e27d5c55428dab4714adafe8019a7d
2049	Abbott, Greg	II	\N	m	A1326	G6213	A13	a4084ceb36ba18fc879b4fac5bac4ff6
2231	Abd El Aleem, Mamdouh	\N	\N	m	A1345	M5313	\N	656591fdcec81762032271c92a9e59f9
1130	Aaukay, Felipe	\N	\N	m	A2141	F412	A2	c5ba3d8e5d7c38f4c4ead4871af2fda5
2712	Abdul Zahra, Abbas	\N	\N	m	A1342	A1213	\N	bc69794e32678c2c338319bfad1f137a
3644	Abernathy, Derek	\N	\N	m	A1653	D6216	\N	50bd3758a1b58a263884e0828ec8a300
2027	Abbott, Edward	\N	\N	m	A1363	E3631	A13	1055d49ed9125cdf9a80c93eefcdc773
275	3Oh!3	\N	\N	m	O	\N	\N	edcd33abf17d8a1c59bf5184208d3c1c
3609	Abereoje, Omotayo	\N	\N	m	A1625	O5316	A162	f269a8f4b094270bf9f3633c917f1996
2965	Abdulrahman, Rahel	\N	\N	m	A1346	R4134	\N	77d7a9d89e133c5bfa764a6d0eca5f3e
3044	Abe, Hitoshi	III	\N	m	A132	H321	A1	cbfa9ff309a4eb9f72b31fd8e28a47af
3058	Abe, Koichi	II	\N	m	A12	K21	A1	ef45b54c4a6daf92d6fa98331ade695c
3536	Abenamar, Sanchez	\N	\N	m	A1562	S5215	A156	46b6b585d3b2f95dfb49a01f4c994885
237	2:50, Egashira	\N	\N	m	E26	\N	\N	7f5f948dca60d79e7fb4c0418121a366
1136	Aavajoki, Kaarlo	\N	\N	m	A1264	K6412	A12	6fa605685bfa9505b0efbc39d578b548
1929	Abbonizio, Alejandro	\N	\N	m	A1524	A4253	A152	5860fe4df3e55be70a77b044704522ea
3224	Abejar, Garry	\N	\N	m	A1262	G6126	A126	92714dcecde764ceff7a3cc2d6203d15
1809	Abbate, Mauro	\N	\N	m	A1356	M613	A13	20912cc765fb46b4bdb0d441942b4a71
2903	Abdullah, Sony	\N	\N	m	A1342	S5134	A134	b4f5ab74879092100653fb8052a682f8
1295	Abadilla, Ian	\N	\N	m	A1345	I5134	A134	9c705a223611ac7aa487d5a3297d2da4
3521	Abelson, Max	\N	\N	m	A1425	M2142	\N	fe26e5c39f017d7fad6796fc32d42c54
2805	Abdulkhabirov, M.	\N	\N	m	A1342	M1342	\N	8ebbc3262d60586f6808d236d20f4013
2179	Abbott, Vinnie	\N	\N	m	A1315	V513	A13	acc490d0b6a579954b4079ed0da72fdd
77	'Romero', Pollino	\N	\N	m	R5614	P4565	R56	1de0bd079638252bf0d377406938eb45
3534	Abena, Pulcherie	\N	\N	m	A1514	P4261	A15	426fdb89c28cae5ec4ef2e78c2f837bf
1729	Abbas, Saddam Hadi	\N	\N	m	A1235	S3531	A12	029b5dd7d4e0f0d7efb061c756b4e3b6
2726	Abdul, Omar	\N	\N	m	A1345	O5613	A134	fbcf74ea09f7c3047b505c4bc9880cff
2582	Abdigapparov, Niyaz	\N	\N	m	A1321	N2132	\N	bfafaf087c4a938610ff633d09df7f1d
2675	Abdu, Baharum	\N	\N	m	A1316	B6513	A13	c474f5e2ab32e0b45d7cba25aac9c3eb
2345	Abdel Mouttaleb, Mohamed	\N	\N	m	A1345	M5313	\N	7ab2f827fce0fe5d99a0b3ee1467af62
3335	Abela, Gérard	\N	\N	m	A1426	G6314	A14	6115cbffb8faac0f3ea5a43187c69521
1713	Abbas, Moe	\N	\N	m	A125	M12	A12	38702aa6edcd63839369dcad710e16ee
909	Aaron, Jermaine	\N	\N	m	A6526	J6565	A65	b8149cd82e918a98b6488f71f34f712d
3039	Abe, Hiro	\N	\N	m	A16	H61	A1	c0a0761d64af2220d25724e82408f010
3338	Abela, Koby	\N	\N	m	A1421	K14	A14	2034b08dbd0d55d507283ce5e97d4a0a
549	Aaberg, Linus	I	\N	m	A1624	L5216	A162	fee737a860bb7250a9b20fb59943fb54
750	Aames, Willie	\N	\N	m	A524	W452	A52	f983dd44bb1392c1575dfe5ffb087e1b
1336	Abaidoo, Essandoh	\N	\N	m	A1325	E2531	A13	2b67a2c561c210c6b692c6bf78559779
3260	Abel, Glenn	\N	\N	m	A1424	G4514	A14	3ca3b88128f32a59d52898ff549075e7
808	Aarelo, Jaan	\N	\N	m	A6425	J564	A64	065aec07f731a5638112367cca78afc3
2294	Abdallah, Mouzahem	\N	\N	m	A1345	M2513	A134	3c5e648e25d308e483696cc076d2222f
940	Aaron, Piet	\N	\N	m	A6513	P365	A65	a506e087a5b3557030cae86b5e5172aa
334	5, Johny	\N	\N	m	J5	\N	\N	5f828597ba9190b4ce4d6e286f479cd2
1187	Abad, Cristina	II	\N	m	A1326	C6235	A13	31412c779d2d98896fd24b81f043143a
3549	Abenhaim, Lucien	\N	\N	m	A1542	L2515	A15	8eef6f4b49dc9391e57acd39176ce9c9
434	A. Martin, Mitchell	\N	\N	m	A5635	M3245	\N	e0d02d9c2b3c7e6680be61e6ed482fd1
1971	Abbott, Andrew	II	\N	m	A1353	A5361	A13	2580296b8fbf1e4362568b78ac1ab3d2
1648	Abbadi, Danny	\N	\N	m	A135	D513	A13	1d2da48ec7d64f6c0f1722977591c0ae
1875	Abbey, Ian	\N	\N	m	A15	I51	A1	d76c9b8bb435e98248a776906a8fb40f
666	Aalto, Eeli	\N	\N	m	A434	E43	A43	4948541e807102a41e272cf8925f5f57
1709	Abbas, Master Dilawar	\N	\N	m	A1252	M2363	A12	5dd719e92a5ad31620f982d9ff37f657
1979	Abbott, Billy	III	\N	m	A1314	B413	A13	e2687832ced360a409051e8d17c90d05
3238	Abel, Blake	\N	\N	m	A1414	B4214	A14	8a3e199d26212e62cca2974b4935ba97
3510	Abels, Scott	\N	\N	m	A1423	S2314	A142	f36a14c5d06769b0e865dd141238d576
2683	Abdubachayev, I.	\N	\N	m	A1312	I1312	\N	92923a88db720f3a8aafd89c6fce3016
1597	Abayo, Shadrack	\N	\N	m	A1236	S3621	A1	cdeeacfa8dcef75ae2f323ce521831ca
2460	Abdella, Marlon	\N	\N	m	A1345	M6451	A134	36ed24be68684f4cbd56dc1ee1925015
2431	Abdelhamid, Rashid	\N	\N	m	A1345	R2313	\N	3057ca63f4763052804cf44c37dcdd5c
3023	Abdürrahmanov, I.	\N	\N	m	A1365	I1365	\N	552012ff3234c906c2c30d442c2273a0
2620	Abdoch, Ramzi	\N	\N	m	A1326	R5213	A132	5afea606e94fc7e00c45a4172a41af33
1727	Abbas, S.K.	\N	\N	m	A12	S212	\N	66dfefd46203e83ac6babd36db74e48d
3466	Abellard, Dominique	\N	\N	m	A1463	D5214	\N	6438a344f751dc538cb30d400813153f
1360	Abakaz, Suvit	\N	\N	m	A1213	S1312	A12	51ef5bcae6254af701fb5b0b8236803d
1918	Abbo	I	\N	m	A1	\N	\N	b95bb4c7427af46e90567d887aaf4b9c
304	41st Sakya Trizen, His Holiness the	\N	\N	m	S3236	H2452	\N	752c278b2bc1a1f4811ee0c8f649241a
3167	Abed, Muhammed	\N	\N	m	A1353	M5313	A13	608e47b775aa84f3fb6f240f3ce7c409
325	5 Gailtaler, Die	\N	\N	m	G4346	D2434	\N	8e83cf0dc933ab25b14839266f4edd7c
998	Aaronson, Trevor	\N	\N	m	A6525	T6165	\N	21cf62dfa149e2b24f02d320fd91c4cd
3638	Abernathy, Andrea Beth	\N	\N	m	A1653	A5361	\N	6c367c9c2862f2334ff15fb37f8bbad8
274	39 Steps, The	\N	\N	m	S3123	T2312	S312	8f8adcbcc4355f97e0c6ea64e0941815
1928	Abbondanzo, Scott	\N	\N	m	A1535	S2315	\N	3719fcefda1590fa5e01c01a001e814d
1779	Abbasov, Mammad	\N	\N	m	A1215	M5312	A121	2a4117b560d6bcc09793fd6c06ce5cd7
2248	Abdala, Gabriel	\N	\N	m	A1342	G1641	A134	788a581b568005a8d9f2164c16176c2b
293	4-5, Sess	\N	\N	m	S2	\N	\N	8b856298716f5c9325352e30bbd97b75
2230	Abd Al Fadeel, Amjad	\N	\N	m	A1341	A5231	\N	668f29f3025a68577161b9d44b730af8
1843	Abbe-Schneider, Martin	\N	\N	m	A1253	M6351	\N	6aa14fd313e693c949ba5429d85e0318
1009	Aarsand, Reidar	\N	\N	m	A6253	R3625	\N	6195799edbe7b41af63d59768a20dc63
1269	Abadi, Payman	I	\N	m	A1315	P513	A13	0b0f70704358584b124090e3bc1f8682
547	Aaberg, Dennis	\N	\N	m	A1623	D5216	A162	4402c2279b473559d6915e390445d880
2439	Abdelkader Taleb, My Alaoui	\N	\N	m	A1342	M4134	\N	60aa4a7637cca16a9691e5e8629cbe83
2023	Abbott, Don	II	\N	m	A135	D513	A13	e82d7211b16e0ff53557c4da00fcc16e
535	A.V., Subba Rao	\N	\N	m	A1216	S161	A1	24d4f2f61cb7c2b47a93d95fb1fd40a1
528	A.R., Krishna	\N	\N	m	A6262	K6256	A6	16488a76ff582ed55e0cd71390f52732
2310	Abdat, Naif	\N	\N	m	A1351	N13	A13	ec6acad14393c05107eeb58ab6772761
575	Aadne, Daniel J.	\N	\N	m	A3535	D5423	A35	5c7cde5c4aa3dd32e42e6d6e4991550b
2213	Abbruzzese, Giacomo	\N	\N	m	A1625	G2516	A162	6680b8e309a037692c130bb488494adb
1878	Abbey, Jennifer Jay	\N	\N	m	A1251	J5162	A1	4b1cb65ec1922aa6f9e6ac306019c5d8
2836	Abdullah	XII	\N	m	A134	\N	\N	141af8571cd7fcb91e4cca4f0a0230b8
3166	Abed, Joseph	\N	\N	m	A1321	J213	A13	840232ebd29fa8553a71b490f8398a3a
3248	Abel, Dominique	I	\N	m	A1435	D5214	A14	a3c4dc50cd0af36def7ab78ffbf4f294
2471	Abdellatif, Chegra	\N	\N	m	A1343	C2613	\N	74d1214eca50898f6fedfde7f39bf474
2524	Abderahmane, Hadj	\N	\N	m	A1365	H3213	\N	bd9c49a81edcfe76f5b082a03eac2a9b
3402	Abelin, Lars	\N	\N	m	A1454	L6214	A145	ae44c65fd9b60b947f085ac19e33a59b
770	Aanensen, Kristian	\N	\N	m	A5252	K6235	A525	8b1e39d362b9428e82d77a784eec44ea
1457	Abarientos, Billy	\N	\N	m	A1653	B4165	\N	1377cdfdfd5f9f480fbe98954e457c33
2781	Abdulahad, Prince	\N	\N	m	A1343	P6521	\N	ebc4a8d04ef9d66a9c5fde4e3549d1ac
207	2 Dope, Shaggy	\N	\N	m	D12	S231	D1	3d334be7b1da5030ca5e46046b1df5bf
1726	Abbas, Roshan	\N	\N	m	A1262	R2512	A12	f0e2d4a8009d42a88b8770ae2f90c89e
3135	Abea, Luis Pérez	\N	\N	m	A1421	L2162	A1	2bc75ef0a5b67d1368953217672dffb8
1652	Abbadzi, Brahim	\N	\N	m	A1321	B6513	A132	589ca9789bfb4dc48f6e0f4c752fd089
3190	Abedini, Hossein	\N	\N	m	A1352	H2513	A135	82d66f212f8eb2f65752006553227156
2764	Abdul-Rahman, Hanya	\N	\N	m	A1346	H5134	\N	0d5af8c0a5e028f4f34e4f6835553a16
3271	Abel, Jon	\N	\N	m	A1425	J514	A14	7f3d728113f67befd6a798a70d4907ba
185	13th Committee	\N	\N	m	T253	\N	\N	bf023c1f3c61f2b6fe392fd0b1e55823
3385	Abeles, Ben	\N	\N	m	A1421	B5142	A142	5ee6fc4224d410ca024f79f84814c103
1785	Abbassi, Abdallah	\N	\N	m	A1213	A1341	A12	774e3149ad0866cd616d9b39ed107751
3215	Abeijón, Ezequiel	\N	\N	m	A1252	E2412	A125	ed10f0e93824178b1d1a46faab9ab52a
1123	Aastrøm, Freddy	\N	\N	m	A2365	F6323	\N	6317c1ca7dea2a6f53ee4f097637388c
1607	Abaza, Mohammed	\N	\N	m	A1253	M5312	A12	70d6fef669768ce567b322e20cdd406a
394	986, Spiritu	\N	\N	m	S163	\N	\N	01e16819df068fd72d7584129d5d84bd
986	Aaronsohn, Doron	\N	\N	m	A6525	D6565	\N	3b00bdca5cffa3dd1fc171f50e450db1
3434	Abella, Daniel	I	\N	m	A1435	D5414	A14	c87441db1393828243724447b85b2d99
851	Aaron	XIV	\N	m	A65	\N	\N	a03a4ba9111bd7a9c4b965b65395a20b
1158	Abaas, Saleem	\N	\N	m	A1245	S4512	A12	05a7b6bf5d70c88bd7ec4e52012ea804
456	A., Kevin	\N	\N	m	A215	K15	A	455e31a69a3fffad8b244b68132d9097
1354	Abakar, Hadje Falmata	\N	\N	m	A1263	H3214	A126	6eafee6cfadc2d292997e8395a0b8851
2637	Abdollahi, Mostafa	\N	\N	m	A1345	M2313	A134	87605177d027f06c1cecff65eef561e9
1460	Abarkoroff, Rabadan	\N	\N	m	A1626	R1351	\N	e942c61834fdae23d95210e41dfd82a7
2694	Abdul	XVII	\N	m	A134	\N	\N	4a640484a59d9f8c2e2a47604eb7c48a
820	Aarles, Jeffrey	\N	\N	m	A6421	J1642	A642	4b165ba53e3ccc1e6b57eefb707d13f4
1425	Abanses, Juan Carlos	\N	\N	m	A1525	J5264	A152	6fda5e6dd79337cfc5a830b1d712a8de
2606	Abdo, Hamza	\N	\N	m	A1352	H5213	A13	4640ef00118c71321cf788ba32ce30ae
1547	Abatelli, Tyler	\N	\N	m	A1343	T4613	A134	899858d01fcfe9644a3ec69679fe4b82
664	Aalto, Alvar	\N	\N	m	A4341	A4164	A43	1b10fed3232aa4c809f49dc9af09c492
364	6995	\N	\N	m	\N	\N	\N	d8567273b20e64233b575a130159a15d
1303	Abadjiev, Vasil	\N	\N	m	A1321	V2413	\N	4810a783dd12fd32da2d6be7c7f04de8
1914	Abbitt, Travis	\N	\N	m	A1361	T6121	A13	c988c9aaf5fb5615a061b1c5d6fe648d
2798	Abdulkadir, Bangin	\N	\N	m	A1342	B5251	\N	cc46b22a25cff8201082ddacb82ff4bf
393	98 Degrees	\N	\N	m	D262	\N	\N	3235abaaa022c42ae63c3fc2078a780c
1510	Abassian, Ahmad Ali	\N	\N	m	A1253	A5341	A125	b05ba419e8090d3559e2beb8a20228cd
2175	Abbott, Tony	III	\N	m	A135	T513	A13	731556db01ec62a9919175e9226a9ac9
137	., Ino	\N	\N	m	I5	\N	\N	52466b3d4117ef33f6283dca838eddc2
397	?, Mr.	\N	\N	m	M6	\N	\N	5519c231103617404bf466ac7503797d
1794	Abbate, Carlos	I	\N	m	A1326	C6421	A13	72c6e0540feff757592654a1d1dcf873
1913	Abbiss, Reg	\N	\N	m	A1262	R212	A12	6740149469c7212d047eec12929eea5e
1042	Aarun, Lorenzo	\N	\N	m	A6546	L6526	A65	09746fe8a65192e4e65dc267b6fe2212
2121	Abbott, Norman	IV	\N	m	A1356	N6513	A13	90e868ed1a27feb034f738b82d190c41
2311	AbdeCaf	\N	\N	m	A1321	\N	\N	42f97a2cd4d2686a539456f9e253dace
728	Aaltonen, Tarmo	\N	\N	m	A4353	T6543	A435	41c1d0820d666894d1f354cceae1f7aa
3376	Abeledo, Enrique	\N	\N	m	A1435	E5621	A143	3c221bca14af71821c8bafc29fad649c
3153	Abecera, Elie	\N	\N	m	A1264	E4126	A126	3ed805eb748976ae4644eb27d14b2e69
1297	Abadillo, Casimiro García	\N	\N	m	A1342	C2562	A134	17c0dd635b65bb78b834df6dad6517d7
789	Aaran, Steve	\N	\N	m	A6523	S3165	A65	03cc6409e6fcec57a8adba613fa1de93
2092	Abbott, Ken	I	\N	m	A1325	K513	A13	33c585b5f231054b30c9ae0975b05262
2899	Abdullah, Shahriar	\N	\N	m	A1342	S6134	A134	0be424fbd777a944444a9470e23ddb1f
1987	Abbott, Bruce Robert	\N	\N	m	A1316	B6261	A13	09e99068501caa5d7dfc50f818ea577e
1026	Aartiles, Iván	\N	\N	m	A6342	I1563	\N	001123e073bbb5796202f88d0942edb1
1324	Abagnale, Sonny	\N	\N	m	A1254	S5125	\N	54d1c2fcfdad0389e3e01b63b291fcf6
521	A.N., Jorge	\N	\N	m	A5262	J625	A5	c0ff5153a8e8c56695dbfff2debbe607
2821	Abdulla, Nassar	\N	\N	m	A1345	N2613	A134	5dd2ab841103bd0c2675c18416154fb3
1893	Abbeyquaye, Ernest	\N	\N	m	A1265	E6523	A12	b9e4c173d6f789392bdbd477419233d7
1710	Abbas, Md.	I	\N	m	A1253	M312	A12	517ddc4609bbb4eabf3d1cfc20639ada
1144	Aayce, Kaan	\N	\N	m	A25	K52	A2	f555c9e52b4a2aa369bef3d856d05092
523	A.P., Deepak	\N	\N	m	A1312	D121	A1	17880877cac99fe5906cc838cb8844f5
3370	Abele, Joe	\N	\N	m	A142	J14	A14	c4d01b056258fed7bdcfd22cd4b1dd34
2238	Abd Rahman, Zureen	\N	\N	m	A1365	Z6513	\N	e72140fa8b6578f4278b10fa703bf2a8
2587	Abdillah, Muhammad	\N	\N	m	A1345	M5313	A134	2bc3e27033d177a6fff6779a1acb8ad4
2526	Abderezai, Siavash	\N	\N	m	A1362	S1213	\N	6af986f2bb6289210b258a212f7adff8
1413	Abani, Chris	\N	\N	m	A1526	C6215	A15	b567afac24e94e7aca41196660e64d21
1721	Abbas, Naushaad	\N	\N	m	A1252	N2312	A12	ca8c297dbd2db423d84a7b532f4f65b3
511	A.J.	VII	\N	m	A2	\N	\N	6e39de6d1c5ecdc584e873de47eb073d
2086	Abbott, John M.	\N	\N	m	A1325	J513	A13	035f09a8f45862a236b7ab518763fb10
2104	Abbott, Mark	V	\N	m	A1356	M6213	A13	e0be752030e29dae18625f693bb7e31c
2646	Abdou Jr., Cheb	\N	\N	m	A1326	C1326	\N	97071ed382713195a366317fd52bf9ad
846	Aaron	VI	\N	m	A65	\N	\N	7f67ce1bed7729a2a4a05735e0748d9d
350	6 Días, Los	\N	\N	m	D242	L232	D2	d89de4a1c4882a852f8f5b52bc1b24df
1632	Abba	\N	\N	m	A1	\N	\N	5fa1e1f6e07a6fea3f2bb098e90a8de2
451	A., Hocine	\N	\N	m	A25	H25	A	034ba7b1436ca545bbc8fda57bfeb9b9
2245	Abdah, Mario	\N	\N	m	A1356	M613	A13	7f246357b67550dee726a2e5dcd838b5
2476	Abdellatiff, Chaouki	\N	\N	m	A1343	C2134	\N	3ecf8b62e203c1fd47b84db791873016
3160	Abed, Amr	\N	\N	m	A1356	A5613	A13	447959ad02a0f344ceb1417940fc63b7
1342	Abair, Tim	\N	\N	m	A1635	T516	A16	440c1a5460e30620367052deced8c1a1
1099	Aaserud, Mikael	\N	\N	m	A2635	M2426	A263	bcd93760872910114919deebfda784ef
2602	Abdo, Aziz	\N	\N	m	A132	A213	A13	808c8756a40282f1110cd60bea5a0979
3507	Abels, Gregory	\N	\N	m	A1426	G6261	A142	f761a60b7e93248803c50d8d5da9e8f4
2955	Abdulov, Omar	\N	\N	m	A1341	O5613	\N	4245635cbff2b2374583e9e6fc1000ac
231	23 Double	\N	\N	m	D14	\N	\N	e2d911fb6a8e55d7bba7d57e7f1187c6
432	A. Hadi, Dudung	\N	\N	m	A352	D3523	A3	ac8b713f05bd3f0b4deb588511f951cf
1696	Abbas, Hector	\N	\N	m	A1236	H2361	A12	5a0ca2c89a52f113fd9352601c877b83
149	., Sundar	\N	\N	m	S536	\N	\N	94e0fb7f4ecdd1a9f0544db5d98dbd94
2733	Abdul, Tabish	\N	\N	m	A1343	T1213	A134	02354e9218b41cf2b4d06a458f6871a5
3146	Abecasis, Jose	\N	\N	m	A12	J212	\N	9452c6d04ebcd64026c4849a438eb33c
2033	Abbott, Frank	III	\N	m	A1316	F6521	A13	0c1978c77d9a4c5a555d42db4f512401
3346	Abela, Toni	\N	\N	m	A1435	T514	A14	3fa9a3760ae43ffa28508c1cb1af4e12
2860	Abdullah, Elijah	\N	\N	m	A1342	E4213	A134	cac5e5821b2dd901b3479f8e05387f27
681	Aalto, Raimo	\N	\N	m	A4365	R543	A43	d3907b6dd2b7e223c4cf14a3807e11a2
2667	Abdrakhmanov, Abdrashid	\N	\N	m	A1362	\N	\N	981efce85021f46da96d0da473a18ed4
1634	Abba, Dimi Mint	\N	\N	m	A1353	D531	A1	be9a352e80f4a164c1e2ba287797af27
1609	Abazadze, Nikoloz	\N	\N	m	A1232	N2421	\N	d0dbbc1352687300d35b2926fc3952a9
1723	Abbas, Qaiser	\N	\N	m	A126	Q2612	A12	9c9883a323c676b008ffe20470f56480
2979	Abdur-Rahman, Ismail	\N	\N	m	A1365	I2541	\N	9bbd99e2c6eb910301b446f7c0243e4a
292	4, Son	\N	\N	m	S5	\N	\N	9cdb5eb9a8da2a9abb10084700fee4b6
835	Aarnio, Tuomas	\N	\N	m	A6535	T5265	A65	bbd79033b87c54f4cd181763a1308b3b
2134	Abbott, Phillip	\N	\N	m	A1314	P413	A13	6cd8f221df5e999848742e95e7a47bd3
1312	Abadzhiev, Lyubomir	\N	\N	m	A1321	L1561	\N	ab3aceff2681b32c5921824c9c98d64a
1376	Aballay, Ruben	\N	\N	m	A1461	R1514	A14	d568bb7c470d3423b93bc22b18e5f3bc
1578	Abay, Reynard	\N	\N	m	A1656	R5631	A1	913b2e027d4b17bd7a51e60306a7824a
3621	Aberle, Erich	\N	\N	m	A1646	E6216	A164	1c690031877d91db6dc03c0aeb3ae8e0
1908	Abbink, John	\N	\N	m	A1525	J5152	A152	b6cc0bd499586ea858f7e2b65ce8db3b
1113	Aasim	\N	\N	m	A25	\N	\N	89f1e3685e0c625f74653978dc81aa70
3606	Aberdein, Chris	\N	\N	m	A1635	C6216	\N	22dfd98e4f4d036fee35a3e444a8f99a
719	Aaltonen, Markus	II	\N	m	A4356	M6243	A435	f0505421bbaa6d1918e549062fd951d3
1430	Abaoag, Jose	\N	\N	m	A12	J212	\N	cdb19847dbfb30e10a4998ba0837e00f
3625	Aberle, John	\N	\N	m	A1642	J5164	A164	179a37e7c681eee0deb8800e503da900
818	Aarikka, Juha	\N	\N	m	A62	J62	\N	ab9b21213c7c6dc0a2978290f3896a11
3113	Abe, Tetsuya	III	\N	m	A132	T321	A1	2d34928fdcb244cd8f34c88a8bff0699
2958	Abdulov, Vsevolod	\N	\N	m	A1341	V2143	\N	2f709882a51f8520fb63ff03e2e7ba33
2914	Abdullahu, Drita	\N	\N	m	A1343	D6313	A134	bbc2715b259d092128d3b33d65ba76cd
492	A.C.M. Gospel Choir	\N	\N	m	A2521	\N	\N	dff0c2e096ea74b76731d37afcc34efc
227	21, Proyecto	\N	\N	m	P623	\N	\N	2f2020a813690916dd8455184ac7c16e
1411	Abanes, Richie	\N	\N	m	A1526	R2152	A152	a1aefc48e38e48ef69e309bba7faf8c7
1697	Abbas, Hussein	II	\N	m	A125	H2512	A12	8a9dcdf2b55e0f975f62327d449e9d4d
1581	Abaya, Araby	\N	\N	m	A161	A61	A1	2798264df78835dade03ad932d4d97c4
1614	Abazia, Joe	\N	\N	m	A12	J12	\N	15771c8ebcc9a4a947e51ca1ea0d8252
2203	Abboud, Nor-eddin	\N	\N	m	A1356	N6351	A13	56b58fc8896c76437ed9fb74d9dc7248
2745	Abdul-Hakeem, Suliman	\N	\N	m	A1342	S4513	\N	74edd769d2d7b59ced3be40962b5f308
2282	Abdallah, Daniel	\N	\N	m	A1343	D5413	A134	2207f496f07b619eda3ccc40ac5e9b6d
46	'Finchie''Coveney, Finbar	\N	\N	m	F5215	F5161	\N	dfed347fe24388549116132f87cd2dfd
25	'Cuba', Luis	\N	\N	m	C142	L21	C1	44fa7a8581bf3325a5b2e8b25b4a46df
475	A., Rod	\N	\N	m	A63	R3	A	89ce9d870c479e4effcc46f3e929746e
1128	Aattache, Jamel	\N	\N	m	A3254	J5432	A32	21c6913b613954e4975a1103bbfc4987
1546	Abate, Tom	\N	\N	m	A135	T513	A13	666f3ee1cd08f06427b44bfd4c3ffd02
3109	Abe, Tatsurô	\N	\N	m	A1326	T3261	A1	3782b73d596c60efcfb5df2e0f845e01
1289	Abadie, Lisandro	\N	\N	m	A1342	L2536	A13	fbe6942026ad93bda41a9c6d9eb266d7
3537	Abenayake, Lakshantha	\N	\N	m	A1524	L2531	A152	86f8696d19e4559b1c723086383de4f7
561	Aada-j	\N	\N	m	A32	\N	\N	8b095f9eabef098e44b398653ad61f62
2575	Abdi, Reza	\N	\N	m	A1362	R213	A13	6736714acb50e656257c37f8a96d349d
1434	Abara, Ignatius	\N	\N	m	A1625	I2532	A16	869def7ece470a36b929ea8bcd89f951
3274	Abel, Joseph Scott	\N	\N	m	A1421	J2123	A14	83d0a1c4e5b7713dfc6d8f260f54efdf
1137	Aavani, Siroos	\N	\N	m	A1526	S6215	A15	f3e4ad4c52d0d01bbbd3edae470e2331
2537	Abderrahmane, Samir	\N	\N	m	A1365	S5613	\N	5fa5373dda1dcae26aadfe0d90213dce
387	8th Earl of Carnarvon, George Reginald Oliver Molyneux Herbert	\N	\N	m	T6412	G6262	\N	638a07712ace6a1e5f850940a63105cd
2835	Abdullah	VIII	\N	m	A134	\N	\N	7049f74cead20ab709fbd14fe1d6e327
1032	Aartomaa, Ville	\N	\N	m	A6351	V4635	A635	b1aa1b118046b4c548aeb53df2dedc3c
148	., Steven	\N	\N	m	S315	\N	\N	5528867a974b748242f28dc4871400c4
665	Aalto, Davin	\N	\N	m	A4315	D1543	A43	ef95c68fa1fe1ce370814349b897a20a
534	A.V. Jr., Subba Rao	\N	\N	m	A1262	S1612	A126	6930211415448058f7f3c9b7938acb6f
2744	Abdul-Basit, Malik	\N	\N	m	A1341	M4213	\N	20e86a7520e03a82899cc09d3c9a1969
317	5 Amigos	\N	\N	m	A52	\N	\N	0f958c82b739064da4f015733fcce14b
3120	Abe, Tsuyoshi	IV	\N	m	A132	T21	A1	f234f72493de88c157a236ea3a996284
1474	Abarzua, César	\N	\N	m	A1626	C2616	A162	0efc3374b3fd95e41afb9b2f4a5c5449
788	Aaran, Abraxas	\N	\N	m	A6516	A1626	A65	aa3199342a89f7130a3a10a18de77050
1030	Aartoma, Kari	\N	\N	m	A6352	K635	A635	8ceb59439f6d0af6ad9a4982624146d1
1112	Aasif, Hyaat	\N	\N	m	A213	H321	A21	34ae407dadd0af733e62bc42c2789851
3396	Abelgas, Gus	\N	\N	m	A142	G2142	\N	9004ec57bc4aa13bca284f3857cb39bc
3256	Abel, Francesc	\N	\N	m	A1416	F6521	A14	3d73b0a176bd3eb70c21fc384a6681c6
2473	Abdellatif, Hilal	\N	\N	m	A1343	H4134	\N	52c10bb12f069936e3e51ad8e1bc0018
1939	Abbot, Chris	\N	\N	m	A1326	C6213	A13	bbd64c5d60070b4158d505f2e9fc3acc
942	Aaron, Robert	I	\N	m	A6561	R1636	A65	1233cdfd961722143ae016319fc41c11
544	Aabel, Hauk	I	\N	m	A142	H214	A14	b71eac23495c483236b818c249856378
1174	Abad, Alex	II	\N	m	A1342	A4213	A13	7e02b30a585a0d13449efd0ccff9198d
337	5/8erl in Ehr'n	\N	\N	m	E6456	\N	\N	093b002c8ae8dbd8e7b6054015a2c542
443	A., Bobby	\N	\N	m	A1	B1	A	15537fc54e5599c18e97e74fe1739832
338	50 50	\N	\N	m	\N	\N	\N	3a88471e13c7f9998b184a7240c04c8e
2115	Abbott, Mitchell	\N	\N	m	A1353	M3241	A13	8ca82cc201fa1466c12f4ff59124ec6c
1169	Abad Faciolince, Héctor	\N	\N	m	A1312	H2361	\N	a9ca08a6ef068be858e07c623f2629e5
3064	Abe, Kôji	\N	\N	m	A12	K21	A1	62dcf8ae3f1d25d3dd58b94da742eba3
567	Aadi, Sam	\N	\N	m	A325	S53	A3	22a80723caf33915a06f044dd854ddf4
3334	Abela, Frédéric	\N	\N	m	A1416	F6362	A14	acd1ca0c3d67a5b69b7f17ad666d3ddf
3476	Abellira, Reno	\N	\N	m	A1465	R5146	A146	8f4f682d61e77fe333320b6fbc4109fe
819	Aaris, Jan	\N	\N	m	A625	J562	A62	2ee87ac0afa8a52226cfc5ab56b14c76
3089	Abe, Ryûtarô	\N	\N	m	A1636	R361	A1	d987d75228de46d5d2711da88a0ceb3d
1441	Abarca, Adrian	\N	\N	m	A1623	A3651	A162	9f120be5572258f6bf797e0141f3086a
3257	Abel, Frank	I	\N	m	A1416	F6521	A14	5d32dc488d1d704d6d00edb699c931ea
1999	Abbott, Christiaan	\N	\N	m	A1326	C6235	A13	13c87d8a28600cb9018e3b8888f3e76c
2405	Abdelfethah, Ahmed Salah	\N	\N	m	A1341	A5324	\N	e61d7d559ffbacaa7f3220210d752be5
1759	Abbasi, Najibullah	\N	\N	m	A1252	N2141	A12	ada9794c738572ea9ec6811915f45027
2941	Abdullayeva, Anaxanim	\N	\N	m	A1341	A5251	\N	05b31c72717ba1c831323d6a64dba749
1858	Abbes, Mohammed	\N	\N	m	A1253	M5312	A12	44709351a973329c84557e11aae2e13e
1541	Abate, Richard	III	\N	m	A1362	R2631	A13	6768b0a3fccfeabb1a01d1dcc89bf015
744	Aamei, Anass	\N	\N	m	A52	A525	A5	8e79f6fd37927daa97bbbc2bd6b56511
965	Aaronovitch, Ben	\N	\N	m	A6513	B5651	\N	aa14e4cf0bf40c40da92aa7ede901faa
2921	Abdullayev, Agasalim	\N	\N	m	A1341	A2451	\N	6595319fec4761f9d95738661db1d105
1341	Abair, Mohamed	\N	\N	m	A1653	M5316	A16	9139d5374c7d3aa4fe19600006df285c
15	'babeepower' Viera, Michael	\N	\N	m	B1616	M2416	\N	c44ccae29eca9494b62b3f9466cf1fe1
2095	Abbott, Kevin	II	\N	m	A1321	K1513	A13	12e64f4258ef5d3c37c83ec24d9bbf5e
76	'Raff'	\N	\N	m	R1	\N	\N	8fc565e774247abfaedcf290321b40ba
2734	Abdul, Tefo	\N	\N	m	A1343	T134	A134	bf07ac328ded7ca5012b8bcc707cb848
433	A. Luce, Michael	\N	\N	m	A4252	M242	A42	db56025f61df540037ac333eb3073f80
2708	Abdul Razak, Abdul Hakim	\N	\N	m	A1346	A1342	\N	d29b4f82838015b1d3cdfce425582af9
542	Aabeel	\N	\N	m	A14	\N	\N	6d7974915dc7e5057e66573505afbef3
1865	Abbey, Brad	\N	\N	m	A163	B631	A1	6dd89ae26cdfc3d209dbfcdc868933d3
554	Aaby, Kristian	\N	\N	m	A1262	K6235	A1	cf3303804daad98e68fd3c5affb1e3be
2458	Abdella, Amber	\N	\N	m	A1345	A5161	A134	d93036305e6d9480273319e237d11625
1050	Aarya	\N	\N	m	A6	\N	\N	189a0d20e25fcd72dccd43774b4cc744
1815	Abbate, Steven	\N	\N	m	A1323	S3151	A13	d55f56aeb79b057beddce2f1d27a519e
3607	Aberdein, Keith	\N	\N	m	A1635	K3163	\N	6329d4fdf2ade323d6e36d7489b983dd
1946	Abbot, Jim	I	\N	m	A1325	J513	A13	4116e37c209529ab894e3b39d022bce5
598	Aagaga, Benjamin Ikhine	\N	\N	m	A2152	B5252	A2	00e643d94ff41776cab67c8f1cacea7d
346	5ivesta Family	\N	\N	m	I1231	\N	\N	116d4b5db6125639280f67ea32fc6a69
2127	Abbott, Paul	III	\N	m	A1314	P413	A13	2d7a352e09ce98ba6ab56542af126a31
2251	Abdala, Lele	\N	\N	m	A134	L4134	\N	3bf73117bd3a02eca7e54fbdc426121c
2723	Abdul, Jubran	\N	\N	m	A1342	J1651	A134	b4d15d6b6abb6be7f6811e40ae79e39c
2754	Abdul-Kareem, Hussein	\N	\N	m	A1342	H2513	\N	b222f85d87b5a0d2b0ef113800a91a90
2999	Abdus-Salaam, Luqman	\N	\N	m	A1324	L2513	\N	d38cf7cc3fcd0f2baf56262d75b9e1cc
2846	Abdullah, Akeem	\N	\N	m	A1342	A2513	A134	6523ad76d970fc6887164e158a349f96
1116	Aasland, Bjørn Eivind	\N	\N	m	A2453	B2651	\N	b9e063323b14b5bbaed70f101136a655
1371	Abalayan, Errol	\N	\N	m	A1456	E6414	A145	6ba9ce6441cdcfdd6705a0f2c741c140
1707	Abbas, Malik	\N	\N	m	A1254	M4212	A12	8d4cb1f9fbf7ddc9d5eafe8bb7107e07
2749	Abdul-Jabbar, Kareem	II	\N	m	A1342	K6513	\N	476212d7d2ffb106d99ea43c40d3d072
988	Aaronson, Cole	\N	\N	m	A6525	C4652	\N	1ff2287e48f98b1a391035027b7c47c9
1093	Aasen, Lars	\N	\N	m	A2546	L625	A25	561c5dfd2e7e7b5823facf80cf88314f
3636	Abernathy IV, Ralph David	\N	\N	m	A1653	R4131	\N	b5cefa3550e0a8b6432f14897761fa3d
2983	Abdurahman, Rahal	\N	\N	m	A1365	R4136	\N	923df3039253069abea52f9fd1165790
1673	Abbas, Ameen	\N	\N	m	A125	A512	A12	18796d58cffb2d3fca54e4d43c91ba68
729	Aaltonen, Teemu	\N	\N	m	A4353	T5435	A435	b970744bb27edfc9eafc301761c334f6
1545	Abate, Thommy	\N	\N	m	A135	T513	A13	574f2f07231c2d0178881e63dd3746ee
2982	Abdurachman, Klaus	\N	\N	m	A1362	K4213	\N	0cd7537f4796bcad683dd723ff623841
2615	Abdo, Mostafa	\N	\N	m	A1352	M2313	A13	89e9d17ed9c44835c9e8ff609cdb9d9b
1415	Abanikanda, Dayo	\N	\N	m	A1525	D1525	\N	63ad3a29af022879c3af7d4981c2d7a2
1706	Abbas, Majed	\N	\N	m	A1252	M2312	A12	b2896435f9334c8a63fd6ca87e3dad9d
591	Aagaard, Jan	\N	\N	m	A2632	J5263	A263	63cb3c3755b162af694d0680a8ba76f4
2039	Abbott, G.P.	\N	\N	m	A1321	G13	A13	a315d7fe222390f038cec4b7d00721f4
1163	Ababsi, Jamal	\N	\N	m	A1254	J5412	A12	0d5d17c545a490a2276e6fdb4e2f6f3c
130	., Adib Ahmad Hilmy	\N	\N	m	A3153	\N	\N	b03fbe46badeb67a237afc17d4bcddf5
1061	Aas, Gunnar	\N	\N	m	A256	G562	A2	6522ebcec24a231bfe4c0813c663ff18
3019	Abdülov, Vüqar	\N	\N	m	A1341	V2613	\N	638f2ce775331851d093e4f23d066366
1121	Aasmundtveit, Olav	\N	\N	m	A2531	O4125	\N	4fbe3c43fa28f8e578faacc33c501e1b
1266	Abadi, Lilian	\N	\N	m	A1345	L4513	A13	7907c885fb6fff1e6da8d764c00458f9
2545	Abdessamie, Ali	\N	\N	m	A1325	A4132	\N	8d220f5d518564820dc8ace97a3853b1
68	'Monkey' Stevens, Neal	\N	\N	m	M5231	N4523	\N	aab536ffda2fea2e45829fb4f105e7af
1095	Aasen, Ole J.	\N	\N	m	A2542	O425	A25	e8a62c777c3e6f0b67612334c0ba3d0f
1326	Abagourram, Youssef	\N	\N	m	A1265	Y2126	\N	f375e2e1bf13be065e2d569368fee152
827	Aarnio, Aatto	\N	\N	m	A653	A365	A65	5fc6cddcb046a58f9228b665e638d021
53	'Insane Wayne' Smith, Wayne	\N	\N	m	I5252	W5252	\N	1508f38d8c56eedfc3d63e04f4f631f1
412	A'Lexis, Charles	\N	\N	m	A4264	C6424	A42	fb401f423ad4499ce0dbb535206a901d
2530	Abderrahim, Hugo	\N	\N	m	A1365	H2136	\N	81d4468f85dd663e82dba425ee2f7113
2585	Abdilla, Ray	\N	\N	m	A1346	R134	A134	4857e9bfd27a34dd95aeeb636ba62d01
1308	Abadou, Youness	\N	\N	m	A1352	Y5213	A13	9941805546b148e16b7045410d3bde5d
3412	Abell, David Charles	II	\N	m	A1431	D1326	A14	63424a693beb039f88d62b0009788b92
587	Aagaard, Egon	\N	\N	m	A2632	E2526	A263	f703127126e5dbe4630ec11f9dc9914b
1198	Abad, Fernando Buen	\N	\N	m	A1316	F6531	A13	1209731202026a7f5d6a9ab9a687b0ca
2688	Abdukholik-zade, D.	\N	\N	m	A1324	D1324	\N	65713f097c8f9c163d525952ce7c026f
553	Aabid, Hanan	\N	\N	m	A135	H513	A13	2df8adf7932998e3fbb9970322685f7d
3018	Abdzu, Bruno	\N	\N	m	A1321	B6513	A132	99faee4619e194b88ee36fc6dc8edfb0
3574	Aberastury, Hector	\N	\N	m	A1623	H2361	\N	cd8cc16faacec52987a52a103837b77e
3157	Abed Elrani, Ahamed	\N	\N	m	A1346	A5313	\N	8a1f3493fff3a7541e6b4e09883cee9e
3410	Abell, Ben	\N	\N	m	A1415	B514	A14	3340af4bdd6dda0ea5230cc79c11890f
737	Aalund, Marcus	\N	\N	m	A4535	M6245	A453	e911fb5bbd69e3b8186cb9a7b7fdb111
1493	Abashidze, Shalva	\N	\N	m	A1232	S4123	\N	05b801427fe94f79388115195f4ec62d
320	5 Asternovas	\N	\N	m	A2365	\N	\N	c94710bff5a3de625c955b5988fadff4
1859	Abbess, Shane	\N	\N	m	A125	S512	A12	37ab661d9ee8587e4e17ac692fb86fdf
1516	Abat, Evie	\N	\N	m	A131	E13	A13	470460933e83e537a8e2cbc8e0c2774b
740	Aamand, Nikolai	\N	\N	m	A5352	N2453	A53	928f3ad8f777ec600a66ba714cb20fb8
2786	Abdulayev	\N	\N	m	A1341	\N	\N	212af2f30c9b8ffef6da8dfa5f3096bb
1021	Aarstol, Stephen	\N	\N	m	A6234	S3156	\N	e786fa4a83e1e6c29f04ec1eb6eab086
1804	Abbate, Lee	\N	\N	m	A134	L13	A13	7d94a11f20df65c92883d45fb55af19a
3268	Abel, Jerry	\N	\N	m	A1426	J614	A14	02154b39facbb5dda0a752153c10541d
2814	Abdulla, Husain	\N	\N	m	A1342	H2513	A134	901db2e00259a981aaeb8d4974af8d90
607	Aagre, Jan	\N	\N	m	A2625	J526	A26	d7234e332483de11aa86b93020775b8f
570	Aadland, Eivind	\N	\N	m	A3453	E1534	\N	4a4dd0d371d3556ad8e6db6ddf9310a2
2534	Abderrahman, Ould	\N	\N	m	A1365	O4313	\N	f3bd0fd7ab5a41e063e72172cf49ef3b
2289	Abdallah, Khaled	\N	\N	m	A1342	K4313	A134	668a9444f039398b8f19a100912e29a0
2468	Abdellatif, Abdellfattah	\N	\N	m	A1343	A1341	\N	172abd8de6cd2652a9857f709a25e739
2155	Abbott, Shawn	\N	\N	m	A1325	S513	A13	98da2a11d6bfefe7a387ab76665a166a
1889	Abbey, Stephen	\N	\N	m	A1231	S3151	A1	bd778f0902af52b8dbcdcf898a65169b
1220	Abad, Luis Garcia	\N	\N	m	A1342	L2621	A13	0c56141ef55f261035f3b04d704c53eb
718	Aaltonen, Markus	I	\N	m	A4356	M6243	A435	a57877511c2fb4ff630e4598795f19cc
1396	Abalos, Tarzan	\N	\N	m	A1423	T6251	A142	4717c1fca4e797dfaceb0aa2d5e742d5
1559	Abatourab, Adil	\N	\N	m	A1361	A3413	\N	a31e9703d025febf5e5b3aa780cc1bdd
1027	Aarto, Uuno	\N	\N	m	A635	U563	A63	5e4f97482c352974986c59c1c94a3bd6
1964	Abbott, Aaron	I	\N	m	A1365	A6513	A13	42e738693143d9bd505fedc3887a18be
2247	Abdala, Farah	\N	\N	m	A1341	F6134	A134	95541aa01bd41d027583e26a983f8084
3519	Abelson, Don	\N	\N	m	A1425	D5142	\N	0f97fdd83bd73c42bf4ee747ce79819a
1767	Abbasi, Umar	\N	\N	m	A1256	U5612	A12	f9b02052d75cce29433251d08964a6c8
2783	Abdulahovic, Mehmed	\N	\N	m	A1341	M5313	\N	545d1e65236142fadd9e041006242c0b
1807	Abbate, Massimo	\N	\N	m	A1352	M2513	A13	bd406cdd24f77262a25a315e36207377
2299	Abdallah, Salah	\N	\N	m	A1342	S4134	A134	c5545ea368aff5a2cccafbedd849520e
3454	Abella, Rey	\N	\N	m	A146	R14	A14	2bee781d1686fe753fdbed36d6d91362
1715	Abbas, Moziz	\N	\N	m	A1252	M212	A12	3f3014c274a73ef38d5edc674746e9f3
3632	Aberman, Hugo	\N	\N	m	A1652	H2165	A165	9958af98a4267134bc2a0044ffea3600
1407	Abandonded, Los	\N	\N	m	A1535	L2153	\N	ceef24124336c2f308c00aa34f8ad5d9
2512	Abdelwahab, Adil	\N	\N	m	A1341	A3413	\N	6d1cedd7bcb113660e8d21c794e97629
54	'Ivanzinho' Oliveira, Ivã	\N	\N	m	I1525	\N	\N	b64875a9a7d46068877889e862df43b6
1481	Abascal, Manuel	\N	\N	m	A1245	M5412	A124	9cbd356566291d6947b34b1b583021bf
3255	Abel, Floyd	\N	\N	m	A1414	F4314	A14	70a642e4ea3d1ce7ef05b0b49b2b6124
369	7 Seconds	\N	\N	m	S2532	\N	\N	d445cd39713ecb9098bf6db64571b3d8
155	., Zhanna	\N	\N	m	Z5	\N	\N	10cd1caa175eff581583a8f892c87d1a
\.


--
-- Data for Name: person_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.person_info (id, person_id, info_type_id, info, note) FROM stdin;
1	4147861	22	5' 9"	\N
2	4147861	19	Richard Matthew Clark was born and raised in southeastern, NC, in a small town called, Chadbourn, NC.  He has a tragic tale filled with emotion that becomes one with the canvas he paints. Clark has a way through any media to lead you into a world that traps your soul.  His mother left him at six months old and his dad that's drinking almost destroyed the both of them.  His mother came back into his life when he was twelve only to attempt to murder him.  Art was his only outlet to express his emotion. His senior year in High School he excelled in the arts and was offered a full scholarship to the Parsons School of Art and the Art Institute, as well as, an internship with Marvel and Disney.  The light at the end of the tunnel was soon dimmed as he had to put his dad in a rehab clinic and drop out of school to save their home.  He saved their home but soon after his father was released from rehab his dad furious of being admitted into the treatment center, gave the home up any way and the two went their separate ways.  With no one to seek shelter with Clark found himself sleeping in a cemetery on a cement tomb staring at the sky seeking a way out.  He went to a local community college during the day where he obtained his adult high school diploma and joined the United States Army.  He found himself joining the military where he fought in the Infantry and forever tried to find a way back to the path to use his art. He is the type of person that has faced trial after trial but no matter how many times he has been knocked to the ground he has always managed to summon the strength to stand back up and face whatever the powers that be had to throw at him.  Trying to have a real family for once he married at 18 and had 2 sons by 21. His wife turned out to be just like his mom and ended up walking out on the family and never looking back.  He was a single father and left the military where he would sell sketches and paint murals for income.  3 years past and he built a sign and graphics company and then married a female that tried to take what he had worked so hard to build. They had one child together and during the divorce proceeding the wife told the judge "Sir he can have the child I just want the money!" Clark threw the keys to her from across the court room and kept his 3 sons together.  He lost everything again but then kept the thing that mattered most....his children.  With just an airbrush left he went to the beaches of the Carolina's and started painting t-shirts for money. This fine artist that seemed to channel the spirits of the masters had been reduced to doing whatever it took art wise to eat.  He found himself working night and day to provide for everyone and with the street smarts he possessed he managed to turn money over and open an airbrush shop in the mall. Three years past and he met a bi racial girl that was born and raised in Germany. They dated for a while and she seemed to be the only one that could tame the battle tossed artist.  They were married in 2005 and now Clark finally has his family and now with four sons.  Although, Clark, has been through so much he always remains positive and humble and true to his southern charm. His work is able to captivate people from all walks of life and crosses over to all races, religions and backgrounds. His art is now world wide and his clients include everyone from the Ruff Ryderz, Warren Sapp and the Hollywood Elite.  Mr. Clark does everything from acting, producing, writing screenplays, set painting, special effects make up, music; and even owns custom body shops and mall stores, as well as, his own Production Company.  Born and raised in the Carolina's of the United States he is a hardened and battle tossed soul that still displays the characteristics of a leader. One that does not drink or use drugs; he stands as a knight making sure others do not have to struggle and feel the pain that he has known.	Tesha Dockery "germanpheonix@yahoo.com"
3	4147861	24	'Tene Clark' (17 November 2005 - present)	\N
4	4147861	28	Ghost	\N
5	4	22	5' 7"	\N
6	4	21	28 April 1966	\N
7	4	20	Los Angeles, California, USA	\N
8	4	17	Well known as rapper Too Short	\N
9	4	28	Shorty the Pimp	\N
10	4	28	Short Dogg	\N
11	5	15	Perseverance is the key to success.	\N
12	5	26	Moore, Brandon Demetrius	\N
13	5	17	Began his career in entertainment promoting and managing rap artists before eventually becoming a rap artist himself.	\N
14	5	17	His father was stationed at Fort Benning, Georgia, at the time of his birth.	\N
15	5	17	Was born at Martin Army Hospital in Fort Benning, Georgia.	\N
16	5	17	Growing up an avid zombie movie buff, he got his first ever movie role in the independent horror film, "Night of the Jackals" (2009), which featured zombie-like creatures known as "Jackals".	\N
17	5	22	6' 4"	\N
18	1739584	28	Metallicar	\N
19	2701136	19	Born in Iraq, Ja'far moved with his family to other parts of the Arab world before settling in London in the mid 1980s. While reading social sciences at the University of London, Ja'far began to assist in independent TV and radio productions in London. After attending courses in film production at London's Lux Centre, Hoxton, he began to write film criticism for the Arabic daily 'Al-Hayat" newspaper, and later for the Paris-based "Cinema" magazine.  After completing an MA in 20th Century Historical Studies and "discovering" the work of Frank Capra, Sergei Eisenstein and Dziga Vertov within the context of "political cinema", Ja'far began an MA in Film Studies, after the completion of which he worked on a PhD thesis on film adaptations.  During his film studies, he worked on a series of TV pilots and programmes for small community-based TV stations, making "Test Drive" (16mm) in 1999, and shooting the short film "Eyes Wide Open" (16mm) which was finally edited in 2005, and making "A Two Hour Delay" (BW 16mm) in 2000, which screened at a festival for independent cinema in 2001.  Ja'far has also helped organize film festivals in London and the Gulf, most notably, programming assistant at the Raindance Film Festival in 2006.  Mesocafe is Ja'far's directorial feature debut.	Anonymous
20	2701137	19	Diego Pecori alias Diego Dada is graduated in 2006 at the Art High School "Virgilio" in Empoli in the section of Photography and Film. Is currently a student at the Faculty of Arts and Humanities of the University of Florence, Bachelor Degree in "The Arts, music and entertainment". Between 2005 and 2010 he made several short films, some of which have received awards and great attention from the public on youtube.	Fab
21	31	26	Vázquez, José Rodríguez	\N
22	31	20	Montpellier, Hérault, France	\N
23	31	21	1971	\N
24	56	17	Legendary disk jockey who made his name at WINS (New York) in the 1950s and 60s; a pioneer of progressive radio at WOR-FM (New York) in 1966.	\N
25	56	17	Biography in: "The Scribner Encyclopedia of American Lives". Volume One, 1981-1985, pages 443-444. New York: Charles Scribner's Sons, 1998.	\N
26	56	17	Father of 'Peter Altschuler'.	\N
27	56	17	In 1963 took his 1010WINS NYC Radio show to the High Schools in the New York City area as part of a "stay in school" campaign.	\N
28	56	28	The Fifth Beatle	\N
29	56	39	Los Angeles, California, USA (cancer)	\N
30	56	19	Murray the K was born Murray Kaufman in New York, New York, on 14 February 1922. After an early career as a song-plugger, he moved into radio and in 1958 joined 1010 WINS. He remained there for seven years, becoming the most popular New York radio DJ. He was an early supporter of singer Bobby Darin, inspired and then 'broke' his hit single, 'Splish-Splash', and made a guest appearance on his "This is Your Life" TV tribute in late 1959.  In 1964, he was one of the first Americans to interview The Beatles, firstly by phone, later joining them in their hotel suite. From then on he acted as their "Mr. Fix-it", arranging for them to visit all the best clubs and restaurants. He also championed their records and for a while, he dubbed himself "the fifth Beatle" and became a trusted friend of the group during their American tours, though not of manager Brian Epstein, who apparently resented his considerable influence.  He left WINS in 1965 and later resurfaced as a presenter on WOR-FM - the first FM rock station.  Married six times, he died of cancer on 21 February 1982, in Los Angeles, California.	Anonymous
31	56	20	New York City, New York, USA	\N
32	56	26	Kaufman, Murray	\N
33	56	24	'Jacklyn Zeman' (qv) (14 February 1979 - 1981) (divorced)	\N
34	56	23	21 February 1982	\N
35	56	21	14 February 1922	\N
36	1739590	26	Rodríguez, José Antonio Ortiz	\N
37	1739590	20	Almería, Andalucía, Spain	\N
38	1739590	21	19 March 1964	\N
39	4147862	17	Played bass guitar with the 'Thai Brides' until April 2007.	\N
40	86	20	Maassluis, Zuid-Holland, Netherlands	\N
41	86	25	(book) (2002) De zonnewijzer	\N
42	86	25	(book) (2002) De bril van God	\N
43	86	25	(book) (2000) Johann Sebastian Bach	\N
44	86	25	(book) (2000) Een deerne in lokkend postuur	\N
45	86	25	(book) (2000) De stiefdochters van Stoof	\N
46	86	25	(book) (1999) De gevaren van joggen	\N
47	86	25	(book) (1998) De vlieger	\N
48	86	25	(book) (1997) Wie God verlaat heeft niets te vrezen	\N
49	86	25	(book) (1996) Het gebergte	\N
50	86	25	(book) (1996) De nakomer	\N
51	86	25	(book) (1994) Du holde Kunst	\N
52	86	25	(book) (1993) Het woeden der gehele wereld	\N
53	86	25	(book) (1992) Verzamelde verhalen	\N
54	86	25	(book) (1992) Een havik onder Delft	\N
55	86	25	(book) (1991) Onder de korenmaat	\N
56	86	25	(book) (1990) Een dasspeld uit Toela	\N
57	86	25	(book) (1989) De unster	\N
58	86	25	(book) (1988) Feest	\N
59	86	25	(book) (1988) De steile helling	\N
60	86	25	(book) (1987) Het uur tussen hond en wolf	\N
61	86	25	(book) (1986) De nagapers	\N
62	86	25	(book) (1986) De jacobsladder	\N
63	86	25	(book) (1985) De huismeester	\N
64	86	25	(book) (1984) Het roer kan nog zesmaal om	\N
65	86	25	(book) (1984) De ortolaan	\N
66	86	25	(book) (1983) Het eeuwige moment	\N
67	86	25	(book) (1983) De kroongetuige	\N
68	86	25	(book) (1982) De vrouw bestaat niet	\N
69	86	25	(book) (1981) De zaterdagvliegers	\N
70	86	25	(book) (1980) De droomkoningin	\N
71	86	25	(book) (1979) Ongewenste zeereis	\N
72	86	25	(book) (1979) De aansprekers	\N
73	86	25	(book) (1978) Een vlucht regenwulpen	\N
74	86	25	(book) (1978) De stekelbaars	\N
75	86	25	(book) (1978) De som van misverstanden	\N
76	86	25	(book) (1978) A Study of a Short Term Behaviour Cycle	\N
77	86	25	(book) (1977) Mammoet op zondag	\N
78	86	25	(book) (1977) Laatste zomernacht	\N
79	86	25	(book) (1976) De kritische afstand	\N
80	86	25	(book) (1976) Avondwandeling	\N
81	86	25	(book) (1974) Het vrome volk	\N
82	86	25	(book) (1973) Ratten	\N
83	86	25	(book) (1973) Ik had een wapenbroeder	\N
84	86	25	(book) (1971) Stenen voor een ransuil	\N
85	86	21	25 November 1944	\N
86	89	26	Hoen, Franciscus Wilhelmus 't	\N
87	89	20	The Hague, Zuid-Holland, Netherlands	\N
88	89	23	23 October 1967	\N
89	89	39	Hilversum, Noord-Holland, Netherlands	\N
90	89	21	29 August 1920	\N
91	1739596	39	Borgerhout, Flanders, Belgium	\N
92	1739596	20	Borgerhout, Flanders, Belgium	\N
93	1739596	23	1984	\N
94	1739596	21	1895	\N
95	105	25	Album: "Voices Carry" (1985/Epic)	\N
96	105	25	Album: "Welcome Home" (1986/Epic)	\N
97	105	25	Album: "Everything's Different Now" (1988/Epic)	\N
98	105	25	CD compilation: "Coming Up Close: A Retrospective" (1996/Epic)	\N
99	105	19	'Til Tuesday were an excellent and intelligent 1980s New Wave rock quartet from Boston, Massachusetts. The group first got together in 1982. The band members were: Aimee Mann (vocals/bass), Robert Holmes (vocals/guitar), Joey Pesce (keyboards), and Michael Hausman (drums). Their music was distinguished by Mann's beautiful vocals, exceptionally literate lyrics, thoughtful and mature subject matter, and rich, lovely melodies. 'Til Tuesday started out playing around the Boston area and won Boston's WBCN Rock & Roll Rumble battle of the bands contest in 1983. They subsequently signed with the label Epic Records and released their debut album "Voices Carry" in 1985. The haunting and poignant titular tune was a substantial hit single; it peaked at #8 on the Billboard pop radio charts. The album also sold well; it reached #19 on the Top 20 album charts. Moreover, the music video for "Voices Carry" won the MTV Video Music Award for Best New Artist. Alas, the band's follow-up 1986 album "Welcome Home" was less successful; it barely cracked the Top 50 at #49 on the Billboard album charts. The moving song "What About Love" did a little better; it went all the way to #26 on the Billboard pop radio charts. Although their third and final album "Everything's Different Now" received positive notices from music critics in 1988, it nonetheless was a complete commercial flop. 'Til Tuesday broke up in 1988. Aimee Mann has since gone on to have a hugely successful solo career while Michael Hausman serves as Mann's manager.	woodyanders
100	4147863	28	Tivo	\N
101	113	17	(March 2000) Sold 2.4 million copies of their second album, "No Strings Attached", in the first 7 days, setting a new first-week sales record. As of April 2003, that record has yet to be matched.	\N
102	113	17	Released their third album, "Celebrity", in July, 2001.	\N
103	113	17	Band consists of 'Justin Timberlake' (qv), 'J.C. Chasez' (qv), 'Joey Fatone' (qv), 'Lance Bass' (qv), and 'Chris Kirkpatrick (I)' (qv).	\N
104	113	17	Ranked #93 on VH1's 100 Sexiest Artists.	\N
105	157	17	Members have included Don Barnes, 'Donnie Van Zant (I)' (qv), Danny Chauncey, 'Bobby Capps' (qv), L.J. Junstrom, 'Gary Moffat' (qv).	\N
106	157	25	(1984) TV commercial: Schlitz Beer	\N
107	157	25	(2004) Album: "Drivetrain"	\N
108	157	25	(2001) Album: "A Wild-Eyed Christmas Night"	\N
109	157	25	(1999) Album: "Live at Sturgis"	\N
110	157	25	(1997) Album: "Resolution"	\N
111	157	25	(1991) Album: "Bone Against Steel"	\N
112	157	25	(1988) Album: "Rock'n'Roll Strategy"	\N
113	157	25	(1987) Album: "Flashback: Best of .38 Special"	\N
114	157	25	(1986) Album: "Strength in Numbers"	\N
115	157	25	(1983) Album: "Tour De Force"	\N
116	157	25	(1982) Album: "Special Forces"	\N
117	157	25	(1980) Album: "Wild-Eyed Southern Boys"	\N
118	157	25	(1979) Album: "Rockin' Into the Night"	\N
119	157	25	(1977) Album: "Special Delivery"	\N
120	161	35	"Spin" (USA), November 2003, by: David Peisner, "War of The Words - "Showtime and Interscope scour the Battle-Rap underground in search of The Next Big Thing""	\N
121	161	35	"Rolling Stone" (USA), October 2003, "Rap Battles Hit Cable - "A new Hip-Hop version of American Idol""	\N
122	161	19	Todd-1 is ready to take on the new millennium and prove to the entertainment world that his early success was no flash in the pan. From MTV to BET to ABC to Source All Access (Nationally Syndicated) to Interscope Presents the Next Episode (on Showtime), the multi-talented producer has paid his dues and the payoff is set for the year 2004. Born Todd Brown, the Brooklyn native showed early promise during his school years and definitely stood out amongst the crowd. He lists early rap stars KRS-One and LL Cool J as major musical influences and by age 16, he had begun to rap professionally. But although he desired a music career, Todd went off to college.  While studying Cable and Corporate Communications, Todd got his first taste of Television production. He took everything from `Speech' to `Remote TV Production' to `Physics of Music'. One day a fellow student came into class wearing a suit and told him about an internship interview that he was going to. He gave him the phone number and his call led to an internship with a growing company called MTV.  Rising from intern to production assistant to associate producer, Todd knew that he found his niche. He quickly bonded with Ted Demme, who took him on as his apprentice. During this time, the music world was revving its engines and the rise of prominent hip-hop and R&B groups were beginning to take over the charts. The show, MTV's 'Fade to Black' (which would later spawn the hit show 'MTV Jams') achieved strong ratings with Todd himself as the offbeat host, proved to be a real learning experience. Having worked with such premiere artists as Babyface, Janet Jackson, Shaquille O'Neal, TLC and Queen Latifah, it was a short time before he received the call to work at BET. Although he spent less than two years there, BET proved to be another stepping stone for the passionate Todd-1.  After a brief stint setting up the foundation for a Mike Tyson record label, Todd hooked up with friend and NBA star Derrick Coleman to form 44 Ways entertainment. Described it as a `full-service entertainment conglomerate which will catered to Music, Television and Film' Todd-1 had his plate full running the day to day operations. 2 years later, Todd returned to his roots as a Producer of Hip Hop Television shows taking on the post of Supervising Producer at the nationally syndicated show - "Source All Access". It was during the hiatus of this show that he wrote his first screenplay entitled "Money Boys".  Currently Todd is the Producer of "Interscope Presents The Next Episode", airing on Showtime Networks. This is the first of its kind, Hip Hip docu-drama delving into the lives of future rap stars. Todd has relocated to Los Angeles and is looking forward to the upcoming challenges that await.	Todd 1
123	161	22	5' 7 1/2"	\N
124	161	20	Brooklyn, New York City, New York, USA	\N
125	161	33	(November 2003) Showtime Networks / 4Battle Enterprises	\N
126	161	36	"Eurweb.com" (USA), 14 July 2004, pg. 1, by: Michele Roy, "Todd 1 Still Innovating Videos"	\N
127	161	36	"XXL Magazine" (USA), December 2003, Iss. 54, by: Adam Matthews, "Face Off"	\N
128	161	36	"Entertainment Weekly" (USA), December 2003, Vol. 743/744, Iss. 12/26/03 - 1/02/04, pg. 134, by: Ken Tucker, "Television Series Of The Year"	\N
129	161	36	"The New York Times" (USA), 14 November 2003, pg. 28, by: Virginia Heffernan, "Watch out or you might get rhymed in the nose"	\N
130	161	36	"Rolling Stone" (USA), 2 October 2003, by: David Swanson, "Rap Battles Hit Cable"	\N
131	161	26	Brown, Todd A.	\N
132	161	21	24 May 1970	\N
133	175	25	CD: "Mirror Mirror"	\N
134	182	33	(2003) Touring in support of last CD	\N
135	182	26	Jones, Kearney Nick	\N
136	182	17	Is signed to Hellcat Records	\N
137	182	17	Is singer/guitarist of 'Tiger Army'.	\N
138	183	17	Took his stage name "Wednesday 13" from Wednesday Friday Addams from The Addams Family, a show he is a big fan of.	\N
259	1739626	37	"Score" (USA), November 2003, Vol. 12, Iss. 11	\N
139	183	19	Influenced mainly by horror B-movies and campy macabre shows and movies, almost every song he's wrote is connected to some kind of movie some more obvious than others. Wednesday started with music in 1992 in the bands Psycho Opera and Maniac Spider Trash both of which were short lived. He then went on to form The Frankenstein Drag Queens From Planet 13 which lasted a total of 6 years along with a reunion which lasted for 1 year. His big breakthrough came when he formed The Murderdolls with Slipknot's Joey Jordison however the band was short lived with Joey focusing on Slipknot and Wednesday starting a solo career to which he is still active. The Murderdolls released a new album after an 8 year hiatus. Wednesday also plays in side projects such as Bourbon Crow and Gunfire 76. He starred in a straight to DVD short entitled Weirdo a Go-Go which he showed B-movie trailers in the form of a Saturday morning cartoon show with puppets.	A. Shearer
140	183	22	6'	\N
141	192	17	Commander of the 1st Special Service Brigade of the British Army which stormed Sword Beach on D-Day. To rally the troops, he asked 'Bill Millin' (qv) to play the bagpipes as they went ashore. Millin played the bagpipes at Fraser's funeral.	\N
142	192	17	Although commonly known as the 17th Lord Lovat, in fact, he became the 15th Lord Lovat upon the death of his father in 1932, and the 25th Chief of the Clan Fraser.	\N
143	192	17	Played by 'Peter Lawford' (qv) in _The Longest Day (1962)_ (qv).	\N
144	192	17	His wife was the aunt of 'Isabella Blow' (qv), and the daughter of Henry John Delves Broughton, 11th Baronet Broughton, played by 'Joss Ackland' (qv) in _White Mischief (1987)_ (qv).	\N
145	192	28	Shimi	\N
146	192	39	Beauly, Scotland, UK	\N
147	192	20	Inverness, Scotland, UK	\N
148	192	29	Lord Lovat. _March Past._ 1978.	\N
149	192	32	_The Longest Day (1962)_ (qv)	\N
150	192	26	Fraser, Simon Christopher Joseph	\N
151	192	24	'Rosamond Broughton' (10 October 1938 - 16 March 1995) (his death); 6 children	\N
152	192	23	16 March 1995	\N
153	192	21	9 July 1911	\N
154	207	22	6' 2"	\N
155	207	26	Utsler, Joseph William	\N
156	207	20	Detroit, Michigan, USA	\N
157	207	17	Is the second half of the underground rap sensation known to be the I.C.P. (Insane Clown Posse), along with Violent J (Joe Bruce).	\N
158	207	17	Announced on "The Howard Stern Show" that he is engaged to his girlfriend of 7 years. They have 3 children together (September 2003)	\N
159	207	17	Almost died while performing a concert. The cause was low blood sugar and the flu.	\N
160	207	17	(1996) Sons Cyrus and Isaac born.	\N
161	207	17	Is part Native American.	\N
162	207	21	14 October 1974	\N
163	208	25	CD: "Is What We Are"	\N
164	1739613	17	A singing duo consisting of Charley Bird and Lucy Texeira.	\N
165	233	26	Jackson, Marquise Diamond	\N
166	233	20	Los Angeles, California, USA	\N
167	233	17	Son of '50 Cent' (qv)	\N
168	233	25	Appeared in '50 Cent' (qv)'s video "Wanksta"	\N
169	233	21	1997	\N
170	234	22	5' 6"	\N
171	234	20	Baltimore, Maryland, USA	\N
172	234	17	Attended Patterson High in Baltimore, Maryland and University International Academy Of Design And Technology in Tampa, Florida.	\N
173	234	17	Associate Producer of The 'Bubba the Love Sponge' (qv) Show.	\N
174	234	21	27 October 1981	\N
175	237	22	178 cm	\N
176	248	39	Richmond, Virginia, USA (complications from a fall)	\N
177	248	20	Suffolk, Virginia, USA	\N
178	248	26	Karim, Benjamin Goodman	\N
179	248	24	'Linda' (? - 5 August 2005) (his death)	\N
180	248	23	5 August 2005	\N
181	248	21	14 July 1932	\N
182	250	17	Members included 'Brad Arnold (II)' (qv), 'Chris Henderson (IV)' (qv), 'Todd Harrell' (qv), 'Matt Roberts (IV)' (qv).	\N
183	250	17	Rock band.	\N
184	1739620	17	The group members are: 'Adrienne Bailon' (qv), 'Naturi Naughton' (qv) and 'Kiely Williams' (qv).	\N
185	1739620	17	Jessica Benson took Naturi Naughton's place when she left the group.	\N
186	1739620	25	Album: "3LW", 2001.	\N
187	1739620	25	Album: "A Girl Can Mack"	\N
188	1739620	25	Album: "Naughty or Nice"	\N
189	258	23	27 August 2003 (cancer)	\N
190	258	20	Berkel, Zuid-Holland, Netherlands	\N
191	258	19	3 Steps Ahead originally consisted of Peter-Paul Pigmans and Rob Fabrie (DJ Waxweazle), but later Peter-Paul Pigmans started to produce under this name on his own. Pigmans aka 3 Steps Ahead was one of the biggest names in the hardcore techno scene and has made many famous tracks such as "Drop It", "In the Name of Love" and "This is the Thunderdome".  He got brain cancer in the late 90s and on the 18th of July 2003 a big party called "3 Steps Ahead 4 Life" was held where all the profit went to 3 Steps Ahead in hope that he would get better treatment and be cured. Unfortunately he died the same year on the 27th of August. A minute of silence was held for him at that years Thunderdome event.	Jiiimbooh
192	258	25	12" vinyl: "Drop It", Pengo Records 1996	\N
193	258	25	12" vinyl: "Its Delicious", ID&T 1997	\N
194	258	25	Album: "It's Delicious", ID&T	\N
195	258	25	Album: "Most Wanted & Mad", ID&T 1997	\N
196	258	21	31 January 1961	\N
197	259	17	Acrobatic dance act in Vaudeville.	\N
198	266	33	(January 2007) A beautiful lie has been certified platinum by the RIAA for sales over 1 million.	\N
199	266	17	Members have included 'Jared Leto' (qv) (vocals and guitar), 'Tomo Milicevic' (qv) (guitar), 'Matt Wachter' (qv) (bass), and 'Shannon Leto' (qv) (drums).	\N
200	266	17	The band has won numerous awards such as the MTV2 award at the 2006 VMAs, the video most inspired by a film at the 2006 Chainsaw Awards, the Best live Action Video at the Woodie Awards, while lead singer 'Jared Leto' (qv) has won the Prince of Darkness award at the 2006 Chainsaw Awards, and the Best Crossover Artist at the 2006 Breakthrough Awards.	\N
201	266	17	The band's bass player 'Matt Wachter' (qv) decided to spend more time with his family at home and left the band. On March 1st 2007, was his last performance in El Paso, Texas.	\N
260	1739626	37	"Score" (USA), January 1997, Vol. 6, Iss. 1	\N
261	1739626	37	"Score" (USA), May 1996, Vol. 5, Iss. 5	\N
262	1739626	37	"Juggs" (USA), November 1995, Vol. 15, Iss. 1	\N
202	266	17	Their second single, "The Kill" from "A Beautiful Lie", made history by being the longest-running song in history on the modern rock billboard charts for a year. Eventually the song was taken off because of a new rule that a song can last only a year on the charts.	\N
203	266	17	Their third single from " Beautiful Lie" "From Yesterday",also made history by being the first American rock video ever shot in China.	\N
204	266	17	The band became good friends with filmmaker 'John Robert Mariani' (qv), receiving a copy of his independent feature, _Lost Suburbia (2007)_ (qv).	\N
205	266	25	(2002) Album: "30 Seconds to Mars" (Immortal)	\N
206	266	25	(2005) Album: "A Beautiful Lie" (Virgin).	\N
207	266	25	(2009) CD: "This Is War"	\N
208	279	33	(October 2012) The group is longer together. 4 members of the group were briefly signed to J Records as Chapter 4 and released the single 'Fool with You'.	\N
209	279	17	The group changed their name to Chapter 4 before disbanding.	\N
210	1739623	22	5' 1"	\N
211	1739623	35	"Bongs and Thongs" (Canada), 2001, Vol. 1, Iss. 1, pg. 40-45, "Nasty Confessions of the 4:20 Girl of the Month"	\N
212	1739623	20	Montréal, Québec, Canada	\N
213	1739623	38	"Bongs and Thongs" (Canada), 2001, Vol. 1, Iss. 1, pg. 30-39, "Diamond 4 Ever: Inhale or Not to Inhale, That Is the Question!"	\N
214	1739623	21	12 June 1977	\N
215	286	36	"The Washington Post" (USA), 22 July 2008, by: Buzz McClain, "Four Doctors, No Scrubs"	\N
216	286	25	Album: "Second Opinion" (1982/CBS Records)	\N
217	286	25	Album: "4 Out of 5 Doctors" (1980/CBS Records)	\N
218	286	25	Compilation album: "Post Op" (2009/Single Bound)	\N
219	286	25	Compilation album: "Reconstructed" (2008/Single Bound)	\N
220	286	19	4 out of 5 Doctors were a very groovy and talented New Wave power-pop group from Washington, D.C. The band was formed in 1979. The members were: Cal Everett (bass/lead vocals), George Pittaway (guitar/vocals), Jeff Severson (keyboards/guitars/vocals), and Tom Ballew (drums/vocals). 4 Out of 5 Doctors released their self-titled debut album in 1980. The group not only toured with Hall & Oates, Richie Blackmore, and Pat Travers, but also opened for such artists as The Clash, The Cars, Cyndi Lauper, Steppenwolf, and Jim Carroll. They contributed the songs "Not from Her World" and "Baby Go Bye Bye" to the soundtrack of the spooky and offbeat supernatural shocker "The Boogeyman." Moreover, 4 Out of 5 Doctors appear as themselves and perform the songs "Mr. Cool Shoes," "Modern Man," "Waiting for a Change," "Dawn Patrol," and "Waiting for Roxanne" at a party in the superior slasher horror cult favorite "The House on Sorority Row." The group scored 82 in the "Rate-a-Record" segment on Dick Clark's "American Bandstand." The band released their sophomore album "Second Opinion" in 1982. When that album proved to be an undeserved commercial flop, they subsequently broke up in 1984. On July 20, 2008 4 Out of 5 Doctors reunited for a well-received sold-out show at the Jammin' Jive club in Vienna, Virginia. The group also performed at the 2008 Wammie Awards at the State Theatre in Falls Church, Virginia on February 15, 2009. The band released the compilation albums "Reconstructed" in 2008 and "Post Ops" in 2009. 4 out of 5 Doctors issued the CD "Cruel and Unusual" in 2010. The band performed their last concert on July 17, 2010 before breaking up for a second and final time.	woodyanders
221	295	17	His daughter Jasymne is also a rapper and goes by the names "Lil 4Tay" and "Jazzy" - she performed a duet "Me and My Daughter" with him on Gangsta Gumbo and on stage with him during the "StreetLow Magazine" tour.	\N
222	295	25	Soundtrack "Bulletproof" (1996) Name of Song "Where I'm From (Don't Fight The Clean Mix)" credited as writer as Anthony Forte.	\N
223	295	25	Soundtrack "Winner Takes All" (1998) (TV)	\N
224	295	25	Album "Rappin 4Tay is Back" released 1991 on 4Flavaz Emtertainment/Get Low Records	\N
225	295	25	Soundtrack "Dangerous Minds" (1995): Name of Song "Problems" (written as Anthony Forte, performed as Rappin 4Tay), Name of Song "Message for Your Mind" (performed as Rappin 4Tay)	\N
226	295	25	Album "Bigger than the Game" released 1998 on EMI/Ragtop	\N
227	295	25	Album "4 Tha Hard Way" released 1997 on Virgin Records	\N
228	295	25	Album "Off Parole" released 1996 on Capitol Records	\N
229	295	25	Album "Don't Fight The Feeling" released 1994 on Capitol Records	\N
230	295	25	Album "Introduction to Mackin" released 1999 on Celebrity Entertainment	\N
231	295	25	Album "Gangsta Gumbo" released 2003 on Liquid 8 Records	\N
232	295	36	"San Francisco Chronicle" (USA), 11 February 2005, by: Peter Hartlaub, "Rappers Role in Showtime Movie is For Real"	\N
233	295	36	"San Francisco Examiner" (USA), 9 August 1995, by: Sabrina Hall/Lisa Washington, "4Tay Put SF Rap on the Map"	\N
234	295	36	"San Francisco Examiner" (USA), 13 March 1995, by: Craig Marine, "Bammies: Even the big finale jam was a dud"	\N
235	295	26	Forté, Anthony	\N
236	295	24	'Nichole' (? - ?) (divorced); 5 children	\N
237	295	21	2 March 1968	\N
238	300	37	"HIP HOP WEEKLY" (USA), 1 June 2011, Vol. 6, Iss. 12	\N
239	300	37	"HIP HOP WEEKLY" (USA), 2008, Vol. 3, Iss. 17	\N
240	300	19	Cali rapper 40 Glocc is living the dream. He is signed to a deal with lifetime friends Mobb Deep - with whom he is about to embark on a national tour - on Infamous/G-Unit Records. He's recording his first album under that deal with some of the top producers in the business (Dr Dre, Alchemist, Havoc) and is traveling to places in the world he once only dreamed of seeing. It would seem that he has everything right now that an aspiring artist could ever want, and that is certainly true; but it certainly wasn't always that way. This is definitely no overnight success story.  Born as Tory Gasaway in Galveston, Texas, 40 Glocc didn't know his mother until the age of 8. Instead, he was raised by his grandparents in Beaumont, along with 14 other children. His father was never around much either. During those eight years, 40 only knew his mother, and a younger sister he had never met, by the pictures his grandparents showed him. He only knew that they lived in California and that one day, his mother was coming to get him. His grandmother told him so.  She did in fact come to get him and moved him to the MacArthur Park area of Downtown Los Angeles. 40 was so glad to see her and his sister, and he just knew that life was going to get better now that his family was reunited. After a time the family relocated to Colton City, San Bernadino, to an area also known as "The Zoo" and the problems at home began. 40 and his mother didn't get along at all. He didn't feel that she cared at all about what happened to him. His new friends did though and 40 started spending all of his time with them. His friends, unfortunately, were all members of the Colton City Crips. The deeper 40 got into that lifestyle, and its ensuing traps, the worse things became at home. Finally, at the age of 13, 40 left home for good, choosing instead to sleep in the cars of friends, or outside of grocery stores with the bums. It was a life he became adept at dealing with. His role models and father figures, such as they were, were gang bangers and drug dealers and 40 learned to survive through them and live by their street code, reaping all the rewards such a life inevitably has in store. Among other things, 40 was shot several times, ending up in a wheelchair for many months after one such incident during which he was shot by police. He finally caught a case from a home invasion charge he didn't commit. A charge it took him six months to beat.  Through all of this though, 40 did have a dream. He also had a talent, that of rapping, and of telling vivid stories of the things he had been through and of his life on the streets. Narratives that people could relate to. People like him. Word didn't take long to reach the right ears; the streets are like that. By '97 group The Zoo Crew (40 Glocc, K-9 and Natural Born) had formed and were dropping their first album "Migrate, Adapt or Die" produced by Tony and Julio G. The album became an underground hit and 40 was recognized as one of the best hidden talents in the streets. Soon he was an integral part of the scene and recording with his West Coast peers. It was his manager and long-time friend Storm though that negotiated his first solo deal with Empire Music Werks who were distributed by BMG. It was through this deal that 40 Glocc released his first solo effort, "The Jackal" which featured a who's who list of West Coast talent - Ras Kass, Bad Azz, Kurupt, Spice 1 and Tray Dee - and production from the best Cali had to offer; long-time supporter Dr Dre, Battle Cat and Protégé. Empire didn't have their promotion game up to snuff though and after sinking much of what he had been advanced back into promoting the album himself, 40 decided to go his own way.  At this time, manager Storm's other act, Mobb Deep had been making a lot of noise since their debut "Infamous" on Jive and it was only natural that they would take an interest in the career of their friend. First instincts said get 40 a deal at Jive but conversations went nowhere and Storm began to shop 40 Glocc at the other majors. Unfortunately, the West Coast had lost their hold on the rap game and no one wanted to take a chance that a West Coast artist could sell. It was a set-back, as was Jive's dropping of Mobb Deep but as life often so does, things took a sudden turn for the great. Mobb Deep was signed to G-Unit and suddenly they and their friend 40 Glocc were running around with rap's finest. This was a home 40 could live with and it wasn't long before that became a reality; he signed to Mobb Deep's imprint Infamous under G-Unit. Some things have remained the same however. 40 is still recording with Dr Dre and he is still writing stories that people his can relate to. That is his goal. To give hope with his lyrics to people who are coming up through some of what he has already lived to tell. To let them know that they too can achieve their dream. To believe in themselves when there is no one else to believe in you.  40 Glocc is pursuing acting as well. He recently wrapped a supporting role in a feature film entitled "Playboys" from directors Zach Cregger and Trevor Moore ("The Whitest Kids U Know"). He's also featured in a new AFI (American Film Institute) short film called "The Second Half". Being a part of a prestigious AFI Film was a great experience for him. 40 Glocc has also appeared in other feature films such as "Thicker Than Blood", "Book Of Love" and Snoop Dogg's "Tha Eastsidaz".  With what he has already accomplished, what are some of 40 Glocc's other dreams? To make an album that touches peoples' souls. He feels that what he is recording now is his best work ever. He knows he can't rap forever though. He also hopes to make his label Zoo Life something he can grow old with. After all, right now, just the thought that he has made it to a point in his life where he probably will live to grow old is a major blessing.	Keith Louis Brown
241	300	29	PRODIGY MOBB DEEP. _My Infamous Life._ New York, NY: Laura Checkoway, 2011. ISBN 978-1-4391-4933-1	\N
242	300	25	Ras Kass "Back It Up" music video	\N
243	300	25	Mobb Deep "Got It Twisted" music video	\N
244	300	25	Kurupt "It's Over" music video	\N
245	300	25	50 Cent "Window Shopper" music video	\N
246	300	25	Lloyd Banks "Hands Up" music video	\N
247	300	25	Mobb Deep "Give It To Me" music video	\N
248	300	25	Ky-Mani Marley "One Time" music video	\N
249	300	25	Warren G "Game Don't Wait" music video	\N
250	300	25	Mobb Deep "Have A Party" music video	\N
251	300	25	G-Unit "Rider Pt. 2" music video	\N
252	300	36	"HIP HOP WEEKLY" (USA), 1 June 2011, pg. 3, "FIST FLY IN L.A"	\N
253	300	17	A member of 50 Cent's G-Unit.	\N
254	303	17	The 411 are Carolyn, Suzie, Tanya and Tisha.	\N
255	303	17	Disbanded in early 2005.	\N
256	303	17	Had three top 40 hits and one album - "On My Knees" (#4), "Dumb" (#3), and "Teardrops" (#23). Their album was called "Between the Sheets".	\N
257	303	17	Were dropped by their record company when Song and BMG merged in 2004.	\N
258	1739626	37	"Score" (USA), June 2004, Vol. 13, Iss. 6	\N
263	1739626	37	"Fling International" (USA), Winter 1995, Vol. 37-4, Iss. 184	\N
264	1739626	37	"Hustler Busty Beauties" (USA), June 1994, Vol. 6, Iss. 9	\N
265	1739626	37	"Bust Out!" (USA), November 1993, Vol. 8, Iss. 6	\N
266	1739626	35	"Score" (USA), June 2004, Vol. 13, Iss. 6, pg. 42+45-46+49-50+68+70-71, by: Bruce Arthur, "Colt 45: Tit-Chat with the Star of 'Busty Dildo Lovers #4'"	\N
267	1739626	35	"Bust Out!" (USA), September 1995, Vol. 10, Iss. 6, pg. 58, "Misty Mountains: (aka Colt 45) 65HHH-23-37"	\N
268	1739626	35	"Bust Out!" (USA), November 1993, Vol. 8, Iss. 6, pg. 45-48, "Colt 45: 65HHH-23-37"	\N
269	1739626	22	5' 7"	\N
270	1739626	20	Corpus Christi, Texas, USA	\N
271	1739626	38	"Score" (USA), June 2004, Vol. 13, Iss. 6, pg. 42-50, "Colt 45: Tit-Chat with the Star of 'Busty Dildo Lovers #4'"	\N
272	1739626	38	"Score" (USA), November 2003, Vol. 12, Iss. 11, pg. 42-49, "Colt 45: Sheer Ecstasy--A Legend, a See-Through Blouse & a Dildo. That's Nice."	\N
273	1739626	38	"Score" (USA), March 2003, Vol. 12, Iss. 3, pg. 81-87, "Colt Rides Again: Still at the head of the big-boob pack."	\N
274	1739626	38	"Buxotica (Score Special)" (USA), 2003, Iss. 80, pg. 11-15, "Colt 45: 52-26-36"	\N
275	1739626	38	"Score" (USA), January 2002, Vol. 11, Iss. 1, pg. 81-87, "Colt 45: Ridin' the Plastic Pony! Colt takes the road to Scoreland with both big guns blazing."	\N
276	1739626	38	"Score" (USA), April 2001, Vol. 10, Iss. 4, pg. 80-81, "Score Sweet Sixteen: Colt 45"	\N
277	1739626	38	"Buxotica (Score Special)" (USA), 2001, Iss. 59, pg. 82-85, "Colt 45: 52-26-36"	\N
278	1739626	38	"Score" (USA), April 2000, Vol. 9, Iss. 4, pg. 21-27, "Colt 45: Some of the Biggest 'Guns' in the World!"	\N
279	1739626	38	"Score" (USA), December 1999, Vol. 8, Iss. 12, pg. 12-17, "Score Big Boob Matchup"	\N
280	1739626	38	"Busty Beauties" (USA), December 1998, pg. 53-60, by: Steve Berlyn, "Colt .45: The Size of Texas Is Upon You"	\N
281	1739626	38	"Score" (USA), April 1998, Vol. 7, Iss. 4, pg. 11-15, "Caught in the Act: Colt 45"	\N
282	1739626	38	"Score" (USA), October 1997, Vol. 6, Iss. 10, pg. 44-51, "Misty Mountains"	\N
283	1739626	38	"Gent" (USA), October 1997, Vol. 38, Iss. 10, pg. 18-25, by: JLG Marketing, Ltd., "Randy Ravage & Colt 45"	\N
284	1739626	38	"Gent's Bra Busters" (USA), April 1997, Vol. 38, Iss. 4, pg. 10-17, by: JLG Marketing, Ltd., "Colt 45"	\N
285	1739626	38	"Score" (USA), January 1997, Vol. 6, Iss. 1, pg. 24-31, "Colt .45: Ho! Ho! Ho! Santa couldn't make it this year. Any complaints?"	\N
286	1739626	38	"Score" (USA), May 1996, Vol. 5, Iss. 5, pg. 56-63, "Colt 45 & Deena Duos: News Flash: One of These Superstars Is Retiring! Read On for All the Details!"	\N
287	1739626	38	"Juggs" (USA), November 1995, Vol. 15, Iss. 1, pg. 8-15, "Misty Mountains: Cock and Load"	\N
288	1739626	38	"Bust Out!" (USA), September 1995, Vol. 10, Iss. 6, pg. 57-63, "Misty Mountains: (aka Colt 45) 65HHH-23-37"	\N
289	1739626	38	"Gent" (USA), March 1995, Vol. 36, Iss. 3, pg. 58-63, by: JLG Marketing, Ltd., "Colt 45"	\N
290	1739626	38	"Fling International" (USA), Winter 1995, Vol. 37-4, Iss. 184, pg. 8-13, "X-Rated Xmas: A Fling Foto Fantasy"	\N
291	1739626	38	"Best of Hustler Busty Beauties" (USA), 1995, Vol. 6, pg. 61-65, by: Parker Haldane, "Four Across"	\N
292	1739626	38	"Gent" (USA), December 1994, Vol. 35, Iss. 12, pg. 18-23, by: Falcon Foto, "Candy & Lynden: An X-Rated X-Mas"	\N
293	1739626	38	"Gent" (USA), July 1994, Vol. 35, Iss. 7, pg. 34-39, by: JLG Marketing, Ltd., "Lisa Lipps and Colt 45"	\N
294	1739626	38	"Hustler Busty Beauties" (USA), June 1994, Vol. 6, Iss. 9, pg. 45-53, by: Parker Haldane, "Colt .45: Savory Boob-Slinger"	\N
295	1739626	38	"Score" (USA), February 1994, Vol. 3, Iss. 1, pg. 89-97, "Peaches & Cream: Colt 45"	\N
296	1739626	38	"Gent's Centerfold Special" (USA), 1994, Iss. 49, pg. 42-49, "On the Boardwalk"	\N
297	1739626	38	"Bust Out!" (USA), November 1993, Vol. 8, Iss. 6, pg. 44-51, "Colt 45: 65HHH-23-37"	\N
298	1739626	38	"Gent" (USA), October 1993, Vol. 34, Iss. 10, pg. 42-49, by: JLG Marketing, Ltd., "On the Boardwalk: Known on the North American exotic dance circuit as Colt 45, this sexy, mammothly endowed filly is now taking her act into the 'Home of the D-Cups.'"	\N
299	1739626	17	As an exotic dancer, she was sometimes billed as Misty Mountains because some club owners found that many patrons thought the name "Colt 45" on the marquee referred to the malt liquor rather than the featured dancer.	\N
300	1739626	21	18 July 1963	\N
301	4147864	22	4' 2"	\N
302	333	33	(2012) Portlandia	\N
303	333	26	Martini-Connally, John	\N
304	333	20	Los Angeles, California, USA	\N
305	333	17	Has worked & studied alongside studio engineer giants like 'Kelley Baker (I)' (qv), 'Wayne Woods (I)' (qv), 'Paul Nelson (VIII)' (qv), 'John Neff' (qv), 'Russ Gorsline' (qv), 'Colin O'Neill (I)' (qv), 'Matt Meyer (II)' (qv), Brent Rogers, Randy Johnson, and 'Will Vinton' (qv).	\N
306	333	17	Bachelors in Digital Media Production from the Art Institute of Portland.	\N
307	333	17	Nephew of writer/director 'Richard Martini (I)' (qv).	\N
308	333	17	Related to former Texas Governor & U.S. Secretary of the Treasury 'John Connally (I)' (qv).	\N
309	333	21	7 September 1984	\N
310	339	37	"Big Fish" (Greece), 4 June 2006, Iss. 28	\N
311	339	37	"Hitkrant" (Netherlands), 19 March 2005, Iss. 11	\N
312	339	37	"The Source" (USA), October 2003, Iss. 169	\N
313	339	37	"Breakout!" (Netherlands), 7 August 2003, Iss. 33	\N
314	339	37	"Dub" (USA), 2003, Iss. 15	\N
315	339	25	Single: "In Da Club" (2003)	\N
316	339	25	Single: "P.I.M.P." (2003)	\N
317	339	25	Music video for 'Lloyd Banks' (qv): "On Fire"	\N
318	339	25	Music video for 'Lloyd Banks' (qv): "I'm So Fly" (also co-director).	\N
319	339	25	Music video for 'Young Buck' (qv): "Shorty Wanna Ride"	\N
320	339	25	Music video for 'Lloyd Banks' (qv): "Karma"	\N
321	339	25	Music video for 'Young Buck' (qv): "Let Me In"	\N
322	339	25	Music video for 'Eminem' (qv): "Like Toy Soldiers"	\N
323	339	25	Music video for 'Game' (qv): "How We Do"	\N
324	339	25	Album: "Get Rich or Die Tryin'," Shady/Aftermath/Interscope/Universal Records 493 544, 2003.	\N
325	339	25	Music video for 'Eminem' (qv): "Sing for the Moment"	\N
326	339	25	Album: "The Massacre," Shady/Aftermath/Interscope/Universal Records 210 388, 2005.	\N
327	339	25	Single: "Candy Shop" (March 2005)	\N
328	339	25	Single: "Disco Inferno" (2005)	\N
329	339	25	Single: "How We Do" (2005)	\N
330	339	25	Album: "Power of the Dollar" (1999) (unreleased)	\N
331	339	25	Album: "Guess Who's Back?" (2002)	\N
332	339	25	2005: TV commercial for Reebok.	\N
333	339	25	Album: "Just a Lil Bit", 2005.	\N
334	339	25	Single: "Just a Lil Bit" (May-June 2005)	\N
335	339	25	2005: Directed music video for Olivia feat. 'Lloyd Banks' (qv), "Twist It".	\N
336	339	25	2005: Public service announcement for The ONE Campaign [www.one.org]	\N
337	339	25	Music video for 'Game' (qv): "Hate It Or Love It"	\N
338	339	25	Music video for 'Tony Yayo' (qv): "So Seductive"	\N
339	339	25	Music video for 'Young Buck' (qv): "Look At Me Now/Bonafide Hustler"	\N
340	339	25	Music video for Olivia: "Twist It"	\N
341	339	25	Appears in 'Tony Yayo' (qv)'s video "Curious" (2005)	\N
342	339	25	2006: Print ad for Glacéau vitamin water.	\N
343	339	25	Music video for 'Ciara (I)' (qv): "Can't Leave 'Em Alone"	\N
344	339	25	Album: "Curtis," Shady/Aftermath/Interscope/Universal Records 173 340, 2007.	\N
345	339	25	TV commercial for Vitamin Water	\N
346	339	25	Music video for Eminem: "We Made You"	\N
347	339	25	Music video for Wisin & Yandel: "Mujeres In The Club"	\N
348	339	25	(2011) Music video for Jeremih: "Down On Me"	\N
349	339	25	(2011) Music video for Nicole Scherzinger: "Right There"	\N
350	339	28	Interscope	\N
351	339	28	Fiddy	\N
352	339	28	Boo Boo	\N
353	339	35	"Parade" (USA), 27 June 2010, pg. 2, by: Walter Scott, "Walter Scott asks...50 Cent"	\N
354	339	35	"Süddeutsche Zeitung" (Germany), 30 June 2007, by: Jonathan Fischer, "50 Cent über Verantwortung"	\N
355	339	35	"Big Fish" (Greece), 4 June 2006, Iss. 28, pg. 44-47, by: Lynley Dwight, "Otan enas andras einai gnostos ginetai issaxios me mia goiteftiki gineka"	\N
356	339	35	"Stuff" (USA), November 2005, Vol. 8, Iss. 11, pg. 118-119, by: Sean Fennessey, "50 Cent Sees the Light"	\N
357	339	35	"Maxim" (USA), November 2005, Vol. 9, Iss. 11, pg. 81, "50's Sense: He's got a new movie, a video game, and a whole mess of other stuff, but 50 Cent still can't bring Dave Chappelle back."	\N
358	339	35	"FHM" (USA), August 2005, Iss. 59, pg. 54, "'Q&A': 50 Cent"	\N
359	339	35	"Blender" (USA), April 2005, Vol. 4, Iss. 3, pg. 66-69, by: Weiner, Jonah, ""Dear Superstar""	\N
360	339	35	"Playboy" (USA), April 2004, Vol. 51, Iss. 4, pg. 61-65+139-142, by: Rob Tannenbaum, "The Playboy Interview: 50 Cent"	\N
361	339	35	"Playboy" (USA), August 2003, Vol. 50, Iss. 8, pg. 30, by: Dewey Hammond, "Phoning It In: 50 Cent"	\N
362	339	35	"Blender" (US / UK), June 2003, Iss. 17, pg. 102, by: Jonah Weiner, "How will 50 Cent, the planet's hottest rapper, spend his summer?"	\N
363	339	19	Born in the South Jamaica section of Queens, Curtis "50 Cent" Jackson has lived in New York City all his life. Raised by his grandparents after his father ran out and his mother was shot when he was only eight. Growing up, the Queens rapper originally wanted to be a heavyweight boxer, but eventually fell back on rapping. DJs had taken it upon themselves to release two Best of 50 Cent mix CDs, before he had even signed to a major label. 50 Cent hit the scene with "How To Rob" and he's been on a rampage ever since dealing with bootleggers, label back stabbing and other platinum selling artists trying to get at him physically. In 1999 his album Power of the Dollar, was heavily bootlegged and Trackmasters/Columbia never released it. Supposedly, Trackmasters weren't comfortable with him being caught up in the streets and getting shot three days before filming the video for "Thug Love," (with Destiny's Child) -- his first single. 50 was shot three times that night, two shots hitting him in the head, the bullet that struck his face he carries as a reminder of what happened. That event led to the fall out with Columbia and negotiating his release from their grasps. He still showed love and rhymed over a Trackmasters produced remix of "I'm Gonna Be Alright" on J-Lo's latest album, but rivals at Murder Inc. had 50 cut from the track which could have launched the rapper. This all changed in one night when Eminem said on a radio show that "50 Cent is definitely my favorite rapper right now, he's the only one keeping it real." The very next day a bidding war started on 50, ending when 50 signed to Eminem's very own label Shady/Aftermath. 50 Cent's fame has exploded, being produced by Dr. Dre and Eminem and finally making his debut album "Get rich or Die Tryin'." 50 has full access and advantage of the streets through mix-tapes; that's his forum because he controls it. 50 Cent is the most anticipated artist of 2003. It's well deserved because he's "been patiently waiting."	Rod Reece
364	339	22	6'	\N
365	339	15	The only thing that I'm scared of is not livin' up to the expectations of 'Dr. Dre' (qv) and 'Eminem' (qv).	\N
366	339	15	[on his feud with rapper 'Ja Rule' (qv)] Right now he's desperate. He should be talking about me, not 'Eminem' (qv) and ['Dr. Dre' (qv)] and everybody else. He'll lose, he knows that. The route that he has to take is the "I'm a mad gangsta" hardcore route, and ain't nobody gonna believe him.	\N
367	339	15	In Hollywood they say there's no business like show business. In the hood they say there's no business like ho' business.	\N
368	339	15	I'm not trying to save the world. As a musician and artist, it just ain't me.	\N
369	339	15	A man becomes as attractive as an attractive woman when he becomes successful and is publicly noted. Power's an aphrodisiac.	\N
370	339	15	I think it's easier for the general public to embrace me in a negative way. You have people who already have a perception of me that says I'm a bad person.	\N
371	339	15	I don't display emotions. I have every feeling that everyone else has but I've developed ways to suppress them. Anger is one of my most comfortable feelings.	\N
372	339	15	In my neighborhood if you're too aggressive, you intimidate someone, they kill you. Or if you decide to be emotional and you start crying, you're a victim. You know, the kid in the schoolyard that doesn't want to fight always leaves with a black eye. You have to find a way to stay in the middle, somewhere where people just don't mess with you because they know that you don't have a problem with it if it goes there.	\N
373	339	15	[on his feuds with many of his fellow rappers, such as 'Nas' (qv), 'Jadakiss' (qv), 'Fat Joe' (qv), 'Shyne' (qv), 'Game' (qv), 'Ja Rule' (qv), 'Sheek Louch' (qv) and 'Styles P.' (qv), among others] If they keep comin' at me, I'll just keep responding back until they don't exist anymore. I got the time and energy to ruin what is left of their careers, if they want to do that.	\N
374	339	15	A lot of kids join the army to get a college education. That's why they do it, and they get sent into these horrible situations.	\N
375	339	15	I got a chance to watch a lot of my mother's sisters and brothers at different periods experiment with the use of drugs or alcohol and I see them respond so differently that I stay away...I've had an experience (with alcohol) that made me paranoid because of it and I stayed away from it following that.	\N
376	339	20	Queens, New York City, New York, USA	\N
377	339	29	Mary Boone. _50 Cent._ Hockessin, DE: Mitchell Lane Publishers, 2006. ISBN 158415523X	\N
378	339	29	Hal Marcovitz. _50 Cent._ Broomall, PA: Mason Crest Publishers, 2007. ISBN 1422202623	\N
379	339	29	50 Cent and Noah Callahan-Bever. _50 X 50: 50 Cent in His Own Words._ New York: Pocket Books, 2007. ISBN 1416544712	\N
380	339	29	50 Cent. _From Pieces to Weight._	\N
381	339	38	"Metro" (Netherlands), 4 May 2012	\N
382	339	38	"Spits" (Netherlands), 9 December 2009, by: Brunopress, "50 cent wil duet met Susan Boyle"	\N
383	339	38	"TVFilm" (Netherlands), 5 December 2009, Vol. 25, by: Righteous Kill/Moonlight, "Als je voor 50 cent geboren bent..."	\N
384	339	33	(June 2003) Currently touring everywhere possible with artists like Busta Rhymes, Snoop Dogg, Jay-Z, Sean Paul, Chingy, and Bone Crusher on the Roc Tha Mic Tour.	\N
385	339	36	"Spits" (Netherlands), 9 December 2009, "50 cent wil duet met Susan Boyle"	\N
386	339	36	"TVFilm" (Netherlands), 5 December 2009, Vol. 25, "Als je voor 50 cent geboren bent..."	\N
502	1739643	22	5' 2"	\N
503	1739643	20	England, UK	\N
387	339	36	"The Orlando Sentinel" (USA), 9 November 2008, by: Choire Sicha, "50 Cent: The New King of All Media"	\N
388	339	36	"Contra Costa Times" (USA), 24 October 2008, by: The Associated Press, "Rapper 50 Cent Settles NY Visitation Issue"	\N
389	339	36	"The New York Times" (USA), 3 July 2008, Vol. 157, Iss. 54,360, pg. E1 & E5, by: Jon Caramanica, "A Hungry 50 Cent, Working Hard for the Money"	\N
390	339	36	"The New York Times" (USA), 31 May 2008, Vol. 157, Iss. 54,327, pg. B4, by: Associated Press, "Arson Suspected at House Owned by Rapper"	\N
391	339	36	"Courier Post" (USA), 30 May 2008, by: Frank Eltman, "Rapper 50 Cent's Home Destroyed by Fire"	\N
392	339	36	"Contra Costa Times" (USA), 30 May 2008, by: Frank Eltman, "Home at Center of 50 Cent Lawsuit Destroyed by Fire"	\N
393	339	36	"The New York Times" (USA), 6 May 2008, Vol. 157, Iss. 54,302, pg. E2, by: Lawrence Van Gelder, "50 Cent Show Disrupted in Angola"	\N
394	339	36	"Entertainment Weekly" (USA), 11 November 2005, Vol. 1, Iss. 849, pg. 34-35, by: Drumming, Neil, ""50 + Change""	\N
395	339	36	"The Atlanta Journal-Constitution" (USA), 2 August 2005, Vol. 57, Iss. 214, pg. E1+E6, by: Nick Marino, "Volume mutes menace of hard-core hip-hop"	\N
396	339	36	"GQ" (USA), June 2003, Vol. 73, Iss. 6, pg. 148+150, by: Jon Caramanica, "Can I get a thug?"	\N
397	339	36	"Entertainment Weekly" (USA), 23 February 2003, Vol. 1, Iss. 698, pg. 43-46+47, by: Evan Serpick, "The 50 Cent Piece"	\N
398	339	26	III, Curtis James Jackson	\N
399	339	17	Is involved in a feud with fellow rapper 'Ja Rule' (qv).	\N
400	339	17	Is signed to 'Eminem' (qv)'s Shady Records imprint, distributed by Interscope Records.	\N
401	339	17	Has a son, Marquise, nicknamed '25 Cent (I)' (qv).	\N
402	339	17	His debut album "Get Rich or Die Tryin'" was the highest debut ever with 900,000 copies sold in the first week.	\N
403	339	17	His mother was killed at age 23, when he was just eight years old.	\N
404	339	17	Was discovered by 'Jason Mizell' (qv) aka Jam Master Jay.	\N
405	339	17	Voted #8 on VH1's 100 Hottest Hotties	\N
406	339	17	Used to be a boxer	\N
407	339	17	Neither drinks alcohol nor smokes.	\N
408	339	17	He bought former heavyweight boxing champion 'Mike Tyson (I)' (qv)'s Farmington, CT, mansion for $4.1 million. The house is approximately 50,000 sq. ft., has 52 rooms and was bought by Tyson for $2.7 million in 1996. Its features include five Jacuzzis, 25 full baths, 18 bedrooms, an elevator, two billiard rooms, a movie theater and a locker room.	\N
409	339	17	Recorded an album in 1999 titled "Power of the Dollar" but it was shelved by Columbia Records due to his legal problems at the time.	\N
410	339	17	Released a series of street mixtapes in 2002. They became so popular that 'Eminem' (qv) heard them and signed him to his record label. Even after his success, 50 still releases street mixtapes on a regular basis.	\N
411	339	17	Album "The Massacre" was originally titled "St. Valentine's Day Massacre" and set for a February 15 release date, but production problems forced it to be set back to March 8.	\N
412	339	17	Was accompanied by actress 'Vivica A. Fox' (qv) to the MTV Video Music Awards 2003	\N
413	339	17	Created a dance known as the "two step".	\N
414	339	17	His favorite actor is 'Charlie Sheen' (qv).	\N
415	339	17	His cartoon-like photo on the cover of his album "The Massacre" was meant to make him look like a Ninja Turtle, his son's favorite cartoon characters. He is also a fan of the cartoon, his favorite turtle being Donatello.	\N
416	339	17	His group, 'G-Unit' (qv), includes 'Tony Yayo' (qv), and 'Lloyd Banks' (qv). 'Young Buck' (qv) and 'Game' (qv) were once members but a well-publicized feud developed.	\N
417	339	17	Raised in Queens, NY, by his grandparents.	\N
418	339	17	Named among Fade In Magazine's "100 People in Hollywood You Need to Know" in 2005.	\N
419	339	17	Was #8 on the annual Forbes magazine Celebrity 100 list in 2006	\N
420	339	17	Founder of G-Unit Records, G-Unit Films, G-Unit Books, G-Unit Clothing and G-Unity Foundation.	\N
421	339	17	In 2007, Forbes Magazine estimated his earnings for the year at $33 million.	\N
422	339	17	Jackson was hurt in a car crash on New York's Long Island Expressway on the night of June 25, 2012. A Mack truck rear-ended the bullet-proof SUV that he was traveling in and almost caused his vehicle to flip over, reported the New York Post. Jackson suffered neck and back injuries, but was released from the hospital within hours. His unidentified driver was also hospitalized.	\N
423	339	21	6 July 1975	\N
424	340	32	_Notorious (2009)_ (qv)	\N
425	345	17	They are a Canadian alternative rock group, formed in 1981, consisting of 'Neil Osborne (I)' (qv) (vocals), 'Brad Merritt' (qv), 'Darryl Neudorf' (qv) and 'Dave Genn' (qv).	\N
426	345	17	Wrongly attributed to the 1844 campaign of William Polk, the origin of the name 54-40, from which the band got their name, has been attributed to William Allen, a Governor of Ohio.	\N
427	345	25	Album "Yes to Everything" (2005)	\N
428	345	25	Greatest hits album "Radio Love Songs: The Singles Collection" (2002)	\N
429	345	25	Album "Goodbye Flatland" (2003)	\N
430	345	25	Album "Casual Viewin'" (2000)	\N
431	345	25	Compilation album "Casual Viewin' USA" (2001)	\N
432	345	25	Album "Heavy Mellow" (1999)	\N
433	345	25	Compilation album "Sound of Truth: The Independent Collection" (1996)	\N
434	345	25	Album "Since When" (1998)	\N
435	345	25	Album "Trusted by Millions" (1996)	\N
436	345	25	Album "Smilin' Buddha Cabaret" (1994)	\N
437	345	25	Album "Show Me" (1987)	\N
438	345	25	Album "Fight for Love" (1989)	\N
439	345	25	Compilation album "Sweeter Things: A Compilation" (1991)	\N
440	345	25	Album "Dear Dear" (1992)	\N
441	345	25	Album "Set the Fire" (1984)	\N
442	345	25	Album "54-40" (1986)	\N
443	345	25	Album "Selection" (1982)	\N
444	348	36	"Playboy" (USA), May 1968, Vol. 15, Iss. 5, pg. 160-161, by: staff, "On The Scene: up, up and away"	\N
445	348	17	Members have included 'Marilyn McCoo' (qv), 'Billy Davis Jr.' (qv), 'Ron Townson' (qv), 'Florence LaRue' (qv), 'LaMonte McLemore' (qv), 'Tanya Boyd' (qv).	\N
629	3228439	25	(March 2011) Music video for Claudine Muno & the Luna Boots "Monsters" - cinematographer	\N
630	3228439	25	(2009) Music video for Uzi & Ari "Wolfeggs" - cinematographer	\N
446	348	17	When they first formed in 1965 they called themselves The Versatiles. Their producer, 'Johnny Rivers' (qv), suggested they come up with a newer-sounding name. That night they sat around trying to think up a new name, and member 'Ron Townson' (qv) came up with The Fifth Dimension.	\N
447	348	17	The group was awarded a Star on the Hollywood Walk of Fame for Recording at 7000 Hollywood Boulevard in Hollywood, CA.	\N
448	348	25	TV commercial: Tropicana fruit juice, the song "Aquarius" being used.	\N
449	348	25	TV commercial: KFC, their song "California Soul" being used	\N
450	348	25	CD: "The Definitive Collection" (Arista) (2-disc set)	\N
451	348	25	CD: "Ultimate Fifth Dimension" (RCA)	\N
452	348	25	Album: "Up, Up and Away" (Columbia)	\N
453	348	25	CD: "Greatest Hits"	\N
454	349	24	'Almina Wombwell' (26 June 1895 - 5 April 1923) (his death); 2 children	\N
455	349	39	Cairo, Egypt (effects of a mosquito bite)	\N
456	349	20	London, England, UK	\N
457	349	17	Discovered the tomb of Tutankhamun, aka "King Tut".	\N
458	349	17	Father of 'Henry George Alfred Marius Victor Francis Herbert 6th Earl of Carnarvon' (qv). Grandfather of 'Henry George Reginald Molyneux Herbert 7th Earl of Carnarvon' (qv). Great-grandfather of 'George Reginald Oliver Molyneux Herbert 8th Earl of Carnarvon' (qv).	\N
459	349	23	5 April 1923	\N
460	349	21	26 June 1866	\N
461	356	36	"Télépro" (Belgium), 25 August 2005, Iss. 2686, pg. TV3, "Buck 65 aux Eurocks"	\N
462	356	26	Terfry, Richard	\N
463	356	22	6'	\N
464	362	26	Vuori, Jussi Heikki Tapio	\N
465	362	21	11 July 1972	\N
466	362	20	Helsinki, Finland	\N
467	362	28	Messy Boy	\N
468	363	26	Linnankivi, Jyrki Pekka Emil	\N
469	366	24	'Ottilie Losch' (1 September 1939 - 1947) (divorced)	\N
470	366	24	'Anne Wendell' (17 July 1922 - 1936) (divorced); 2 children	\N
471	366	39	UK	\N
472	366	20	London, England, UK	\N
473	366	17	Son of 'George Edward Stanhope Molyneux Herbert 5th Earl of Carnarvon' (qv). Father of 'Henry George Reginald Molyneux Herbert 7th Earl of Carnarvon' (qv). Grandfather of 'George Reginald Oliver Molyneux Herbert 8th Earl of Carnarvon' (qv).	\N
474	366	23	22 September 1987	\N
475	366	21	7 November 1898	\N
476	374	24	'Jean Wallop' (7 January 1956 - 11 September 2001) (his death); 3 children	\N
477	374	39	Winchester, Hampshire, England, UK	\N
478	374	20	Lancaster Gate, London, England, UK	\N
479	374	17	Racing Manager to 'Queen Elizabeth II' (qv).	\N
480	374	17	Father of 'George Reginald Oliver Molyneux Herbert 8th Earl of Carnarvon' (qv). Son of 'Henry George Alfred Marius Victor Francis Herbert 6th Earl of Carnarvon' (qv). Grandson of 'George Edward Stanhope Molyneux Herbert 5th Earl of Carnarvon' (qv).	\N
481	374	23	11 September 2001	\N
482	374	21	19 January 1924	\N
483	387	20	London, England, UK	\N
484	387	17	Son of 'Henry George Reginald Molyneux Herbert 7th Earl of Carnarvon' (qv). Grandson of 'Henry George Alfred Marius Victor Francis Herbert 6th Earl of Carnarvon' (qv). Great-grandson of 'George Edward Stanhope Molyneux Herbert 5th Earl of Carnarvon' (qv).	\N
485	387	17	Godson of 'Queen Elizabeth II' (qv).	\N
486	387	24	'Fiona Aitken' (18 February 1998 - present); 1 child	\N
487	387	24	'Jayne Wilby' (16 December 1989 - January 1998) (divorced); 2 children	\N
488	387	21	10 November 1956	\N
489	393	17	Group members are 'Nick Lachey' (qv), 'Drew Lachey' (qv), 'Justin Jeffre' (qv), 'Jeff Timmons' (qv).	\N
490	402	17	The band's big hit song "Boogie Oogie Oogie" was inspired by an especially tough and unresponsive audience that the group was performing live for at an American military base. 'Hazel Payne' (qv) yelled to the hostile crowd, "If you think you're too cool to boogie, we've got news for you! Everyone here tonight is going to boogie, and you're no exception to the rule!". 'Janice Marie Johnson' (qv) subsequently wrote what Payne shouted down as the opening lyrics for the song while Perry Kibble came up with a funky bass line to accompany said lyrics.	\N
491	402	17	The band took their unusual name from the song "A Taste of Honey", which was a hit for 'Herb Alpert & The Tijuana Brass' (qv) in 1965.	\N
492	402	19	A Taste of Honey was a funk/disco/R&B band from Los Angeles, California. The group first formed in 1971. The line-up was: 'Janice Marie Johnson' (qv) (guitar/bass/vocals), 'Hazel Payne' (qv) (guitar/vocals), Perry Kibble (keyboards) and Donald Ray Johnson (drums). A Taste of Honey started out playing at various clubs in Southern California and at American military bases in both the United States and abroad (the band did USO tours in such places as Spain, Alaska, Thailand, Morocco and Japan). The group were discovered by Capitol Records in 1976 and signed up with the label two years later. They scored a massive smash in 1978 with the infectiously funky disco song "Boogie Oogie Oogie", which peaked at #1 on the Billboard pop charts for three consecutive weeks, sold over two million copies, and earned the group a Grammy Award for Best New Artist on February 15, 1979. The follow-up song, "Do It Good", was a #13 hit on the R&B radio charts. By 1980, the band had become a duo consisting of only 'Janice Marie Johnson' (qv) and 'Hazel Payne' (qv). In 1981, A Taste of Honey had another huge success with their cover of the lovely Japanese ballad "Sukiyaki", which soared to #1 on the R&B radio charts and climbed all the way to #3 on the Billboard pop charts. The band broke up in the early 80s. 'Janice Marie Johnson' (qv) went on to pursue a solo career, 'Hazel Payne' (qv) became an international stage actress, Donald Ray Johnson has recorded several blues albums and continues to play the drums (he's also a well-known blues singer/drummer in Western Canada), and Perry Kibble sadly died of heart failure at the tragically young age of 49 in 1999. In 2004, Janice Marie Johnson and Hazel Payne reunited to perform on the PBS TV specials _Get Down Tonight: The Disco Explosion (2004) (TV)_ (qv) and _My Music: Funky Soul Superstars (2005) (TV)_ (qv).	woodyanders
493	402	25	Album: "Ladies of the Eighties" (1982)	\N
494	402	25	Album: "Twice As Sweet" (1980)	\N
495	402	25	Album: "Another Taste" (1979)	\N
496	402	25	Album: "A Taste of Honey" (1978)	\N
497	2701156	25	(1998) Album: "The Love Movement"	\N
498	2701156	25	(1996) Album: "Beats Rhymes And Life"	\N
499	2701156	25	(1993) Album: "Midnight Marauders"	\N
500	2701156	25	(1991) Album: "The Low End Theory"	\N
501	2701156	25	(1990) Album: "People's Instinctive Travels And The Paths Of Rhythm"	\N
504	1739643	19	A rising star, Basia is fast establishing herself as a most talented, versatile, and charming young performer with a unique maturity and understanding, years in excess of her age. She has been studying acting at the prestigious Keane Kids Studios for the past 3 years, where management recognized her potential and immediately signed her.  With a burgeoning career that spans Film, Television, and Stage, her singing and dancing skills add yet another dimension to Basia's unique talent in her rise to stardom.	Anonymous
505	1739643	25	"Fiddler on the Roof" as Village Child (Hills Centre Performing Arts).	\N
506	1739643	25	"La Dispute" as Dina (Benedict Andrews (STC).	\N
507	1739643	25	"Les Miserables" 10th Anniversary Season as Young Cosette.	\N
508	1739643	25	(Royal Theatre).	\N
509	1739643	25	Photography for CBA Pamphlets.	\N
510	1739643	21	7 December 1989	\N
511	1739648	26	Adam, Isabelle	\N
512	1739648	20	Gent, Belgium	\N
513	1739648	34	Strong Ghent accent	\N
514	1739648	17	Has been romantically linked with Belgian singers 'Willy Sommers' (qv) and 'Raf Van Brussel' (qv).	\N
515	1739648	21	25 May 1975	\N
516	421	28	"The U2 of Norway"	\N
517	421	19	Norwegian pop group formed in 1985 comprised of: 'Morten Harket' (qv), lead singer and song writer; 'Magne Furuholmen' (qv) (("Mags"), keyboards, piano, vocals and song writer, and Paul Waaktaar-Savoy ('Pål Waaktaar' (qv)), guitars, vocals and song writer.  Achieved a major breakthrough in 1985 with the hit "Take On Me." Has since then had following hits with "The Sun Always Shines On TV," "Hunting High and Low," "Manhattan Skyline," "I've Been Losing You," "The Living Daylights," "Stay on These Roads," "Crying in the Rain," "Summer Moved On," "Forever Not Yours," and recently "Analogue - All I Want" to name a few.  Has sold over 70 millions records worldwide.  Made the theme song for the 1987 James Bond movie _The Living Daylights (1987)_ (qv).  Made a comeback in the year 2000 after a seven year split with the album "Minor Earth Major Sky."  Released the first fully web-based animated flash music video to be made available (with the song "I Wish I Cared"). 'Madonna' (qv) was a close second.  In August of 2005 they attracted the largest number of people (120,000) ever to attend a concert in Norway.	Peter Rosengren
518	421	29	Jan Omdahl. _The Swing of Things - the book about a-ha._ Oslo: Forlaget Press, 2004. ISBN 82-7547-120-6	\N
519	421	25	a-ha has released the following albums: Hunting High and Low (1985) Scoundrel Days (1986) Stay on These Roads (1988) East of the Sun, West of the Moon (1990) Headlines and Deadlines - Greatest Hits (1991) Memorial Beach (1993) Minor Earth Major Sky (2000) Lifelines (2002) How Can I Sleep With Your Voice in my Head - a-ha Live (2003) The Singles 1984-2004 (2004) Analogue (2005)	\N
520	421	33	(August 2006) Will tour Russia and Norway shortly, before beginning on their next studio album. Release date probably sometime in 2007.	\N
521	421	17	In 1991, A-Ha set a Guinness Book World Record by playing for the largest paying audience in the world: 198,000 people at the Maracana stadium in Rio de Janeiro, Brazil.	\N
522	421	17	An A-Ha poster can be seen on the wall during the _"Seinfeld" (1990)_ (qv) episode "The Pez Dispenser," which was aired in 1992.	\N
523	421	17	In 2005, the video for "Take On Me" was parodied in an episode of a _"Family Guy" (1999)_ (qv) cartoon where Chris is pulled into the pencil sketched world of the video with A-Ha singer, 'Morten Harket' (qv). The scene contains re-drawn footage copied from the "Take On Me" video, but with Chris instead of "The Girl".	\N
524	421	17	In 1999, songwriter Paul Waaktaar-Savoy ('Pål Waaktaar' (qv)) received an award: A-Ha had been played 2,000,000 times on US radio-stations since 1985.	\N
525	421	17	A-Ha has performed at two Nobel Peace Prize concerts, the most prestigious award show in the world. A-Ha performed in 1998 and 2001. ('Morten Harket' (qv) has also performed solo twice.) The 1998 performance was A-Ha's comeback into the world of music.	\N
526	421	17	Songs by A-Ha have been included as background music in episodes of popular TV series, such as _"Baywatch" (1989)_ (qv), _"Melrose Place" (1992)_ (qv), _"South Park" (1997)_ (qv), _"Smallville" (2001)_ (qv), and _"The Simpsons" (1989)_ (qv), as well as movies such as _One Night at McCool's (2001)_ (qv), _Grosse Pointe Blank (1997)_ (qv), _Corky Romano (2001)_ (qv), and Beavis and Butthead.	\N
527	421	17	In 1994, A-Ha performed the official song for the Winter Paralympics of 1994 at Lillehammer in Norway. The name of the song was "Shapes That Go Together".	\N
528	421	17	A-Ha sales (with albums, singles and EP's) is around 70 million copies.	\N
529	421	17	Fans of A-Ha includes: 'Coldplay' (qv), 'Sarah Brightman' (qv), 'Graham Nash (I)' (qv), 'Pet Shop Boys' (qv), 'Keane' (qv), 'Adam Clayton (I)' (qv), 'Robbie Williams (I)' (qv), 'Claudia Schiffer' (qv), and 'Leonard Cohen (I)' (qv).	\N
530	421	17	The very first version of "Take On Me" was called "The Juicyfruit Song" and was recorded during a rehearsal in 1981 by Bridges, Paul Waaktaar-Savoy ('Pål Waaktaar' (qv)) and 'Magne Furuholmen' (qv)'s former band.	\N
531	421	17	A-Ha is responsible for the "ripped jeans" fashion trend of 1985. Lead singer 'Morten Harket' (qv) was the originator of this trend due to a slight mishap, he mistakenly tore the front of his jeans on a Marshall amplifier while rushing to the stage during a performance. Afterwards, he remarked "Ouch!I just didn't see those". In future performances he used razor blades to achieve the same effect.	\N
532	421	17	On the 30th of October 2006 in London, A-Ha received the prestigious Q Inspiration Award for their long contribution to music and for inspiring many of their younger colleagues in the business.	\N
533	424	35	"Ignore Magazine" (USA), 30 June 2006, by: Sven Barth, "Sunglasses at Breakfast is a Must: A Charlie Rose-like Interview with A-Trak"	\N
534	424	20	Montreal, Quebec, Canada	\N
535	424	38	"ignore Magazine" (USA), 30 June 2006, by: Avi Rothman, "Sunglasses at Breakfast is a Must: A Charlie Rose-like Interview with A-Trak"	\N
536	424	36	"ignore Magazine" (USA), 30 June 2006, by: Sven Barth, "Sunglasses at Breakfast is a Must: A Charlie Rose-like Interview with A-Trak"	\N
537	424	26	Macklovitch, Alain	\N
538	424	17	Younger brother of David "Dave 1" Macklovitch - 1/2 of the Electro-funk duo Chromeo under Vice Records.	\N
539	424	21	30 March 1982	\N
540	1739649	26	Casares, Marilia Andrés	\N
541	1739649	20	Cuenca, Cuenca, Castilla-La Mancha, Spain	\N
542	1739649	17	Her group with 'Marta Botía' (qv) (named Ella Baila Sola) released 3 albums: "Ella Baila Sola" (1996); "E.B.S" (1998) and "Marta y Marilia" (2000).	\N
543	1739649	21	17 December 1974	\N
544	431	26	Flores, Luis Antonio	\N
631	3228439	25	(2009) music video for Artaban "Fjord Mustang" - cinematographer	\N
545	431	19	Born in Temple, TX, raised in Mexico City, Luis A. Flores has the best of both worlds: the American Way of Life with the vibrant Latin Culture.  Composer, Arranger, Producer, lives in NYC.  Latin influenced by principle, but with many influences worldwide, Luis has accomplished several projects for theater and film, and now is working on Wrion Bowling and Adam Craig's Indie film: Shelter, soon to be released by early Fall.	Luis A. Flores
546	2701161	26	Solla, Ricardo Álvarez	\N
547	2701161	20	Valladolid, Valladolid, Castilla y León, Spain	\N
548	2701161	21	1971	\N
549	447	26	Ané, Dominique	\N
550	447	21	6 October 1968	\N
551	448	17	Frequent guest on 'Howard Stern (I)' (qv)'s radio show.	\N
552	448	17	Is a huge fan of 'Beth Ostrosky' (qv).	\N
553	448	17	Former wrestler.	\N
554	448	28	Awesome Angelo	\N
555	454	39	London, England, UK	\N
556	454	22	168 cm	\N
557	454	20	UK	\N
558	454	26	Adelman, Joe	\N
559	454	17	He originally started out in fashion for many years then Switched to porn in 1999 and started making Indian content sites.	\N
560	454	17	Was of Jewish faith.	\N
561	454	23	27 October 2006	\N
562	454	21	13 October 1948	\N
563	1739669	20	Czech Republic	\N
564	1739669	21	30 August 1985	\N
565	3063824	20	Switzerland	\N
566	3063824	21	1961	\N
567	498	39	Paris, France (lung cancer)	\N
568	498	20	Tours, France	\N
569	498	26	Fournier, Alain	\N
570	498	17	Became famous in the seventies as a crime novelist. Known for his humorous, goliardic style and his far right political views. He also worked as a journalist for several french far right newspapers. Lived in New Caledonia in the 1980s.	\N
571	498	23	2 November 2004	\N
572	498	21	19 December 1947	\N
573	502	26	Graham, Allan	\N
574	502	22	5' 7 1/2"	\N
575	502	25	Album (with Showbiz), "Goodfellas," PayDay/FFRR/PolyGram Records 124 007, 1995.	\N
576	502	25	Album (with Showbiz), "Runaway Slave," PayDay/London/PolyGram Records 828 334, 1992.	\N
577	502	28	Aldo	\N
578	502	28	Big Al	\N
579	502	28	Bing-Bing	\N
580	505	24	'Dr. Lao Sealey' (23 April 2005 - present)	\N
581	505	34	Wears long, braided dreadlocks	\N
582	505	22	6' 3"	\N
583	505	20	New Jersey, USA	\N
584	505	26	Calloway, Albert Johnson	\N
585	505	17	Grew up with 'Mariah Carey' (qv).	\N
586	505	17	Went to Howard University.	\N
587	505	21	29 August 1974	\N
588	520	24	'Krishnaveni Jikki' (qv) (? - present)	\N
589	4147865	21	1934	\N
590	4061930	33	(July 2010) Recently married and expecting a child, Aa will be taking a hiatus from the band Savage Genius.	\N
591	4061930	20	Japan	\N
592	4061930	21	17 April 1978	\N
593	538	20	Norway	\N
594	538	21	21 July 1960	\N
595	543	39	Norway	\N
596	543	20	Norway	\N
597	543	23	29 December 1948	\N
598	543	21	1911	\N
599	544	39	Oslo, Norway	\N
600	544	19	Popular Norwegian comedian of the silent period, in Norwegian and Swedish films. He made his stage debut in 1897 at the Christiania Theater in Oslo, and was a prominent and busy actor in the Norwegian theatre. In 1917, he began appearing in silent films in Sweden, then returned to Norway in 1927, where he worked in many films, including several after the advent of sound. He made his last film in 1938, at the age of 71. His son 'Per Aabel (I)' (qv) was also a popular comic actor in Norwegian films.	Jim Beaver <jumblejim@prodigy.net>
601	544	20	Forde, Norway	\N
602	544	17	Father of 'Per Aabel (I)' (qv).	\N
603	544	23	12 December 1961	\N
604	544	21	21 April 1869	\N
605	545	39	Oslo, Norway	\N
606	545	19	Norwegian actor, son of 'Hauk Aabel (I)' (qv). Growing up in the world of theatre and films, 'Per Aabel (I)' (qv) was groomed for a life in the arts. He studied ballet in London and attended the Academy of Fine Arts in Paris. He followed this with training with the great theatre director 'Max Reinhardt (I)' (qv) in Vienna. His stage debut was in 1931 and he spent a number of years as a principal actor and teacher with major theatre companies in Oslo. He did not appear in films for nearly a decade after that, and his cinematic output was not large. He prospered in the Norwegian theatre and became one of its most respected comic actors.	Jim Beaver <jumblejim@prodigy.net>
607	545	20	Kristiania, Norway. [now Oslo, Norway]	\N
608	545	29	Jan E.Hansen. _Kjære Per Aabel._ Oslo: J.W.Cappelens Forlag a.s, 1993. ISBN 82-02-13805-1	\N
609	545	29	Per Aabel. _Den stundesløse Per Aabel._ Oslo: Gyldendal Norsk Forlag, 1980. ISBN 82-05-12409-4	\N
610	545	29	Per Aabel. _Du verden._ Oslo: Prent Forlag, 1950.	\N
611	545	25	(1954) He acted in 'Robert De Flers', 'Gaston Arman de Cavaillet' (qv), and 'Etienne Rey' (qv)'s play, "Accounting for Love", at the Saville Theatre in London, England with 'Leslie Phillips (I)' (qv) and 'Mary Clare' (qv) in the cast.	\N
612	545	26	Aabel, Per Pavels	\N
613	545	17	Son of 'Hauk Aabel (I)' (qv).	\N
614	545	17	As a young child his family were neighbours and friends with the legendary playwright 'Henrik Ibsen' (qv). Aabel himself was only four when Ibsen died but has a clear memory of himself riding on his lap as a child.	\N
615	545	17	Second oldest male actor in Norway so far, he was 97 years and eight months old when he died in Desember 1999.	\N
616	545	23	22 December 1999	\N
617	545	21	25 April 1902	\N
618	550	26	Åberg, Linus Per Ulrik	\N
619	550	20	Sweden	\N
620	550	21	7 December 1977	\N
621	3316915	20	Havre, Montana, USA	\N
622	3316915	21	8 April 1949	\N
623	1739681	17	A Norwegian singer.	\N
624	1739681	17	Became famous after participating in Norwegian Idol.	\N
625	1739681	17	Two of her songs have been certified gold in Norway - 'Bliss' and 'I Know'.	\N
626	1739681	22	171 cm	\N
627	2701181	20	Hellerup, Denmark	\N
628	2701181	21	7 July 1935	\N
632	562	19	Born in 1976 to Scandinavian parents, Erik grew up in the San Francisco Bay Area. He graduated 1 of 330 in high school, garnering the Valedictory, and was accepted to Yale and Stanford Universities. He took a full Trustee scholarship to USC's Cinema-Television School as a film production major where he went on to supervise the Spielberg Scoring Stage. He graduated Summa Cum Laude in 1998, and became the Editor Guild's youngest new member, working on _Forces of Nature (1999)_ (qv), _Tuesdays with Morrie (1999) (TV)_ (qv), _The Last Producer (2000)_ (qv), _They Nest (2000) (TV)_ (qv) and _"Law & Order" (1990)_ (qv). He was also a sound effects editor on the Sci-Fi Channel's _"Dune" (2000)_ (qv) miniseries.	Alexis Kasperavicius <lex@via.net>
633	562	21	1976	\N
634	1739690	17	She had a highly publicized relationship with 'Errol Flynn (I)' (qv) for the last two years of his life. (She was 17 when he died).	\N
635	1739690	17	Daughter of 'Florence Aadland' (qv).	\N
636	1739690	17	She had a daughter, Aadlanda Joy Fisher, in 1980.	\N
637	1739690	17	At age 7, was featured in an industrial film entitled The Story of Nylon (1949), billed as Beverly Adlund.	\N
638	1739690	28	Woodsey	\N
639	1739690	28	Little Wood Nymph	\N
640	1739690	28	SC	\N
641	1739690	39	Lancaster, California, USA (congestive heart failure)	\N
642	1739690	20	Hollywood, California, USA	\N
643	1739690	29	Florence Aadland. _The Beautiful Pervert._ 1965.	\N
644	1739690	38	"Celebrity Sleuth" (USA), 1990, Vol. 3, Iss. 6, pg. 84-85, by: staff, "Growing Pains"	\N
645	1739690	33	(March 2009) Appeared on "Hollywood Charmers", BBC Radio 2 series on "four charming leading men", talking about Errol Flynn.	\N
646	1739690	36	"Los Angeles Times" (USA), 10 January 2010, by: Rong-Gong Lin II, "Beverly E. Fisher dies at 67; Errol Flynn's final girlfriend"	\N
647	1739690	26	Aadland, Beverly Elaine	\N
648	1739690	24	'Maurice Jose de Leon' (24 June 1961 - 11 June 1964) (divorced)	\N
649	1739690	24	'Joseph E. McDonald' (6 April 1967 - January 1969) (divorced)	\N
650	1739690	24	'Ronald Fisher' (1970 - 5 January 2010) (her death); 1 child	\N
651	1739690	23	5 January 2010	\N
652	1739690	21	16 September 1942	\N
653	1739692	17	Has two daughters: Barbara Simpson (from her first marriage) & 'Beverly Aadland' (qv) (from her marriage to Herbert Aadland).	\N
654	1739692	39	Los Angeles, California, USA (cirrhosis of the liver and hepatitis)	\N
655	1739692	20	Van Zandt County, Texas, USA	\N
656	1739692	29	Florence Aadland. _The Big Love._	\N
657	1739692	25	"The Beautiful Pervert" (1965) by Florence Aadland as told to Lisa Janssen (another book that retells the story of her daughter's affair).	\N
658	1739692	25	"The Big Love" (1961) by Mrs. Florence Aadland as told to Tedd Thomey (a book that chronicles her teenage daughter's 2-year affair with actor 'Errol Flynn (I)' (qv)).	\N
659	1739692	26	Simpson, Florence Elaine	\N
660	1739692	24	'William Benegal Rau' (qv) (31 October 1960 - ?)	\N
661	1739692	24	'Herbert Aadland' (? - ?) (divorced); 1 child	\N
662	1739692	24	'?' (? - ?) (divorced); 1 child	\N
663	1739692	23	10 May 1965	\N
664	1739692	21	21 September 1909	\N
665	572	20	Kunda, Estonia	\N
666	572	17	Graduated Estonian Academy of Music's Higher Theatre School in 2002. Since then, has worked as an actor in Tallinn City Theatre.	\N
667	572	17	Graduated Estonian Academy of Music's Higher Theatre School alongside with actresses 'Hele Kõre' (qv), 'Kadri Lepp' (qv), 'Laura Nõlvak' (qv), 'Karin Lätsim' (qv), 'Evelin Pang' (qv), 'Maria Soomets' (qv), 'Elisabet Tamm' (qv), 'Carita Vaikjärv' (qv), and actors 'Ott Aardam' (qv), 'Karol Kuntsel' (qv), 'Alo Kõrve' (qv), 'Anti Reinthal' (qv), 'Mart Toome' (qv), and 'Priit Võigemast' (qv).	\N
668	572	21	12 April 1980	\N
669	3410702	20	Copenhagen, Denmark	\N
670	3410702	21	10 August 1942	\N
671	4036924	23	19 March 1966	\N
672	4036924	39	Charlottenlund, Denmark	\N
673	4036924	20	Nordby, Denmark	\N
674	4036924	19	Danish set designer and art director, prominent in Scandinavian theatre and in films both European and American. He attended the Danish Naval Academy, then attended art school while simultaneously working as an assistant for Nordisk Films and for the Folketeatret of Copenhagen. He worked as an assistant to the director 'Svend Gade' (qv) on _Hamlet (1921)_ (qv) in Berlin, and while there studied painting at the Kunstgewerbe Museum. He worked during the early Twenties in the Berlin theatre, then accepted work in Paris designing sets for avant garde films for directors such as 'Alberto Cavalcanti' (qv) and 'Jean Renoir' (qv). Aaes returned to Denmark in 1933 and worked simultaneously in films and theatre, both in Europe and abroad, thereafter.	Jim Beaver <jumblejim@prodigy.net>
675	4036924	21	27 April 1899	\N
676	581	26	Aafjes, Lambertus Jacobus Johannes	\N
677	581	20	Amsterdam, Noord-Holland, Netherlands	\N
678	581	23	22 April 1993	\N
679	581	39	Swolgen, Netherlands	\N
680	581	21	12 May 1914	\N
681	582	17	Killed on the east front during WWII. _Unge viljer (1943)_ (qv) was his first and only screen performance.	\N
682	582	23	1944 (casualty of war)	\N
683	587	23	19 August 1984	\N
684	588	20	Rungsted, Denmark	\N
685	588	23	22 April 1921	\N
686	588	21	21 August 1850	\N
687	2701185	21	22 October 1924	\N
688	597	36	"Se og Hør" (Denmark), 11 December 2003, Vol. 64, by: Anne Bennike, "Jesus kan det hele"	\N
689	597	36	"Vild med dyr" (Denmark), December 2003, Iss. 6, pg. 7, by: Helene Kemp, "Jeg elsker dyr"	\N
690	597	26	Aagaard-Williams, Sebastian Henry	\N
691	597	21	11 August 1988	\N
692	597	20	Gentofte, Denmark	\N
693	597	28	Viggo	\N
694	621	26	Aaker, Dee Forrest	\N
695	621	20	Inglewood, California, USA	\N
696	621	17	Brother of 'Lee Aaker' (qv).	\N
697	621	21	17 July 1941	\N
698	624	37	"TV Guide" (USA), 2 July 1955	\N
740	1739742	26	Aalbers, Harriet	\N
741	1739742	17	Sister of Aileene, Fern and Lorraine Aalbu.	\N
742	1739742	23	18 January 1975	\N
743	1739742	21	12 June 1913	\N
744	1739743	39	Los Angeles, California, USA	\N
745	1739743	20	Minneapolis, Minnesota, USA	\N
746	1739743	26	Aalbers, Vera Louraine	\N
699	624	19	As Rusty, the boy whose parents were killed by Indians and who was subsequently adopted by a cavalry unit at Fort Apache on the popular adventure _"The Adventures of Rin Tin Tin" (1954)_ (qv), tyke actor Lee Aaker left a lasting mark in the early days of television, but he had in fact appeared in several major films prior to this series.  He was born on September 25, 1943, in Los Angeles, where his mother owned a dance studio. On TV almost from infancy, he started appearing in unbilled film bits at the age of eight in such classics as _The Greatest Show on Earth (1952)_ (qv) and _High Noon (1952)_ (qv). He quickly moved to featured status before year's end. He showed promise as the kidnapped Indian "Red Chief" in a segment of the film _Full House (1952)_ (qv) and another kidnap victim as the son of scientist 'Gene Barry' (qv) in _Atomic City (1952)_. From there he co-starred in the 'John Wayne (I)' (qv) western classic _Hondo (1953)_ (qv) as the inquisitive blond son of homesteader 'Geraldine Page' (qv), and appeared to good advantage in other movies such as the film noir thriller _Jeopardy (1953)_ (qv) with 'Barbara Stanwyck' (qv), the hoss opera drama _Arena (1953)_ (qv) with 'Gig Young' (qv) and the comedies _Mister Scoutmaster (1953)_ (qv) with 'Clifton Webb' (qv) and _Ricochet Romance (1954)_ (qv) with 'Marjorie Main' (qv).  Stardom, however, was assured after nabbing the role of the famous dog's young master on the "Rin Tin Tin" series. After the show's demise, however, Aaker did not survive the transition into adult roles. He instead moved into the production end of the business, serving as an assistant to producer 'Herbert B. Leonard' (qv) on the _"Route 66" (1960)_ (qv) series, then later dropped out altogether to become a carpenter. He still attends nostalgia conventions and was recently a "Kids of the West" honoree at the 2005 Golden Boot Awards.	Gary Brumburgh / gr-home@pacbell.net
700	624	17	Was tested for the top boy role in the classic movie _Shane (1953)_ (qv) and promised the part, but lost it a few days later to the late 'Brandon De Wilde' (qv).	\N
701	624	17	Brother of 'Dee Aaker' (qv).	\N
702	624	17	Interviewed in "Growing Up on the Set: Interviews with 39 Former Child Actors of Classic Film and Television" by Tom Goldrup and Jim Goldrup (McFarland, 2002).	\N
703	624	15	Suddenly after the [_"The Adventures of Rin Tin Tin" (1954)_ (qv)] series was canceled and I began doing guest shots, I realized that something had changed -- I wasn't the center of attention any more. My folks had always told me that my career might not last, but when it happened, it was still a hard thing for me to adjust to.	\N
704	624	20	Inglewood, California, USA	\N
705	624	26	Aaker, Lee William	\N
706	624	24	'Sharon Ann Hamilton' (22 September 1969 - March 1971) (divorced)	\N
707	624	21	25 September 1943	\N
708	3316922	25	Produced the music video "Pure to me" by Samsaya	\N
709	3316922	25	Produced the music video "Kjære lille deg" by Rolf Aakervik	\N
710	626	20	Copenhagen, Denmark	\N
711	626	21	12 September 1958	\N
712	1739725	17	She plays spanish guitar, electric guitar and piano at her solo-shows.	\N
713	1739725	19	Annika Aakjær is a Danish singer/songwriter/actress. She's mainly known for her career as a singer - and for her fantastic stage-performance - which is a mix of her songs and stand-up comedy between the songs. She studied at Aalborghus Gymnasium, but dropped out to - as she says - study life instead.  She released her first album "Lille filantrop" ("Little philanthropist") in 2008, and her second album "Missinær" ("Missionary") in 2010 on Playground Records. Both produced by Henrik Marstal. Both albums were very well received by Danish reviewers. Five and six stars pretty much all over, but none of the albums gave her a massive radio-hit. "Tyk" ("Fat") from the first album gave her enough attention to fill the small concert-halls, and the title-track from "Missionær" was a regular on the national Danish radio a few months after release. A third album will be released in 2012.  In 2009 she won the acclaimed award "Steppeulven" as best, upcoming act.  Annika was cast for the world's first theatre-musical "Come Together", entirely based on The Beatles songs. Also here she gained great success, and were referred to as a "main attraction" in the show in a TV review. Her acting-career includes various small parts, until landing the role as Daimi in the 2011 film about the Danish comedian and actor Dirch Passer.	Jacob Nielsen
714	3063831	39	Jenle, Denmark	\N
715	3063831	20	Aakjær, Denmark	\N
716	3063831	23	22 April 1930	\N
717	3063831	21	10 September 1866	\N
718	636	21	15 April 1968	\N
719	3564372	21	25 September 1970	\N
720	4147866	39	Los Angeles County, California, USA	\N
721	4147866	19	John Aalberg was best friends with Ed Kappel in Chicago. They were both in the Projectionist Union, the rules back then only allowed brothers or sons to join, (William Leonard) was the brother of May (Leonard) Kappel, the wife of Ed, Bill changed his name to Kappel in order to get in the Union. Ed Kappel was offered a sound job in Los Angeles, which he turned down because he did not think he had the education to handle it. Since Aalberg was a graduate of Armour Tech in Chicago, Ed let Aalberg take the job. Because of this and his friendship with Ed and the difficult times in Chicago, Aaalberg hired Ed Leonard at Universal, then Ed asked Aalberg to hire Willie (Kappel) Leonard as things became bad in Chicago after the head of the union, Tommy Malloy was murdered, and that's how the, Leonard's, Henderson's and Murray's became successful in the industry. Bill Leonard worked at 20th Century as a Projectionist in 1939, when his daughter, Sheila Leonard married Robert Henderson, he got him in the Union and became a Sound Editor with two Academy Award nominations, when Bob Henderson's, daughter, Lynnell Henderson married Alan Murray, he got Alan a job as a Sound Editor who not only has been nominated 4 times for an Academy Award, he won for the Sound in Clint Eastwood's "Letters from Iwo Jima" Alan and Bob began working with Clint on the Movie "Escape From Alcatraz" Now all three of Lynnell and Alan's children work at Warner Bros.	Anonymous
722	4147866	22	6' 0"	\N
723	4147866	20	Chicago, Illinois, USA	\N
724	4147866	23	30 August 1984	\N
725	4147866	21	3 April 1897	\N
726	1739739	17	Real life sister to 'Lorraine Aalbu' (qv), 'Fern Aalbu' (qv), and 'Harriet Aalbu' (qv).	\N
727	1739739	39	Hennepin County, Minnesota, USA	\N
728	1739739	20	Minneapolis, Minnesota, USA	\N
729	1739739	26	Aalbu, Evelyn Aileene	\N
730	1739739	24	'Ernie Fliegel' (? - ?); 1 child	\N
731	1739739	23	25 June 1966	\N
732	1739739	21	5 February 1909	\N
733	1739741	26	Aalbu, Anna Ferne	\N
734	1739741	20	Minneapolis, Minnesota, USA	\N
735	1739741	23	24 April 1984	\N
736	1739741	39	Valley Village, Los Angeles, California, USA	\N
737	1739741	21	6 January 1912	\N
738	1739742	39	Minneapolis, Minnesota, USA	\N
739	1739742	20	Minneapolis, Minnesota, USA	\N
747	1739743	17	Sister of Aileene, Fern and Harriet Aalbu.	\N
748	1739743	23	20 January 1991	\N
749	1739743	21	31 March 1905	\N
750	648	17	Brother of Zentropa co-owner and executive producer 'Peter Aalbæk Jensen' (qv).	\N
751	1739753	37	"Celebrity Skin" (USA), October 2002, Vol. 24, Iss. 109	\N
752	1739753	37	"Hitkrant" (Netherlands), 6 April 2002, Iss. 14	\N
753	1739753	37	"Vibe" (USA), August 2001	\N
754	1739753	37	"Mixmag" (UK), August 2001, Iss. 123	\N
755	1739753	37	"Black Men" (USA), December 2000, Vol. 4, Iss. 6	\N
756	1739753	37	"Hitkrant" (Netherlands), 24 June 2000, Iss. 25	\N
757	1739753	25	Music video for 'Tim Mosley (I)' (qv): "Here We Come"	\N
758	1739753	25	Most famous for mega hit songs "Back and Forth," "One in a Million","Try Again," "More than a woman," and "Are You that Somebody."	\N
759	1739753	25	Noted for her well-choreographed music videos.	\N
760	1739753	25	Model for 'Tommy Hilfiger' (qv).	\N
761	1739753	25	Album, "Age Ain't Nothing But a Number," Blackground/Jive/BMG Records 01241-41533, 1994.	\N
762	1739753	25	Album, "One in a Million," Blackground/Atlantic Records 92715, 1996.	\N
763	1739753	25	Album, "Aaliyah," Blackground/Virgin/EMI Records V2-10082, 2001.	\N
764	1739753	25	Album, "I Care 4 U," Blackground/Universal Records 060 097, 2002.	\N
765	1739753	25	Music video, "Try Again" (2000).	\N
766	1739753	25	Music video for The Notorious B.I.G.: "One More Chance"	\N
767	1739753	25	Originally casted as "Zee" in the two Matrix sequels. Aaliyah had filmed many of her scenes but had not completed them all due to her sudden death. The role was re-casted and re-shot with Nona Gaye in the role of Zee.	\N
768	1739753	25	Attended the 2000 Indus music awards in Karachi, Pakistan.	\N
769	1739753	25	Most famous for her role in Queen of the damned (2002)	\N
770	1739753	31	_Losing Aaliyah (2001) (V)_ (qv)	\N
771	1739753	31	_"E! True Hollywood Story" (1996) {Aaliyah}_ (qv)	\N
772	1739753	31	_BET Tonight Special: Aaliyah (2001) (TV)_ (qv)	\N
773	1739753	28	Liyah	\N
774	1739753	28	BabyGirl	\N
775	1739753	28	Wonder Woman	\N
776	1739753	28	Lee	\N
777	1739753	28	Li Li	\N
778	1739753	28	Queen of R&B	\N
779	1739753	39	Marsh Harbour, Abaco Island, Bahamas (airplane crash)	\N
780	1739753	29	Kelly Kenyatta. _Aaliyah: An R&B Princess in Words and Pictures._ New York: Amber Communications Group, Inc., 2002. ISBN 0970222432	\N
781	1739753	29	Christopher John Farley. _Aaliyah : More Than a Woman._ New York: MTV, 2001. ISBN 0743451406	\N
782	1739753	29	Tim Footman. _AALIYAH._ New York: Plexus Publishing, 2003. ISBN 0859653277	\N
783	1739753	29	William Sutherland. _Aaliyah Remembered._ New York: Trafford Publishing, 2006. ISBN 1412050626	\N
784	1739753	19	Talented. Beautiful. Modest. These three words described R&B singer-turned-actress Aaliyah perfectly. Born in Brooklyn, New York but raised in Detroit, Aaliyah got her first major exposure appearing on the syndicated television series _"Star Search" (1983)_ (qv) where she awed the audience with her amazing voice and talent. Withdrawing from the celebrity scene for a few years, Aaliyah lived the life of a normal teenage girl, attending Detroit's Performing Arts High School where she majored in dance. It was around this same time that Aaliyah met singer/composer 'R. Kelly' (qv). Kelly assisted Aaliyah with the production of her debut album "Age Ain't Nothing But A number" which scored several number hits, specifically "Back and Forth." The album's title was a brief reference to her short-lived marriage to 'R. Kelly' (qv) (she was 15 years of age at the time, and he was in his 20s). Thir marriage was annulled due to her status as a minor. During her senior year, Aaliyah went on to record "One In A Million" which featured the songwriting talents of major R&B producers/writers 'Missy 'Misdemeanor' Elliott' (qv) and 'Tim Mosley (I)' (qv). That album was a major success and sealed Aaliyah's fame forever. After seeing her at an awards show and in the video for her hit song "Are You that Somebody?" (from the 'Eddie Murphy (I)' (qv) film _Doctor Dolittle (1998)_ (qv)), film producer 'Joel Silver (I)' (qv) (producer of _The Matrix (1999)_ (qv) and other major actor films) asked Aaliyah to audition for a role in an upcoming romance/action film called _Romeo Must Die (2000)_ (qv). With her determination and sex appeal, Aaliyah won Silver over and was cast in her first major film role. _Romeo Must Die (2000)_ (qv) was a hit at the box office. This film led to her being cast as one of the stars of the film based on 'Anne Rice (I)' (qv)'s _Queen of the Damned (2002)_ (qv) and in the two sequels to the major box office hit, _The Matrix (1999)_ (qv). During the busy schedule of her film career, Aaliyah took time to record her third album, the self-titled "Aaliyah". July 2001 was a busy time for Aaliyah. After the sucess of her song "Try Again" for which she was nominated for a Grammy Award and won several MTV Video Awards, Aaliyah finally released her "Aaliyah" album. Debuting at number two on the Billboard charts, "Aaliyah" was a sales success despite many lack-lustre reviews it received. In August 2001, Aaliyah took time off from her busy album promotional tour to fly to the Bahamas to film a video for the song "Rock the Boat". The video, filmed on Abaco Island, was directed by 'Hype Williams' (qv), a major music video director known for his style and wit. On August 25, 2001, after filming the video, Aaliyah and about 9-11 of her entourage took off from Marsh Harbour airport at 6:50pm EDT in a small Cessna 404 en route to Opa-Locka, Florida. A few minutes after take-off, the plane crashed about 200 feet from the runaway killing Aaliyah and many others instantly. Four passnegers were pulled alive from the wreckage, and one later died at a hospital in Nassau. Aaliyah was only 22 years old. Aaliyah's short-lived, but brillant career was a true success story for a young African-American woman who went against all odds to be herself in an industry where originality is scarce. Truly missed by her family, friends, and fans, her music and film contributions will live forever.	Luis32789@aol.com
785	1739753	19	On January 16th 1979 the world was blessed with the birth of Aaliyah Dana Haughton in Brooklyn, New York. Aaliyah was raised by her father, mother and brother 'Rashad Haughton' (qv) in Detroit. At age 9 she appeared on _"Star Search" (1983)_ (qv), the TV program and sang "My Funny Valentine", a song which her mother had sung years earlier. At age 11, she sang with 'Gladys Knight' (qv) in a five-night stint in Las Vegas. In 1992, she began to work on her debut album with the help of singer 'R. Kelly' (qv). The album, "Age Ain't Nothing But A Number" was released in 1994 and received heavy praise. Aaliyah came under attack shortly after when reports suggested she was married to 'R. Kelly' (qv). At the time, she was 15, he was 27. The marriage was apparently annulled. In 1995, she began to work on her 2nd album, alongside 'Jermaine Dupri' (qv), 'Tim Mosley (I)' (qv), 'Slick Rick (I)' (qv) and Missy 'Misdemeanor' Elliott'. The album, titled 'One In A Million' was released on August 27th 1996. In 1998 she released the single, 'Are you that somebody?' from the _Doctor Dolittle (1998)_ (qv) soundtrack, it was produced by her friends 'Tim Mosley (I)' (qv). Later that year she released the single 'Journey to the past', from the _Anastasia (1997)_ (qv) soundtrack. In 2000, she made her film acting debut and starred as Trish O'Day in the smash hit, hip-hop, kung fu film, _Romeo Must Die (2000)_ (qv) alongside 'Jet Li' (qv). The producer was so impressed by her performance she got parts in _The Matrix Reloaded (2003)_ (qv) and _The Matrix Revolutions (2003)_ (qv). She made numerous records for the soundtrack and released 'Try Again', for which she was nominated with 'Best female video' and 'Best Video in a film' with MTV. In 2001 she was nominated with 2 awards for MTV, the 'Breakthrough female' and 'best performing female'. In July 2001 she released her third album, the self-titled, 'Aaliyah'. In early August of the same year she filmed the video for the single 'More Than a woman', taken off the album and on the 23rd August she started filming for 'Rock The Boat', on Abaco Island, in the Bahamas. On 25th August, filming was completed and her and eight of her crew members including her hair stylist and bodyguard boarded a small plane. Shortly after take off, the plane crashed and exploded, Aaliyah and all on board, perished. Aaliyah's funeral was held on Friday August 31st in New York, and 22 white doves were flown to celebrate each year of her life. Soon after her death, the hit singles 'More Than a woman' and 'Rock The Boat' were released from her third album. In 2002, the film _Queen of the Damned (2002)_ (qv) by 'Anne Rice (I)' (qv) was released in which Aaliyah played the lead, Queen Akasha. She was nominated for best Villain at the MTV movie awards 2002. Looking back at her biography, it's no wonder her name means 'Highest, most exhalted one; the best', she had achieved so much in her short life of 22 years.	James Bryant
786	1739753	17	Auditioned for a role on the television sitcom _"Family Matters" (1989)_ (qv).	\N
787	1739753	17	(1999) Chosen as one of Teen People Magazine's "21 Hottest Stars Under 21."	\N
788	1739753	17	4 tattoos: The letter "A" on the side of her wrist, an Egyptian Unk in her inner wrist, a music symbol on her ankle and a dove on her lower back.	\N
789	1739753	17	(2000) Voted First Place by the readers of Black Men Magazine for "The 10 Sexiest Women of the Year."	\N
790	1739753	17	Performed with 'Gladys Knight' (qv) at age eleven in Las Vegas.	\N
791	1739753	17	(July 17, 2001) Aaliyah's self-titled long awaited third album is released.	\N
792	1739753	17	Got her dove tattoo as a tribute to her grandmother.	\N
793	1739753	17	Graduated from the Detroit High School of the Performing Arts with a 4.0 GPA.	\N
794	1739753	17	Got her big break on the television show _"Star Search" (1983)_ (qv).	\N
795	1739753	17	(25 August 2001) Died in a plane crash on a return trip from shooting a music video in the Bahamas. The crash, which happened in Marsh Harbour, located on Abaco Island in the Bahamas, was determined to have been caused by the plane being overloaded.	\N
796	1739753	17	She got her middle name Dana from her grandmother.	\N
797	1739753	17	At the time of her death, Aaliyah and her boyfriend, Roc-A-Fella co-CEO 'Damon Dash (I)' (qv), had plans to wed.	\N
798	1739753	17	Parents: Micheal and Diane Haughton. Brother: 'Rashad Haughton' (qv) (born 6 August 1977).	\N
799	1739753	17	At the age of 5, she moved to Detroit, Michigan, where she grew up.	\N
800	1739753	17	At the time of her death, she was scheduled to reloop her dialogue in _Queen of the Damned (2002)_ (qv) and to film the majority of her role for _The Matrix Reloaded (2003)_ (qv) and _The Matrix Revolutions (2003)_ (qv).	\N
801	1739753	17	(Jan 2002) Posthumous single "More Than A Woman" reaches #1 in the UK.	\N
1097	3063848	39	Valrico, Florida, USA	\N
802	1739753	17	(Jan 2002) The first female artist to have a posthumous number one single in the UK record charts.	\N
803	1739753	17	In January 2002 she reached No. 1 in the UK with her single "More Than A Woman". She was knocked off the top spot a week later by another deceased artist - 'George Harrison (I)' (qv).	\N
804	1739753	17	At her funeral, 22 white doves were released from the steps of the church. One dove for each year of her life.	\N
805	1739753	17	Younger sister of 'Rashad Haughton' (qv).	\N
806	1739753	17	Auditioned for the 'Elton John' (qv) Broadway show, Aida.	\N
807	1739753	17	Her uncle, 'Barry Hankerson (I)' (qv), was formerly married to singer 'Gladys Knight' (qv).	\N
808	1739753	17	Her mother Diane was once a promising solo singer but gave it up to raise her children Aaliyah and 'Rashad Haughton' (qv).	\N
809	1739753	17	She had a close friendship with producer/musical artist 'Missy 'Misdemeanor' Elliott' (qv).	\N
810	1739753	17	It was announced in November 2002 that good friend 'Missy 'Misdemeanor' Elliott' (qv) is to produce a tribute album to Aaliyah which will include stars finishing off songs Aaliyah was working on before her death in August 2001. In the same month, it was announced that a posthumous Aaliyah album, entitled "I care 4 u", will be released.	\N
811	1739753	17	Was considered for the role of Alex in _Charlie's Angels (2000)_ (qv), but casting directors deemed her too young and the part went to 'Lucy Liu (I)' (qv).	\N
812	1739753	17	Was considered for the part of Maggie in _Get Over It (2001)_ (qv), but was already committed to _Romeo Must Die (2000)_ (qv). 'Zoe Saldana' (qv) was eventually cast in the role.	\N
813	1739753	17	Was the first choice to play Valerie in _Josie and the Pussycats (2001)_ (qv), but had already signed on for the lead role in _Queen of the Damned (2002)_ (qv). 'Rosario Dawson' (qv) eventually got the part.	\N
814	1739753	17	Was almost the voice of Leah in _Osmosis Jones (2001)_ (qv), but could not accept due to schedule conflicts. The part was eventually voiced by 'Brandy Norwood' (qv).	\N
815	1739753	17	Her grandmother was Native American.	\N
816	1739753	17	She was close friends with 'Nicole Richie' (qv) and 'Beyoncé Knowles' (qv).	\N
817	1739753	17	Was originally cast in the title role in _Honey (2003)_ (qv) but died before production began. 'Jessica Alba' (qv) won the part after her death.	\N
818	1739753	17	Best friend was 'Kidada Jones' (qv).	\N
819	1739753	17	Ranked #36 on VH1's 100 Sexiest Artists.	\N
820	1739753	17	In Arabic, the name Aaliyah means "highest, most exalted one.".	\N
821	1739753	17	Her planned appearance in _State Property 2 (2005)_ (qv) was recast with 'Mariah Carey' (qv) after her death.	\N
822	1739753	17	Had a 4.0 voice - she was a "soubrette soprano".	\N
823	1739753	17	Her video Try Again was the most viewed video of 2000 - 2001, getting over 85,000 views daily.	\N
824	1739753	17	Was named #7 On "America's Hottest 30 Song birds" of (2001).	\N
825	1739753	17	Her song "Rock the boat" Was the most viewed video of the year 2002 Getting over 56,000 views daily.	\N
826	1739753	17	Had 15 #1 Singles Out of 3 Albums.	\N
827	1739753	17	Ranked #12 On Hollywoods Hottest of 2000.	\N
828	1739753	17	Married 'R. Kelly' (qv) when she was only 15 years old. He was 27.	\N
829	1739753	17	Before her death, Aaliyah had planned concerts in more than 22 countries around the world to promote her last album.	\N
830	1739753	22	5' 7 1/2"	\N
831	1739753	15	[interview in July 2001 with Germany's "Die Zeit" newspaper that eerily predicts her death] It is dark in my favorite dream. Someone is following me. I don't know why. I'm scared. Then suddenly I lift off. Far away. How do I feel? As if I am swimming in the air. Free. Weightless. Nobody can reach me. Nobody can touch me. It's a wonderful feeling.	\N
832	1739753	15	[from "MTV Diary: Aaliyah"] want people to remember me as a full-on entertainer and a good person.	\N
833	1739753	15	It's hard to say what I want my legacy to be when I'm long gone.	\N
834	1739753	15	[her advice for aspiring artists) Keep working hard and you can get anything that you want. If God gave you the talent, you should go for it. But don't think it's going to be easy. It's hard!	\N
835	1739753	15	Everything is worth it. The hard work, the times when you're tired, the times where you're a bit sad . . . In the end, it's all worth it because it really makes me happy. There's nothing better than loving what you do.	\N
836	1739753	15	Sensual is being in tune with your sensual self.	\N
837	1739753	15	When I'm long gone, I want to be remembered not just as an actress or singer, but as a full-on entertainer.	\N
838	1739753	15	[on her inspirations]: Sade. How beautiful is she? I chose her because I idolize her. I've always looked up to her. She and I have the same birthday which is January 16th so I feel like she is my soul sister. What I love about Sade is that she stays true to her style no matter what. She can leave us for 8 years and come back and be absolutely mind blowing. And you gotta respect that.	\N
839	1739753	15	Being female, you're raised to be a good, sweet girl and not flip out. So I had to give myself permission to be mean and evil. It's tough. But I've always been drawn to the darker side of things.	\N
840	1739753	20	Brooklyn, New York City, New York, USA	\N
841	1739753	27	_Queen of the Damned (2002)_ (qv)::$5,000,000	\N
842	1739753	27	_Romeo Must Die (2000)_ (qv)::$1,500,000	\N
843	1739753	38	"Playboy" (USA), November 2002, Vol. 49, Iss. 11, pg. 77, by: Jamie Malanowski, "Sex In Cinema 2002"	\N
844	1739753	38	"Celebrity Skin" (USA), March 2002, Vol. 24, Iss. 103, pg. 8, by: staff, "Pop Tarts: One In A Million"	\N
845	1739753	38	"Maxim" (USA), May 2001, Iss. Special, pg. 22, by: Barron Claiborne, "Maxim Hot 100 2001: #14"	\N
846	1739753	38	"FHM" (France), October 2000, Iss. 15, pg. 36, by: Jeff Dunas, "Une Bombe Platine"	\N
847	1739753	34	Usually covered her left eye with her hair	\N
848	1739753	34	Often wore sunglasses in front of the covered left eye	\N
849	1739753	34	Usually wore black leather, or white clothing in her music videos	\N
850	1739753	34	Had on black nail polish in nearly all of her music videos	\N
851	1739753	36	"Femme Fatales" (USA), September/October 2002, Vol. 11, Iss. 10/11, pg. 10-13, by: Craig Reid, "Memories of Aaliyah: A look at the life and tragic end of a multi-talented performer."	\N
852	1739753	36	"Femme Fatales" (USA), September/October 2002, Vol. 11, Iss. 10/11, pg. 14, by: Chuck Wagner, "Enduring Spirit: She went from pop princess, to Egyptian Vampire Queen, to immortal icon."	\N
853	1739753	36	"Entertainment Weekly" (USA), 7 September 2001, Vol. 1, Iss. 612, pg. 16-17+24, by: Tom Sinclair, "Mourning Aaliyah"	\N
854	1739753	36	"The Ottawa Citizen" (Canada), 26 August 2001, pg. 2-3, "Aaliyah confirmed dead in plane crash saturday August 25 2001 at 6:50 pm in the Bahamas"	\N
855	1739753	36	"details" (USA), April 2000, pg. 138, by: Josh Dean, "Trading ballads for bullets "	\N
856	1739753	36	"Teen People" (USA), June 1999, pg. 66-67, by: April P. Bernard, "21 Hottest Stars Under 21"	\N
857	1739753	26	Haughton, Aaliyah Dana	\N
858	1739753	24	'R. Kelly' (qv) (30 August 1994 - 7 February 1995) (annulled)	\N
859	1739753	23	25 August 2001	\N
860	1739753	21	16 January 1979	\N
861	3063834	20	Kaukola, Finland	\N
862	3063834	21	7 October 1930	\N
863	1739757	17	Married to Bollywood actor Ranjeet.	\N
864	2701195	26	Aaltio, Lauri	\N
865	2701195	20	Pukkila, Finland	\N
866	2701195	23	20 August 2001	\N
867	2701195	24	'Raili Aaltio' (? - ?); 2 children	\N
868	2701195	21	28 June 1925	\N
869	3316924	20	Nurmijärvi, Finland	\N
870	3316924	21	29 January 1982	\N
871	664	17	Famous architect and designer. He graduated in 1921 from the Helsinki University of Technology with a degree in architecture.	\N
872	664	17	Children: Johanna (b. 1925) and Hamilkar (b. 1928).	\N
873	664	17	Both of his wives were also architects.	\N
874	664	39	Helsinki, Finland	\N
875	664	19	Alvar Aalto, one of Finland's most famous people who reshaped architecture and furniture of public buildings on the basis of functionality and organic relationship between man, nature and buildings, is now called the "Father of Modernism" in Scandinavian countries.  He was born Hugo Alvar Henrik Aalto, on February 3, 1898, in Kuortane, Finland (at that time Finland was part of Russian Empire). He was the first of three children. His father, J. H. Aalto, was a government surveyor. His mother, Selma Hackestedt, was of Swedish ancestry, she died in 1903. His father remarried and moved the family to the town of Jyvaskyla. There young Aalto attended the Normal School and the Classical Gymnasium, graduating in 1916. During the summer months, young Aalto accompanied his father on surveying trips. From 1916-1921 he studied at the Helsinki University of technology, graduating with a degree in architecture. While a student, Aalto worked for Carolus Lindberg on the design of the "Tivoli" area for the 1920 National Fair. At that time Aalto was a protégé of Armas Lingren, partner of E. Saarinen during the formative period of Finnish National architecture of Romanticism. Aalto served in the Finnish National Militia during the Civil War that followed after the Russian Revolution, when the nation of Finland gained independence from Russia.  In 1922-1923 Aalto worked for a project in Sweden, he collaborated with A. Bjerke on the design of the Congress Hall for the 1923 World Fair in Goteborg. He also designed several buildings for the 1922 Industrial fair in Tampere. In 1923 Aalto opened his first architectural office in Juvaskyla. In 1924 he married architect Aino Marsio, they had two children, Johanna (born 1925), and Hamilkar (born 1928). Aalto and his wife had their honeymoon in Italy. The Mediterranean culture made a profound influence on Aalto's creativity, it blended with his Nordic intellect and remained important to his visionary works for the rest of his life. The simple massing and ornamentation of the "architettura mirwire" of Northern Italy translated into Aalto's style with its balanced proportions, harmonious volumes rendered in stucco or wood, and sparse decoration with selective use of classical elements. In 1927 the Aaltos moved to the city of Turku. There Alvar Aalto designed the Paimio Sanatorium, a building that elevated him to the status of master of heroic functionalism. He soon moved forward in his pursuit of artistic harmony through organic integration of people and buildings with the environment. Such was his design for the Villa Mairea (1938) in Noormarkku, one of the most admired private residences in contemporary architecture.  In 1933 Aalto moved to Helsinki. There he founded his architecture firm "Artek" where he executed his major international commissions, such as Finnish Pavilions for the 1936 Paris World Fair and the 1939-1940 New York's World Fair, libraries in Oregon, USA, and Finland, Opera House in Essen, Germany. His other significant buildings included Baker House at the Massachussetts Institute of Technology, Cambridge, Mass., USA, Central University Hospital in Zagreb, Croatia, Helsinki Institute of Technology, North Utland Art Museum in Denmark, Nordic House in Reykjavic, Iceland, Public Library in Vyborg, (now Russia), and many other buildings. His later masterpieces include the municipal building in Sayanasalo (1952), the Vuoksenniska Church (1959) and the Finlandia Hall in Helsinki. His works exhibit a range of innovative ideas presented with comforting clarity and carefully crafted balance of intricate and complex forms, spaces, and elements, that are integrated in a simple and well-proportioned way. Aalto's design for the Finnish Pavilion at the 1939 New York's World Fair was described as "work of genius" by 'Frank Lloyd Wright (I)' (qv).  Functionalism and synthetic attitude were important in Aalto's evolution from Nordic Classicism towards Modernism. He created his own way of converging forms, materials, and purpose of his buildings on the rationale of their functionality, aesthetics, and comfortable use. Aalto's architecture, furniture, glassware and jewelery evokes multiple allusions to images of unspoiled nature, thus making an ennobling influence on public behavior. He designed 70 buildings for the town of Jyvaskyla, 37 of which were realized, such as the Institute of Pedagogy (1953-1957) and other public buildings. Aalto's ecological awareness was epitomized in his design of the Sunila Cellulose Industry and the residential village for employees (1936 - 1939) and its second stage (1951 - 1954). Aalto's creativity was deeply rooted in his own organic way of life, traditional for the people in Scandinavian countries. "The very essence of architecture consists of a variety and development reminiscent of natural organic life. This is the only true style in architecture" said Alvar Aalto.  Alvo Aalto was Chairman of the Arcitects Union and President of the Finnish Academy. His latest building for the Art Museum in Jyvaskyla was named after him. His awards included the Royal Gold Medal from the Royal Institute of British Architects (1957) and the Gold Medal from the American Institute of Architects (1963). Alvar Aalto was featured on the last series of the 50 Finnish mark bill, before the Euro. He died of natural causes on May 11, 1976, in Helsinki and was laid to rest in Hietaniemi Cemetery in Helsinki, Finland.	Steve Shelokhonov
876	664	15	I do not write, I build.	\N
877	664	20	Kuortane, Finland	\N
878	664	29	Goran Schildt, ed.. _Alvar Aalto In His Own Words._ Rizzoli,	\N
879	664	26	Aalto, Hugo Alvar Henrik	\N
880	664	24	'Aino Aalto' (6 October 1924 - 13 January 1949) (her death); 2 children	\N
881	664	24	'Elissa Aalto' (4 October 1952 - 11 May 1976) (his death)	\N
882	664	23	11 May 1976	\N
883	664	21	3 February 1898	\N
884	666	20	Viipuri, Finland	\N
885	666	21	6 February 1931	\N
886	1739765	26	Tuunanen, Edla Inkeri	\N
887	1739765	20	Muhos, Finland	\N
888	1739765	24	'Antti V.J. Aalto' (? - ?) (divorced); 2 children	\N
889	1739765	21	3 April 1923	\N
890	1739778	20	Finland	\N
891	1739778	21	1976	\N
892	682	26	Aalto, Rostislav Sergejevich	\N
893	682	20	Moscow, Russian SFSR, USSR [now Russia]	\N
894	682	21	31 July 1971	\N
895	685	20	Turku, Finland	\N
896	685	21	November 1986	\N
897	690	20	Rauma, Finland	\N
898	690	25	Iltalehti news paper editor-in-chief (2002-)	\N
899	690	25	SubTV managing director (2001-2002)	\N
900	690	25	Alma Media content manager (2000)	\N
901	690	25	Nelonen (Finnish Channel 4 TV) News editor-in-chief (1998-2000)	\N
902	690	21	6 May 1966	\N
903	691	39	Helsinki, Finland	\N
904	691	19	Heikki Aaltoila's father was an amateur actor and musician. Aaltoila studied music 1928-34 at Helsinki Conservatoire with 'Erkki Melartin' (qv), 'Leevi Madetoja' (qv) and Ernst Linko. He played the piano in silent movies, and also double bass at Helsinki University Student Orchestra. He had a job at the Finnish Broadcasting Company 1939-44, and he was the musical conductor of the Finnish National Theatre 1934-73. He composed, arranged and conducted the music for some 150 stage plays. As a film composer, he wrote music for around 75 movies.  Aaltoila had the capability to use several kind of musical styles (from Middle Age to Jazz and Modernism), and his orchestrations are very vivid. He was music critic in several newspapers in 1932-86. * "Jussi" Prize for year's best film score in 1954 and 1955.	Markus Lång <mlang@elo.helsinki.fi>
905	691	20	Hausjärvi, Finland	\N
906	691	26	Aalto, Heikki Johannes	\N
907	691	24	'Inkeri Hupli' (? - ?); 3 children	\N
908	691	24	'Marja Liuhto' (1941 - 1949) (divorced)	\N
909	691	23	11 January 1992	\N
910	691	21	11 December 1905	\N
911	692	25	Dancer and choreographer	\N
912	692	21	1958	\N
913	700	39	Helsinki, Finland	\N
914	700	20	Hämeenlinna, Finland	\N
915	700	23	8 March 1990	\N
916	700	21	17 August 1910	\N
917	1739786	20	Lappeenranta, Finland	\N
918	1739786	21	9 December 1934	\N
919	705	20	Turku, Finland	\N
920	705	17	Works for Illume Oy.	\N
921	705	21	1956	\N
922	710	22	5' 7"	\N
923	710	21	15 January 1992	\N
924	713	26	Aaltonen, Kalevi Osvald	\N
925	713	20	Helsingin mlk., Finland	\N
926	713	21	5 October 1957	\N
927	715	39	Espoo, Finland	\N
928	715	20	Urjala, Finland	\N
929	715	23	18 April 1957	\N
930	715	21	23 March 1900	\N
931	1739790	22	168 cm	\N
932	1739790	20	Turku, Finland	\N
933	1739790	33	(1999) Lives in London, works both in Finland and in the UK.	\N
934	1739790	26	Aaltonen, Minna Kaisa	\N
935	1739790	17	Daughter of Finnish actress 'Leena Takala' (qv)	\N
936	1739790	17	Graduated from Mountview Theatre School, UK.	\N
937	1739790	21	17 September 1966	\N
938	724	20	Turku, Finland	\N
939	724	21	7 January 1938	\N
940	725	17	Has been a member of of several Finnish rock'n'roll bands, including the legendary Hurriganes in the 1970s.	\N
941	725	17	He doesn't speak English very well, so while making music with Hurriganes his bandmates wrote lyrics in a phonetic format (words written as they are spoken).	\N
942	725	31	_Ganes (2007)_ (qv)	\N
943	725	31	_Lähikuvassa Remu Aaltonen (1983) (TV)_ (qv)	\N
944	725	20	Helsinki, Finland	\N
945	725	26	Aaltonen, Henry Olavi	\N
946	725	34	Bald	\N
947	725	21	10 January 1948	\N
948	726	26	Aaltonen, Risto Kalevi	\N
949	726	20	Helsinki, Finland	\N
950	726	24	'Heidi Elisabet Öhman' (1964 - 1977) (her death); 2 children	\N
951	726	24	'Hanni Marjatta Tiensuu' (1978 - 1990) (divorced); 2 children	\N
952	726	24	'Sisko Hallavainio' (2002 - present)	\N
953	726	21	16 March 1939	\N
954	3063844	20	Helsinki, Finland	\N
955	3063844	23	12 January 1983	\N
956	3063844	21	30 March 1906	\N
957	1739794	26	Aaltonen, Ulla-Maija	\N
958	1739794	20	Vihti, Finland	\N
959	1739794	23	13 July 2009	\N
960	1739794	39	Helsinki, Finland	\N
961	1739794	21	28 August 1940	\N
962	732	26	Aaltonen, Veikko Onni Juhani	\N
963	732	20	Sääksmäki, Finland	\N
964	732	21	1 December 1955	\N
965	733	20	Finland	\N
966	733	21	7 March 1950	\N
967	735	39	Helsinki, Finland	\N
968	735	20	Marttila, Finland	\N
969	735	23	30 May 1966	\N
970	735	24	'Elsa Rantalainen' (qv) (1931 - 1941) (divorced)	\N
971	735	21	8 March 1894	\N
972	736	39	Helsinki, Finland	\N
973	736	20	Rauma, Finland	\N
974	736	23	19 April 1979	\N
975	736	21	31 January 1916	\N
976	1739797	20	Denmark	\N
977	1739797	21	1 April 1962	\N
978	1739801	37	"Overdrive Magazine" (USA), October 1978	\N
979	1739801	39	West Hills, California, USA (heart disease)	\N
980	1739801	19	Angela Aames grew up in Pierre, South Dakota. She acted in high school and attended the University of South Dakota before coming to Hollywood in 1978 to begin her acting career. Her first film role was as Little Bo Peep in the film _Fairy Tales (1978)_ (qv). She followed that up by playing Linda "Boom-Boom" Bang in _H.O.T.S. (1979)_ (qv). Other film roles included _...All the Marbles (1981)_ (qv), _Scarface (1983)_ (qv), _Bachelor Party (1984)_ (qv), _The Lost Empire (1985)_ (qv), _Basic Training (1985)_ (qv), and _Chopping Mall (1986)_ (qv). She did guest appearances on several television shows, including _"Cheers" (1982)_ (qv) and _"Night Court" (1984)_ (qv). Her last role was as Penny, a fitness instructor, on _"The Dom DeLuise Show" (1987)_ (qv). Angela was found dead at a friend's home in West Hills in the San Fernando Valley on November 27, 1988. The coroner later ruled that her death was a result of a deterioration of the heart muscle, probably caused by a virus. She was 32 at the time.	Don Nelsen <kpaden@cobweb.net>
981	1739801	19	Beautiful, buxom blond Angela Aames made her mark in Hollywood during the late 1970s and 1980s while appearing in a string of silly T & A comedies and exploitation movies. Additionally, she appeared on numerous TV shows in sexy bit parts that sadly amounted to little more than window dressing.  While she aspired to be a comedienne, her ample curves made her most suitable to play the series of voluptuous party girls and sex kittens that eventually would comprise her resume.  Angela was born February 27, 1956. An early resume indicates that, early, her thespian training included stints at the 'Lee Strasberg' (qv) Theatre Institute and 'Harvey Lembeck' (qv)'s Comedy Workshop, and stage appearances in such theatrical fare as "Of Mice and Men", "The Lion in Winter", "A Midsummer Nights Dream", "The Importance of Being Earnest", "Tartuffe", "The Pleasure of his Company", "Dark of the Moon" and "The Women".  In addition to Angela's verified credits as published at IMDb, her resume lists a number of other appearances in film and television including the 20-minute educational short called "Malice in Bigotland" as well as an industrial short for G.T.E. that dealt with sexual harassment. Also listed are appearances on the Telethon for Autistic Children and Krofft Supershows.  Her television work included bit parts in shows like _"Barnaby Jones" (1973)_ (qv), _"Angie" (1979)_ (qv), _"Out of the Blue" (1979)_ (qv), _"Mork & Mindy" (1978)_ (qv), _"Hill Street Blues" (1981)_ (qv), _"Cheers" (1982)_ (qv), _"Automan" (1983)_ (qv) and _"Alice" (1976)_ (qv), in addition to her recurring appearances on _"B.J. and the Bear" (1978)_ (qv), _"The Fall Guy" (1981)_ (qv) and _"Night Court" (1984)_ (qv). All featured Angela in tight outfits with copious amounts of cleavage on display. In her _"Cheers" (1982)_ (qv) appearance, in the episode called _"Cheers" (1982) {Sam's Women (#1.2)}_ (qv), Angela plays her "bimbo" role with such skill that her spelling of her name, "Brandee-with two E's", is the show's funniest and most memorable line.  In 1983, she appeared on Cinemax's _Likely Stories, Vol. 4 (1983) (TV)_ (qv), playing an 80-foot tall, bikini-clad giantess.  Her earliest film role appears to have been _Fairy Tales (1978)_ (qv), in which she plays a sexier "Little Bo Peep" than you've probably seen before. Angela briefly appeared nude in this film, and clips of her nude scene later appeared in made-for-video compilations like _The Best of Sex and Violence (1981)_ (qv) and _Famous T & A (1982) (V)_ (qv). Taking one look at her, Angela was simply made to play the part of Linda "Boom Boom" Bangs in _H.O.T.S. (1979)_ (qv), which had her skydiving topless into a swimming pool, among other exploits that made effective use of her frontal anatomy. Her resume also lists an otherwise unknown film from this period, called "The Crazy".  Angela appeared in bit parts a number of made-for-TV movies in 1980-81 appearances, which mostly showcased her figure and which included "Moviola" (aka _This Year's Blonde (1980) (TV)_ (qv)), _Charlie and the Great Balloon Chase (1981) (TV)_ (qv), _The Comeback Kid (1980) (TV)_ (qv) and _The Perfect Woman (1981) (TV)_ (qv).  The early 1980s saw her topless again in _...All the Marbles (1981)_ (qv). She also appeared, briefly, in _Boxoffice (1982)_ (qv), as a pregnant Hollywood starlet at a posh dinner party. In 1983, Angela had a non-speaking walk-through part in _Scarface (1983)_ (qv).  In 1984, she had arguably her most memorable moment on-screen, in the now-cult classic 'Tom Hanks' (qv) vehicle _Bachelor Party (1984)_ (qv). During the film's opening credits, Aames appears in 'Adrian Zmed' (qv)'s photography studio as a mother having baby pictures taken of her infant child. With a red "come get me" top cut practically to her navel, she made indelible impressions on legions of adoring male fans.  Her later film roles, in the mid to late 1980s, included 'Jim Wynorski' (qv)'s _The Lost Empire (1985)_ (qv), _Basic Training (1985)_ (qv) and _Chopping Mall (1986)_ (qv). _The Lost Empire (1985)_ (qv), in particular, allowed Angela to take more of a leading role, demonstrating her fine flair for comedy in addition to her big breasts. There are also some vague Internet references to an appearance in a 1988 "documentary" on bodybuilding called "Flex" (1988), and also starring Harry Grant and 'Tom Platz' (qv). This is certainly plausible, as Angela had reportedly taken up weightlifting in the years just before her untimely death.  In 1988, she had secured a starring role in the weekly sit-com _"The Dom DeLuise Show" (1987)_ (qv), in which she portrayed an aerobics instructor who frequented the beauty and barber shop around which the show revolved. During the show's pilot episode, she made a spectacular entrance, clad in a skin tight leotard, during which 'Dom DeLuise' (qv) commented, to the audience, "I just love watching her jog!"  In addition to her numerous TV and film appearances, Angela occasionally modeled. Notably, she was a "Mint 400 Girl" in 1982. The "Mint 400 Girls" were glamorous race beauty queens integrally involved in the publicity for the prestigious Mint 400 Las Vegas off-road race. She has been featured in a number of publications over the years, including Adam Magazine, Playboy, Partner, Variety, Celebrity Sleuth, Femme Fatales and the National Enquirer.  Angela died unexpectedly on November 27, 1988, of what was officially declared "heart disease". She was 32 years old. She is buried in Riverside Cemetery in Pierre, South Dakota, where she was born.  There were actresses who had better roles and who achieved more in their careers, but the fact that, despite her rather lightweight film roles, Angela's fans fondly remember her nearly twenty years after she left us speaks volumes about her cinematic legacy.	Brent Blackburn
982	1739801	20	Pierre, South Dakota, USA	\N
983	1739801	38	"Femme Fatales" (USA), September 1998, Vol. 7, Iss. 4, pg. 44-45, by: Jim Wynorski, "Thanks for the Mammaries"	\N
984	1739801	38	"Celebrity Sleuth" (USA), 1990, Vol. 3, Iss. 3, pg. 21, by: staff, "Hostesses With The Mostest: Bedtime Movie Girl"	\N
985	1739801	38	"Playboy" (USA), July 1986, Vol. 33, Iss. 7, pg. 189, by: Alan Houghton, "Grapevine: Throw in a Towel"	\N
986	1739801	38	"Partner" (USA), September 1982, Vol. 4, Iss. 4, pg. 9, "Celebriteasers Sex Starlet Special"	\N
987	1739801	38	"Overdrive Magazine" (USA), October 1978, "Date Master"	\N
988	1739801	36	"National Enquirer" (USA), 17 February 1987, pg. 17, by: Don Monte, ""TV - Behind the Screens""	\N
989	1739801	36	"Playboy" (USA), February 1983, Vol. 30, Iss. 2, pg. 138, "The Year In Sex"	\N
990	1739801	36	"National Enquirer" (USA), 28 September 1982, "TV - Behind the Screens"	\N
991	1739801	24	'Mark Haughland' (? - 27 November 1988) (her death)	\N
992	1739801	23	27 November 1988	\N
993	1739801	21	27 February 1956	\N
994	750	37	"Home Life" (USA), June 2004	\N
995	750	37	"People Weekly" (USA), 3 December 1979	\N
996	750	28	Buddy	\N
997	750	19	Aames has a son, Christopher, with his first wife. Aames met his second wife, 'Maylo McCaslin' (qv), in 1984 on the set of _"Rocky Road" (1985)_ (qv), a cable sitcom in which she starred. They live in rural Olathe, Kansas with their daughter, Harleigh.	Anonymous
998	750	17	Dated his _"Eight Is Enough" (1977)_ (qv) TV sister 'Connie Needham' (qv).	\N
999	750	17	The youngest of two older brothers and an older sister.	\N
\.


--
-- Data for Name: role_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_type (id, role) FROM stdin;
1	actor
2	actress
3	producer
4	writer
5	cinematographer
6	composer
7	costume designer
8	director
9	editor
10	miscellaneous crew
11	production designer
12	guest
\.


--
-- Data for Name: title; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.title (id, title, imdb_tiny_index, kind_id, production_year, imdb_tiny_id, phonetic_code, episode_of_id, season_nr, episode_nr, series_years, md5sum) FROM stdin;
80889	(#1.66)	\N	7	1980	\N	\N	80815	1	66	\N	4de45f35edf0b753c54ab72dcbe68bb5
5156	Josie Duggar's 1st Shoes	\N	7	2010	\N	J2326	5022	4	13	\N	8d492850166137b550ceb0e9a5b46086
197772	(#2.8)	\N	7	1962	\N	\N	197751	2	8	\N	152b0f7213dd467760823b0d6387a6ec
111913	(2012-09-13)	\N	7	2012	\N	\N	111095	\N	\N	\N	daf144630ef1ab1cd5d1d028b406cdcf
117556	(#1.1042)	\N	7	\N	\N	\N	117506	1	1042	\N	be62adfea75e456d47ddab5c68ac96b0
40704	Anniversary	\N	7	1971	\N	A5162	40698	4	9	\N	5e12ce73fac1d1dcf94136b6e9acd8f8
164312	(#13.60)	\N	7	1997	\N	\N	164254	13	60	\N	2d7b85508041bc8b1e4b576f328727b9
149337	Mellody Hobson	\N	7	2005	\N	M4312	149328	1	8	\N	5bf869eaffa411fdc51e06c2020952d5
32020	Kiss Me Kate	\N	7	2011	\N	K2523	32014	1	10	\N	293e8c75c7f35a4035abf617962be5a9
36858	(2012-09-11)	\N	7	2012	\N	\N	36138	\N	\N	\N	7c4d73fbab6bf1bbf3cb3958c5f975a9
112085	The Best of Olivia	\N	7	2008	\N	B2314	111095	1	762	\N	1b8dc7b88bba29abade0df92564d0c69
25704	Macauley's Cure	\N	7	1966	\N	M2426	25696	1	34	\N	295cd3e29779b6ae1550fe3817cfea39
49634	Discriminación en el lenguaje	\N	7	1998	\N	D2652	49611	\N	\N	\N	7a865a589dbaec16d2e4f5a0f068e9ae
37608	The Eye of Ra: Part 2	\N	7	1971	\N	E1616	37579	2	11	\N	faebb738a1a761ed8928cb4b65367036
92382	Shinkai no akuma	\N	7	2011	\N	S5252	92364	1	11	\N	e9f24b4c2878e2b099931fbd0dc80914
7532	Beautiful, Married & Missing	\N	7	2009	\N	B3145	7383	\N	\N	\N	890adf0e8ff5ba69b8f6dc7b0dce84e7
5522	Game 2	\N	7	1951	\N	G5	5520	\N	\N	\N	4b042601dbe4f50d6691a7d41e703941
33423	(2012-05-30)	\N	7	2012	\N	\N	33102	\N	\N	\N	08098b9e95d2ea3ed513c4e7665e68cf
165729	Blowout	\N	2	2004	\N	B43	\N	\N	\N	2004-????	d047de6e356eef4efcc36541cb121a61
73362	The 500 Percent Club	\N	7	2012	\N	P6253	73295	\N	\N	\N	249db59011a04a4d3454c5985559b11c
122463	Christmas Special	\N	7	2006	\N	C6235	122400	8	11	\N	c848c27c04725bef4794a0178b4a6660
37110	Tim Clark - President of Emirates Airlines	\N	7	2012	\N	T5246	37092	1	2	\N	c7aff07b7db42f487b5140c27147c81b
156252	Hessens schönste Kurbäder	\N	7	2008	\N	H2525	156245	\N	\N	\N	7f2b20a949126b467c108dc7cf39cd86
126955	(1977-03-05)	\N	7	1977	\N	\N	126283	\N	\N	\N	8f3513eb2fc28323132d57e3031c87ed
189047	(2012-11-03)	\N	7	2012	\N	\N	189008	\N	\N	\N	7695346a1d35b27aae96ab11ce087910
2903	(2002-06-29)	\N	7	2002	\N	\N	2894	\N	\N	\N	bca48eae0eeae88dc3c9cf68a0294d1d
11566	(#1.8)	\N	7	2012	\N	\N	11555	1	8	\N	ff1f7f30f7745185cc132faebf6ff616
160794	Self-Awareness as a Soldier! Strength Lies in the Pure Heart	\N	7	1995	\N	S4165	160772	1	38	\N	eb32612a744424c3b79a8959c48aa89b
62387	The Breaking Point/Working Class People/The Voter's Choice: Part 3	\N	7	1990	\N	B6252	62368	3	3	\N	8cc4d380db8007ade9ba56c1ae425a4f
85015	(#1.190)	\N	7	2002	\N	\N	84913	1	190	\N	1ad2308948521ed682e17c0c6c3443cf
81082	The Weight: Part 1	\N	7	2004	\N	W2316	80989	5	1	\N	30a18346d8c8e0c540c8f551c50da699
91059	Osa 118. Kimonkylän taidekoti	\N	7	2003	\N	O2524	91033	16	15	\N	c519b9b1181c5ada819404719b376e9a
182150	Los capos no mueren	\N	7	1992	\N	C1256	182140	1	11	\N	90496f4ca68c6fe18066938defecb600
144818	Cousin und Cousine	\N	7	2002	\N	C2532	144806	1	21	\N	698d9f1c3022fcbc307ee890e82aebed
188109	Gun-Talk	\N	7	1956	\N	G5342	188095	2	15	\N	0562f67fc2f5faf224b877abecbf0258
194163	(#1.6)	\N	7	1994	\N	\N	194139	1	6	\N	123158ec8fade1f19f91e4dfc615dc38
185522	Nanny from Heaven	\N	7	1989	\N	N5165	185452	5	14	\N	39ec26fcbd767580e3045df9e5f749ab
116833	Halve Finale #1	\N	7	2009	\N	H4154	116831	1	1	\N	82fec9563ad32c9451c2a17c47179a12
10794	Guilt-Free Pub Grub	\N	7	2010	\N	G4316	10671	\N	\N	\N	1d7f1a5e32af5177ae5b111938785489
152481	(#3.11)	\N	7	2002	\N	\N	152267	3	11	\N	586cdbb346ba263aceb7850a6edb1efe
33079	Cloned Puppies: A New Generation of 'Trakrs'	\N	7	2009	\N	C4531	32442	\N	\N	\N	e13740a30a18f2fadd9b0883acf2129f
7310	Adults Only 20 to 1: World's Sexiest Scandals	\N	7	2010	\N	A3432	7301	9	2	\N	194dad479c29213396da565071a65d02
18390	All That Jasmine	\N	7	1994	\N	A4325	18389	1	5	\N	3bc9caa126ef9513b79e850b9ef8be71
126091	(#5.8)	\N	7	2009	\N	\N	126014	5	8	\N	2c6e41a60e9c16fc565af9fe67593a15
20232	Baby Manning	\N	7	1998	\N	B152	20037	\N	\N	\N	825389d4e35f378f950238020942782e
134182	(2010-07-27)	\N	7	2010	\N	\N	134128	\N	\N	\N	2e3e5afc8e111eacd98699c6f28d444b
192882	Solo de flûte	\N	7	2006	\N	S4314	192835	1	11	\N	87d600911ba20aa46778f322eadaaec0
59538	(2002-02-09)	\N	7	2002	\N	\N	59480	\N	\N	\N	f1a0a17ab85d025061f63ae22b53a686
95727	Érase un negocio	\N	7	2004	\N	R252	95690	2	3	\N	52e5bc0c77f0b064ff11cd7c721076d7
99644	Peru to Brazil	\N	7	\N	\N	P6316	99633	1	1	\N	a2a3f9a9dfaa6c23ec1d96cff3d43711
60770	Blutsbande	\N	7	2006	\N	B4321	60768	1	7	\N	f26233762bac22bbe9d74be23a88cd6b
6883	(1999-01-09)	\N	7	1999	\N	\N	6845	\N	\N	\N	3805102536744e2cc28ccc0dc69b2fac
11306	Amande	\N	7	\N	\N	A53	11299	1	29	\N	fc10451a055daf0c1996ba919c84cbd3
101193	Squeeze Rockin' Freak Painting or Pumpkin Pies Plymptoon	\N	7	2006	\N	S2625	101172	2	1	\N	cf30dbefb48c6a3de8c9797a1e498dd5
133148	Did You Win?	\N	7	2012	\N	D35	133147	1	13	\N	0f718d7ed363df8564c2a5768a485e73
183966	Boys and Girls Together Again	\N	7	1992	\N	B2532	183962	1	15	\N	201d7f0dddc87b03dd164bd40fd488a3
86817	(1982-07-30)	\N	7	1982	\N	\N	86671	\N	\N	\N	feb3c50a56d633597ca86ecc6f048b42
16604	The Next First Lady?/Here Comes the Girls/Toni Morrison	\N	7	1999	\N	N2316	15711	31	20	\N	6385686401009aa7277c38cea7db489c
125298	The Awakening	\N	7	2012	\N	A252	125231	2	69	\N	f6b66de1cf236137940c5f4f1c75585c
168637	The Entertainer	\N	7	1993	\N	E5363	168611	1	23	\N	7643c6f1545f8e70f2baf95fca2394c2
111657	(2011-05-13)	\N	7	2011	\N	\N	111095	\N	\N	\N	e05b4fd49ed26a97d8d7b2cbd7e68bd3
6507	Lunch Hour	\N	7	2009	\N	L526	6438	2	4	\N	09ae8e22be7f59235d4fbdca3a63e0bc
26155	Tim Burton	\N	7	2012	\N	T5163	26109	\N	\N	\N	f36dba18c95057442419edc182f73dc8
106269	(#2.20)	\N	7	2011	\N	\N	106217	2	20	\N	ec936da7d162a5a75b10f0c6ab412be3
139166	(1999-06-21)	\N	7	1999	\N	\N	139148	\N	\N	\N	fc0ceeac6e4a1c606d973dde3a073ded
85263	(#1.44)	\N	7	2001	\N	\N	84913	1	44	\N	7a24b2a6ae28c37a844cc20a08b9bd58
95087	(2003-04-28)	\N	7	2003	\N	\N	94664	\N	\N	\N	947ebbf4fd84cad212516083c8399387
55171	Wish You Weren't Here	\N	7	1999	\N	W2653	55165	1	5	\N	e2f099b1ffe706eecc211ebedd6e798a
139677	Bedroom Buddies	\N	2	1992	\N	B3651	\N	\N	\N	1992-????	60e631f4a29c899017073ed4ef92c4d0
143915	Reel Murder: Part 2	\N	7	1986	\N	R4563	143813	7	15	\N	395f0d4a7f90ce925ce239ebc42b257c
172767	(2011-12-10)	\N	7	2011	\N	\N	172759	\N	\N	\N	3a6b272edcc7aa825dee59cf08356901
41599	Seret Tadmit	\N	7	2003	\N	S6353	41575	1	6	\N	67daa1fe11df834d28d04126768bcee5
36005	(2012-11-26)	\N	7	2012	\N	\N	35537	\N	\N	\N	2d76aad1af3a32fe61ddce0c69163592
152708	(#8.3)	\N	7	2007	\N	\N	152267	8	3	\N	c9f3ed0a9f74a8f40f9feb477d665517
182060	Lost & Found	\N	7	2006	\N	L2315	182054	1	4	\N	0bafc69d080a0d54b9be60c3bf3b3652
89789	(2003-08-08)	\N	7	2003	\N	\N	87087	\N	\N	\N	41534f521dac02c538734454f54e1a92
15437	(#19.6)	\N	7	2011	\N	\N	15336	19	6	\N	a9fe52e9c0093fdfb01fac39a43356ec
34714	Send Her Victorious	\N	7	1989	\N	S5361	34706	1	5	\N	b7d2fb4f4d636b3c3de9141a7334973a
16083	Hostage/In Search of Bin Laden/The Captain	\N	7	2005	\N	H2325	15711	38	1	\N	ed623cfa59720af8a3427515b0acdfc3
44277	Silence of the Clams	\N	7	2007	\N	S4521	44260	1	2	\N	6577d5b107f4d861680cd75c1c61c7a8
51440	Brennender Ehrgeiz	\N	7	1999	\N	B6536	51415	3	11	\N	b94cbef39180bdcbbf17bc34e3fc7feb
27788	(2002-01-25)	\N	7	2002	\N	\N	27736	\N	\N	\N	fc3a3ed117967deb7d0132cf64246fef
31667	(1991-04-12)	\N	7	1991	\N	\N	31647	\N	\N	\N	4e5fdba1f3d8a74f95c85da456b5a3a5
130053	Count Me In!	\N	7	1999	\N	C535	129983	6	8	\N	5bdba846c128356c914f64da58429bc6
32704	(2012-05-22)	\N	7	2012	\N	\N	32442	\N	\N	\N	a04733c180a683bb2195ccf52cf9568b
168	Oahu, HI	\N	7	2003	\N	O	118	2	2	\N	b61f5f895096b62e2094f32c3606aae5
89993	(2004-05-21)	\N	7	2004	\N	\N	87087	\N	\N	\N	abaef6e681871e08484d81900a027f6e
169030	The Visit to Aunt Ruth's	\N	7	1990	\N	V2353	168958	1	1	\N	8761c8e29cb11ad3ba6176ddc9544d89
4477	Silenci	\N	7	2009	\N	S452	4457	2	6	\N	a72742ad15bc4ed1fc48e39db32ce71b
109242	(2000-06-13)	\N	7	2000	\N	\N	108733	\N	\N	\N	40c9b53898160d2d5dd777c5de62c4c3
28820	(1996-02-12)	\N	7	1996	\N	\N	28531	\N	\N	\N	5d209e19cbb6cd5e2a169a506a9769d8
183700	Broken News	\N	2	2005	\N	B6252	\N	\N	\N	2005-????	64065df245c3a03d2b8393cec153cc86
38282	(2008-07-15)	\N	7	2008	\N	\N	38084	\N	\N	\N	5527873c0ecfb3af31fa65f2becf4ec9
57276	(#1.9305)	\N	7	2006	\N	\N	55774	1	9305	\N	c23e10d30fc4f417387e039ed3677817
168245	Free of Charge	\N	7	1967	\N	F6126	168208	4	19	\N	a7c1cd52c9ae6511dfb7ee0cc579c6c7
74371	American Justice	\N	2	2004	\N	A5625	\N	\N	\N	2004-????	d0d9d994eb34142614894127dc98f750
5392	(#1.8)	\N	7	2011	\N	\N	5383	1	8	\N	66aa6123117ad570cff22a0961cde934
115268	The Boy Next Door	\N	7	2008	\N	B5236	114979	13	18	\N	2da5276828def251a95a367c5a74359a
120056	(#2.9)	\N	7	2009	\N	\N	120036	2	9	\N	a44636910a50bf5613640b4c80ff3e37
199241	Todo el dinero del mundo	\N	7	2008	\N	T3435	199182	1	58	\N	1d8fa0a5549195fe36c2f329af2b2188
67012	Sole teme por la vida de Ángel	\N	7	2007	\N	S4351	65509	\N	\N	\N	7dbc2c3a438dab3743a21fe7e91a980b
128694	(2002-02-15)	\N	7	2002	\N	\N	128673	\N	\N	\N	59d560f9e0c9b92eef0ae0264f905923
97217	(#2.29)	\N	7	\N	\N	\N	97178	2	29	\N	24a73e31e3c36da3097422fa4c4a7121
41947	The Man Who Loves Snakes	\N	7	1962	\N	M5412	41937	\N	\N	\N	74f013f4c6e7a0cb396cd5371bf0279f
104647	(#1.13832)	\N	7	2010	\N	\N	103385	1	13832	\N	3e4a08706ba3df01b67b21b472e2973c
18852	Nothing Says Lovin' Like Something from the Oven	\N	7	2007	\N	N3524	18706	11	20	\N	44d2319231285d48225ae187128431af
153597	(#2.63)	\N	7	2008	\N	\N	153410	2	63	\N	7bd6643f26b9cf84600dd1ad82cf92c2
17087	The Story of Zed the Hero of Africa	\N	7	\N	\N	S3612	17038	\N	\N	\N	15e83b27beda1dc95afb025b1e816d55
97163	Is It Normal to Have Looked for Love Online?	\N	7	2012	\N	I2356	97158	\N	\N	\N	31ea0320e2d02c3d161b46e2d1cf6f38
161163	(#1.382)	\N	7	2007	\N	\N	161135	1	382	\N	2694ac4a9902afd385aa06fb75279740
189813	Buniyaad	\N	2	1987	\N	B53	\N	\N	\N	1987-1988	397741a58f417fe27adde10e7ad0349b
45102	From Here to Maternity	\N	7	1981	\N	F6563	45093	3	1	\N	e768162ac8f7adbf10080612f7d010ac
2425	Andres Carefully Plans Out How to Tell Sophia the Truth about Her Real Parents	\N	7	2011	\N	A5362	2417	1	70	\N	5ec637a5138aa3b6bb838d965ba1d19e
141140	Adini Vermek Istemeyen Dinleyici	\N	7	2011	\N	A3516	141138	1	27	\N	62c165ad2cb46ad8896daca0ef828c1a
38642	The Last Temptation	\N	7	1992	\N	L2351	38590	4	13	\N	3dd9075db20f13423a432dd76e72bf1e
194455	Lo acusa de farsante	\N	7	2012	\N	A2316	194395	1	19	\N	5999aaf49f78d94abe33bc55052c92b5
131665	College Bass 3: Carhartt	\N	7	2012	\N	C4212	131651	\N	\N	\N	8b19757d8ed9610e31282b6ba712255e
119607	(#3.11)	\N	7	2008	\N	\N	119552	3	11	\N	7a9daddaf2af4a689f76fd5e7e9f4efe
91643	Renishaw Hall	\N	7	\N	\N	R524	91279	25	24	\N	bb92307702d846515536ec7e77001c2d
46397	(2004-08-07)	\N	7	2004	\N	\N	46022	\N	\N	\N	4e68c7593e0f1569aba33f936b6d02bf
110274	Tsutomu no shi	\N	7	1970	\N	T2352	110180	1	53	\N	730183eca8ecd2d421924f58ff86c01a
76938	(#1.9)	\N	7	2005	\N	\N	76786	1	9	\N	6d5a81648c0a79259ac949050a4bf1f2
151933	(#12.14)	\N	7	2010	\N	\N	151798	12	14	\N	b2d038206adfa4a77d536373e2d3f011
190991	(2012-05-30)	\N	7	2012	\N	\N	190979	\N	\N	\N	3e9abcd65aab3f5b933c64fa257f3c28
117688	(#1.1161)	\N	7	\N	\N	\N	117506	1	1161	\N	e100b2ef96c492cc823f38e6d892a3d6
172151	(1996-06-20)	\N	7	1996	\N	\N	172118	\N	\N	\N	6c118f2faa06ad2ae85bd438a0c8c7cd
46262	(2001-06-15)	\N	7	2001	\N	\N	46022	\N	\N	\N	e9e533c0c233b3f3457891aea5b440ce
85684	Livet på en pinne	\N	7	1996	\N	L1315	85670	1	9	\N	a36ee7756fce61386d8c431293a2c862
180390	(2011-08-01)	\N	7	2011	\N	\N	178599	\N	\N	\N	b647672e76711ac23827f5ca3b281a42
64519	(2012-05-08)	\N	7	2012	\N	\N	64458	\N	\N	\N	6653b6b81f189a30aa6fab012983a643
50096	Borrón y cuenta nueva	\N	7	2002	\N	B6525	49991	11	1	\N	2b563da3e8af08ecdfb83ba1025e1503
153397	(2010-08-08)	\N	7	2010	\N	\N	153265	\N	\N	\N	f3b15b1260a0777427d08d7d753e3190
90397	(2006-01-12)	\N	7	2006	\N	\N	87087	\N	\N	\N	27c9c9316f2e4f5061841cdc61dd6440
175856	Pretty in Pink	\N	7	2009	\N	P6351	175829	2	13	\N	97d4a3b60f9249002bda238e5a4e4932
59974	Friday Night Bites	\N	7	2011	\N	F6352	59970	1	4	\N	e8466a835d2e103c64323e19f1bc0d1f
103904	(#1.13086)	\N	7	2007	\N	\N	103385	1	13086	\N	710884d6b42a8385f4dbbf46424214d2
133508	Dazed	\N	7	2012	\N	D23	133491	22	4	\N	a9eb72f5e89877b268c32e6813d742e0
48250	(#1.114)	\N	7	2001	\N	\N	48232	1	114	\N	279d525d62042d8124e9a1f672c236c7
116111	Avatar Day	\N	7	2006	\N	A1363	116109	2	5	\N	b2b7641f916f4469571f916b3f730023
109983	At the Movies	\N	2	1991	\N	A3512	\N	\N	\N	1991-????	d7ab69da97bcbae1d7ca9875c25b24ee
91401	Chichester Cathedral	\N	7	\N	\N	C2362	91279	25	8	\N	4ba947ffa3b73881aeec4c5bd3971173
82087	Rosalie Sees That Jenny Genuinely Loves Angelito and Junjun	\N	7	2012	\N	R2423	81903	1	88	\N	1b174f1b9b280199c7ba1d21043b1804
167777	Beep Beep	\N	7	2010	\N	B1	167764	4	21	\N	10cd1b04b570bb70c029e896b40058f6
181201	The Ballad of Bret Maverick	\N	7	1982	\N	B4316	181193	1	10	\N	b2e64d17a99e3e5ebe6adb01346fa066
16563	The Lobbyist/Roberto Benigni/Choosing Life	\N	7	1999	\N	L1236	15711	31	24	\N	7e68223bb30b423ce3f2f363c83a6cf8
76579	Malas noticias	\N	7	2004	\N	M4253	76496	1	100	\N	abdde5714ff3ff599954e0d47c250e79
155949	(#1.2)	\N	7	1967	\N	\N	155947	1	2	\N	833f07fee87ea4c65730debb8305e592
180111	(2010-09-25)	\N	7	2010	\N	\N	178599	\N	\N	\N	930932de6afb23b056f09e7eff0490c8
64498	(2011-12-01)	\N	7	2011	\N	\N	64458	\N	\N	\N	00db96aa4a010d1cb282e4ba26e7f7e2
88093	(1998-06-22)	\N	7	1998	\N	\N	87087	\N	\N	\N	73532ca18b3fc2470eeb679910024e54
38363	(2008-12-18)	\N	7	2008	\N	\N	38084	\N	\N	\N	7c2a69dcbf497a2e4cc4995b58ed01ab
194400	Amor por Tristán	\N	7	2012	\N	A5616	194395	1	85	\N	2f84a2aef57fb947143a0d491e0fc140
188427	Alan Page	\N	7	2011	\N	A4512	188426	\N	\N	\N	2f41638f1bc2b0f05a4a5429c3e89805
190102	Burianuv den zen s Hilary Binder	\N	7	2008	\N	B6513	190100	1	2	\N	92ce56cbdea0f31ddbcd517f49255bb7
29652	(2004-05-26)	\N	7	2002	\N	\N	29216	\N	\N	\N	1ba76f214f9f73489d348ad768a81051
12098	Balloon Ride!	\N	7	2010	\N	B4563	12089	2	15	\N	2918f353c2ac5dc5c401b3c7d9f008ab
187927	(2012-11-14)	\N	7	2012	\N	\N	187850	\N	\N	\N	8a23c0e9c9037a81842e02515053697d
154457	Oh Brother	\N	7	2001	\N	O1636	154448	2	2	\N	5ded4beababce56022d6f5da884633d7
34323	Abenteuer Auto	\N	2	2000	\N	A1536	\N	\N	\N	2000-????	2c3e5b44e590a7f4eaef6372ee59c14c
45052	Satmaran	\N	7	2001	\N	S3565	45041	1	4	\N	3bc14c491424368a7d1dd0e59959d1f6
44624	The Adventure of the Western Star	\N	7	1990	\N	A3153	44586	2	9	\N	a580d712b461f90ff233dede8f01eade
168353	Le prince	\N	7	1964	\N	P652	168344	\N	\N	\N	a03b2e8d78887e365c86fa6cb95d2883
170534	Mitsuyo Ohta, Izumi Maruoka & Masanobu Takahama	\N	7	2013	\N	M3232	170424	\N	\N	\N	f68825ebc9c7dcef95ffca67ca73b39d
182471	Missionary's Baby	\N	7	2005	\N	M2562	182425	1	32	\N	c6165f71020efb766d6eac146582af8a
11862	Mein fernes Kind - 33 Jahre Schuld und Sehnsucht	\N	7	2005	\N	M5165	11752	\N	\N	\N	792368cf81524a9578dc09e740ab9927
142425	Bellator Fighting Championships 58	\N	7	2011	\N	B4361	142372	5	10	\N	859d85367a18aef3d4b969c50869c122
79240	Mystery of Puma Punku	\N	7	2012	\N	M2361	79207	4	6	\N	1391f3cb383320d88556a0e7332c90b2
78721	(1998-10-06)	\N	7	1998	\N	\N	78428	\N	\N	\N	55b7f829ce35af8fa2ac94f26a952252
85557	Tanya & Andrea: Glamorous Rehearsal Dinner	\N	7	2010	\N	T5362	85533	1	20	\N	5b0d035a33a26b1ef8da925687f5b957
26054	Dead Family Robinson	\N	7	2004	\N	D3154	26051	1	11	\N	d7f6a3bab90588e63fffb133a4f91965
116403	(#1.17)	\N	7	2012	\N	\N	116324	1	17	\N	7b609d430d80941cf4b01c63595f3e61
93922	(1966-05-01)	\N	7	1966	\N	\N	93909	\N	\N	\N	129afb7bc9949cc7240b77e8df285285
142429	Bellator Fighting Championships 61	\N	7	2012	\N	B4361	142372	6	2	\N	26e4bc9896690ef2649de51275896348
84874	(#1.64)	\N	7	2011	\N	\N	84548	1	64	\N	cf46fec542bd4db085f4a5423cca3224
56392	(#1.10616)	\N	7	2011	\N	\N	55774	1	10616	\N	63f9ad5f55a240f136fa1cc0b9f2972b
135231	Waters of the Moon	\N	7	1968	\N	W3621	135113	4	4	\N	ae07995d3cb749f7b8cc6bef16480995
184699	Individualism	\N	7	1983	\N	I5313	184043	1	21	\N	72a7393974cd245d234679713582ccd9
125464	Vynález století	\N	7	1984	\N	V5423	125458	1	1	\N	b7193e28bf22ecc2d440c8723e5377a2
35331	Acampamento de Férias 3	\N	2	2012	\N	A2515	\N	\N	\N	2012-????	79a83fe17f133212574e3748db635d59
25634	Seared Pork Tenderloin	\N	7	2007	\N	S6316	25600	1	8	\N	b84a5784d74c0471dc8350b2324c6222
194183	Cabin Fever	\N	2	2003	\N	C1516	\N	\N	\N	2003-????	03463a805c67f5bd77b0b22e180a23fc
186098	(#1.12)	\N	7	1994	\N	\N	186094	1	12	\N	7747e386416856b04b17ae027b8e5e3d
9303	The Hellion	\N	7	1959	\N	H45	9246	2	16	\N	e450063e62c93e8dd60e4dc65294f562
73520	War and Pieces	\N	7	2000	\N	W6531	73510	1	12	\N	97f42cfcad8e8b8c430fdc0d11fa7b83
93861	Era uma Vez um Caos	\N	7	2008	\N	E6512	93840	2	6	\N	95be933d70dd2b3ce51e6ceca624a042
73875	Auditions: Dallas	\N	7	2008	\N	A3523	73710	7	2	\N	8a36e82e3f6193b8ca971c90d501cda3
163726	Strict Order! The Forbidden Rescue of Orihime Inoue	\N	7	2007	\N	S3623	163436	7	11	\N	f57fd9bd1233624a4e615539ce7c94da
176398	The Category of Happiness	\N	7	2000	\N	C3261	176388	1	9	\N	db0f59dd720e90e8989fb65d861f8a55
89017	(2001-01-17)	\N	7	2001	\N	\N	87087	\N	\N	\N	c2af96148922cf9a5cc36ff50327749b
51332	(#2.5)	\N	7	2009	\N	\N	51316	2	5	\N	5701d0480a882598a21998dbedce2afc
107962	American History: Marching Into the Future	\N	7	2007	\N	A5625	107959	\N	\N	\N	cc2d14f437d4834bd87bb7d31cd3ad60
151173	Big Band Showcase	\N	2	\N	\N	B2153	\N	\N	\N	????	420abd619307ded7ed0842b367cc5897
195884	(2010-06-06)	\N	7	2010	\N	\N	195563	\N	\N	\N	869f597060163b478dfc7bf52aaa1b09
146923	(#2.9)	\N	7	2008	\N	\N	146843	2	9	\N	d6fa2b1d6e444acae7e67c913be9990e
52795	(2003-08-26)	\N	7	2003	\N	\N	52785	\N	\N	\N	c7146d3c9684b61e90826596d63933ed
189974	(#1.6)	\N	7	2000	\N	\N	189966	1	6	\N	2b97f31e49e4cea3da14e1d1292915d2
64634	(1979-05-26)	\N	7	1979	\N	\N	64592	\N	\N	\N	f3f13935ab40412d8e72ff96395a4148
25839	(1993-01-05)	\N	7	1993	\N	\N	25837	\N	\N	\N	12c8d3d0462978b762cc23afbe517e79
86257	The Legend of the Bad Fish	\N	7	1988	\N	L2531	86247	1	5	\N	05ab7ded02e9efd4ac8e0ba7c4d75ed9
15051	(#4.23)	\N	7	2011	\N	\N	14924	4	23	\N	1247ba279aa98530335aed0e93c369c6
41025	Phil	\N	7	2012	\N	P4	41013	2	6	\N	185ae4ba17091d43fd7e5793b4596a73
43842	(2012-12-18)	\N	7	2012	\N	\N	43320	\N	\N	\N	4d815c682907d2d10e2e4382345dab7c
164063	Alicia	\N	7	2006	\N	A42	164050	\N	\N	\N	d389cf4c55ab63614a7ed6c8a846fd6d
45661	(#1.129)	\N	7	1997	\N	\N	45627	1	129	\N	f6bdee14192536165b312a7a28370880
177422	Less Than Hero	\N	7	2004	\N	L2356	177390	1	18	\N	86c0d3e100d752b8b608e3c94818d11a
186287	(#2.17)	\N	7	2012	\N	\N	186266	2	17	\N	9afcc6f415c39e21b26de721b8248a01
30642	Ryan and Brian	\N	7	\N	\N	R5316	30638	\N	\N	\N	3e03da4296d2dfe71e18361997c1d716
71213	(2012-10-11)	\N	7	2012	\N	\N	71033	\N	\N	\N	d1263cb2b3647814fcc86058398e7950
68728	Presidential Estates	\N	7	1997	\N	P6235	68692	\N	\N	\N	a5dd5bcb1c6fef2a4ec1da6ec6286a3e
40307	Jail	\N	7	2011	\N	J4	40242	1	20	\N	8d4ed0548e9531f1cfb5d1be86da07c6
21926	Warning Signs: Part 2	\N	7	1983	\N	W6525	20918	3	30	\N	7364cd96ef5be68e83ca697d52c14bbe
105022	(2000-06-21)	\N	7	2000	\N	\N	103385	\N	\N	\N	4bc87cdf371646b888e5ee2ca827374d
156679	(#1.1)	\N	7	2010	\N	\N	156678	1	1	\N	b09be7891bf73a4a949ade921e68824a
68161	Operation Homecoming: Writing the Wartime Experience	\N	7	2007	\N	O1635	68151	1	3	\N	a1b7d00a2725df540c61cd761cbca62d
142178	(#1.73)	\N	7	2008	\N	\N	142028	1	73	\N	04270f0043026c6274711a9ee01dd70a
137564	Read My Book	\N	7	\N	\N	R3512	137496	3	23	\N	c8ab3d544fc97e2ae042fa1859b845ac
136167	Prudential World Cup 1979 Final: England vs West Indies	\N	7	1979	\N	P6353	136152	\N	\N	\N	049d0d431f2167df20bc670c8b7aa1d8
131164	Tu ne te vengeras point	\N	7	1995	\N	T5315	131163	\N	\N	\N	e7d66a07ae5016c40f54e73af940134f
56273	(#1.10497)	\N	7	2010	\N	\N	55774	1	10497	\N	6c1652b974786b75ac1d177224bd4cf7
135174	Romeo and Juliet	\N	7	1967	\N	R5324	135113	3	3	\N	f6e213b9797a28f89baeed7608ff3492
128726	(1999-03-16)	\N	7	1999	\N	\N	128714	\N	\N	\N	a4db9993b9a4881abca264a62cdb0ab0
56952	(#1.8521)	\N	7	2003	\N	\N	55774	1	8521	\N	70229d16d6fc5d82cfefa31c351bef47
12792	Benjamin Dalatu	\N	7	2011	\N	B5253	12781	3	6	\N	96bd3d34d48c1d8d786a7ba9c76abd09
185582	Snoop Returns	\N	7	2009	\N	S5163	185571	1	10	\N	41076f66dadb944d8ec1fcefdf8c5a74
3083	1001 gece	\N	2	2006	\N	G2	\N	\N	\N	2006-????	6ab41cfa8b16d0f93564b2d5b2e13ae8
89986	(2004-05-14)	\N	7	2004	\N	\N	87087	\N	\N	\N	fbb4921d70c631c98e10304ad8aafe2b
66707	Mario visita a Andrea	\N	7	2005	\N	M6123	65509	1	21	\N	05c4a5bc6bcfc6989c52835e3cf5e0d8
28606	(1995-03-16)	\N	7	1995	\N	\N	28531	\N	\N	\N	ace0fcf06aa2d0f1010c1f72f5693975
7034	(2001-04-26)	\N	7	2001	\N	\N	6845	\N	\N	\N	b5773a56b3c21479ceada92cb3840612
161892	The Sea	\N	7	2006	\N	S	161881	1	11	\N	b2d1c40dae0953cf1421b79f9bb90fa3
187093	(2005-11-23)	\N	7	2005	\N	\N	187057	\N	\N	\N	32ce98b80f02c0d7b8bce4794739ab39
192415	Carmen et moi	\N	7	2006	\N	C6535	192412	2	24	\N	9024bd34cd9098be3a38d14c80cd75fc
120967	Baby an Bord	\N	2	1997	\N	B1516	\N	\N	\N	1997-????	16626eccf783882bc72b59a6df77c73c
148188	Coming Out, Getting Out, Going Out	\N	7	1996	\N	C5232	148136	6	24	\N	4d23dabcf24ecb7cf161dcfcec885db4
69595	(#4.20)	\N	7	1993	\N	\N	69220	4	20	\N	35d097ad9b563be9e6a9b33cd63d1aac
98872	De familie Terlaet	\N	7	1982	\N	F5436	98870	1	1	\N	35e29846d364d9ff280e20ee0feea322
6072	(#1.2)	\N	7	1992	\N	\N	6070	1	2	\N	9b6e28f02451ce9d94b46e57343c5147
119570	(#1.25)	\N	7	2006	\N	\N	119552	1	25	\N	3fdb06d087a7660389877df5c3f312d2
98484	Mug's Game	\N	7	1964	\N	M25	98326	4	97	\N	549ed0914abacf25646d6ba6338028cd
165450	Dogfish Head	\N	7	\N	\N	D2123	165443	1	8	\N	f99fdef3665a1422b0a04da1974ff3ba
126494	(#22.22)	\N	7	1979	\N	\N	126283	22	22	\N	482bff6c61206c18461d31d31bbfdd71
2723	1941 - Das 'Unternehmen Barbarossa'	\N	7	1999	\N	D2536	2685	5	3	\N	57e791cd28bc44072c5c27f2c4726286
20028	(2008-02-29)	\N	7	2007	\N	\N	19968	\N	\N	\N	753f56aecb10b0b6ec4f2c96769d1991
157266	Aussie Icons	\N	7	2007	\N	A252	157261	\N	\N	\N	197a6411bb39a127544970bc204d1f87
101058	The Annual Porn Pilgrimage	\N	7	2010	\N	A5416	100979	6	2	\N	311c7171eac7c6022e1d9de161e86b1c
11012	Fout in '45	\N	7	1995	\N	F35	11005	1	3	\N	4eb29985f51f63dc6b90d2a4df8a23ba
197085	Dogtown	\N	7	2009	\N	D235	197071	3	10	\N	57aa0c4081a0cd5d76f4f8206ea79b7c
55217	If You Can't Beat Them	\N	7	1989	\N	I1253	55207	1	3	\N	4b76c571155d419c15765263849e794a
81462	Happy Anniversary	\N	7	2001	\N	H1516	81426	2	13	\N	185f0778cdd6c830300e7b99790e1b3d
114155	Lynyrd Skynyrd	\N	7	2000	\N	L5632	113993	25	6	\N	edbd17769d459038afafa601d6daad6b
82009	Jenny Has to Deal with Her Problems Before She Could Marry Paeng	\N	7	2012	\N	J5234	81903	2	22	\N	bfed18f166695348a431c11010f59a95
110200	Himerareta mono	\N	7	1970	\N	H5635	110180	1	23	\N	7a558fc3349e1c0032cfb7db9e91d8ee
32515	(2009-12-30)	\N	7	2009	\N	\N	32442	\N	\N	\N	54d63cd7638271c4bf7399a535598ec7
187330	(2009-02-17)	\N	7	2009	\N	\N	187057	\N	\N	\N	d9424a767b6ef251d8201daf4b9301f0
122836	Naked & Dangerous	\N	7	2012	\N	N2352	122803	3	2	\N	266a61cb05462c75cd64f5e87a042050
145865	Liebe auf den ersten Blick	\N	7	\N	\N	L1356	145764	2	28	\N	3bf35d22d97029355d5397cd8c295cc5
30577	Sombras	\N	7	2006	\N	S5162	30505	1	21	\N	a46bcc42dded23a296589f17f57e2d87
118851	(#1.909)	\N	7	\N	\N	\N	117506	1	909	\N	62fe0ba224f4239157f99f409c29761a
69421	(#18.9)	\N	7	2007	\N	\N	69220	18	9	\N	c17f17d5dbfa74b3f534edbd1f834698
178161	Breakaway	\N	2	1983	\N	B62	\N	\N	\N	1983-????	82a14ebf9818e9bced7a0830d0cb2234
179243	(2007-10-09)	\N	7	2007	\N	\N	178599	\N	\N	\N	7943156eeb938e450ccedeeb30c3e9df
172239	Seems Like Old Toons	\N	7	1993	\N	S5242	172198	1	58	\N	a8ec092f3ddc77a0a53e250d94474aa2
184179	(#1.2265)	\N	7	\N	\N	\N	184043	1	2265	\N	f5d83eeb869b1af8207a6a84b381cfc1
320	Missing and Presumed Dead	\N	7	1992	\N	M2525	284	9	2	\N	548e5619a9e5087b9fbe86ab3488808c
7047	(2001-08-30)	\N	7	2001	\N	\N	6845	\N	\N	\N	d4923c91529b97e409f8c59c01303d9f
59104	Season of Change	\N	7	2005	\N	S2512	58754	8	40	\N	6d610a0d9ed5d16c5411b6553b03bb2d
135316	Prom 42: Shostakovich's Fifth Symphony	\N	7	2010	\N	P6523	135301	1	15	\N	eedb8aa3ff93ed343a835c0ec551d4f9
35391	Killer in a Rose Colored Mask	\N	7	1961	\N	K4656	35385	1	2	\N	d43e4097a90cf81d3bf497bc495a35a0
54169	Alguna vez, algún día	\N	2	1976	\N	A4251	\N	\N	\N	1976-????	b6225c381642838fbf153c2983d462f8
103407	(#1.10553)	\N	7	1997	\N	\N	103385	1	10553	\N	92aca0742bcc88a64ff5abae67bfbe3a
196847	Big Things in the Desert	\N	7	\N	\N	B2352	196812	\N	\N	\N	0d2a07e35bd92f5756d47d457e269ee0
156946	Bunter Goes to Nice	\N	7	1961	\N	B5362	156931	7	9	\N	808e11a08ce4455a0edb5d5f5e3fd4ec
198620	Calling All Cooks	\N	2	2000	\N	C4524	\N	\N	\N	2000-????	aa8d518d4ea537800e8bd5e96517efaf
78519	(1997-03-18)	\N	7	1997	\N	\N	78428	\N	\N	\N	d8c674b01be65b25ed3fd119d39afa9f
139780	Plasticine	\N	7	2012	\N	P4232	139778	1	2	\N	764b32f0d628afc5e398594d6dee4c7f
114295	Willie Nelson	\N	7	1990	\N	W4542	113993	\N	\N	\N	5281deb9c0ef47d0313dc047930381d9
45546	(2006-12-16)	\N	7	2006	\N	\N	45248	\N	\N	\N	911f6f738c03c861052ff4cacfdcf1b4
103146	(2007-06-28)	\N	7	2007	\N	\N	103140	\N	\N	\N	75b7f53a405aab15d43420f7d039ed4e
73991	Live Results Show: One Contestant Eliminated	\N	7	2009	\N	L1624	73710	8	28	\N	7e7f25fded4fd06dc2832b28dbb1ce39
87058	City of Doral	\N	7	2013	\N	C3136	87049	\N	\N	\N	116e9f2a02ab0f417864289441511304
160283	(#1.19)	\N	7	2004	\N	\N	160272	1	19	\N	07440fdfdcbeafd67bd56d6dd722c8ab
68833	Customer Service Please/A Friend in Need	\N	7	2011	\N	C2356	68757	1	125	\N	07a86c7571cb0241a4c997795b8d22d9
192056	Women's Volleyball: Brigham Young vs UNLV	\N	7	2008	\N	W5214	191994	\N	\N	\N	e3504e7d137df25261d97e27d3b4b6dc
9189	(#1.63)	\N	7	2002	\N	\N	9188	1	63	\N	4acc41248f85fc5e1a991b84f710e5cf
138113	(#1.35)	\N	7	1968	\N	\N	138084	1	35	\N	4c2d648702c9e2d2b0cebc4b97c1f121
42982	Wilde Katzen	\N	7	1991	\N	W4323	42975	1	6	\N	19132b065b9b5489eda0bb472234dc8e
23399	(#1.86)	\N	7	2008	\N	\N	23216	1	86	\N	3ab4d5d2dbf1f0e55f5848203b548b41
101316	(#12.23)	\N	7	2006	\N	\N	101221	12	23	\N	7d75cf497e032af1b7a1e21ff89a89dc
161112	Queensland	\N	7	2011	\N	Q5245	161105	\N	\N	\N	10124102d49a24415bbc9839a395e757
124338	Final Countdown	\N	7	2009	\N	F5425	124313	2	25	\N	49764657604dfc3c853c95e836e51b8a
42313	Baby Sitter Jitters	\N	7	1993	\N	B1236	42311	1	49	\N	00c7c64da19736b9c6be407c18219e56
187126	(2007-01-09)	\N	7	2007	\N	\N	187057	\N	\N	\N	cd9abd48f786a87d879a024d98939157
132025	Bathroom for Three	\N	7	2012	\N	B3651	132012	4	11	\N	ba4c1ad8533999c908337f33212e0373
157966	(#40.1)	\N	7	2011	\N	\N	157571	40	1	\N	82c85131b96b2d034a026f5a57dff515
61236	Angels and Blimps	\N	7	1999	\N	A5242	61231	2	13	\N	d276f3eb9a2db7f41b6f2f6fb22f530a
77466	Cena de presentación	\N	7	2013	\N	C5316	77426	1	154	\N	267c65ed6c7dbc0d831f0387d356a952
138256	(2006-11-06)	\N	7	2006	\N	\N	138209	\N	\N	\N	19ff3a7c82ef16fa967a62bfdad7889c
144207	The Company You Keep	\N	7	1984	\N	C5152	144146	3	8	\N	1b02dea0005164e930c5d0ade7af7e95
84718	(#1.251)	\N	7	2011	\N	\N	84548	1	251	\N	a7f557c7ed0253a92977034ab800960b
191539	Yes, No, Maybe So	\N	7	2008	\N	Y2512	191513	1	7	\N	fbf6149afc65bdcf7b16e375b0e1ec70
172862	Bradford Martin	\N	7	2011	\N	B6316	172759	\N	\N	\N	7ad88b1e47fd64b09be73d9076f90664
62717	Liebesschmerz	\N	7	1998	\N	L1256	62633	3	23	\N	ae68fa29b3f6e4474d8d833b2205d19d
39150	ActorsE Chat with Dallas Malloy and Ric Drasin	\N	7	2013	\N	A2362	39009	5	66	\N	e9e658b8e2444b50c98c2c1358e0f4be
93107	(1981-03-07)	\N	7	1981	\N	\N	93031	\N	\N	\N	e3ea92dd0f9ad213bb5e432f707a0514
43396	(2009-05-26)	\N	7	2009	\N	\N	43320	\N	\N	\N	290a30d407a71192ba1772dc762b39af
141837	(#1.12)	\N	7	2007	\N	\N	141833	1	12	\N	f481ec805fe86e3111397c0ebb5c76b2
40623	(#1.11)	\N	7	1972	\N	\N	40620	1	11	\N	4940cfa0f09d8394d8225bfe1232b324
138324	Ritz Carlton Residences	\N	7	2013	\N	R3264	138209	11	18	\N	21c8505819884e11dfcb775ad65040fd
120133	Presumed Dead	\N	7	1976	\N	P6253	120115	1	5	\N	30af8097bb2cfeb5a670e9432fa6a30e
194417	Chava quiere ser Cachito	\N	7	2012	\N	C1262	194395	1	107	\N	ffa8b9c83b84bbd7f3fff88aef6adfef
75728	(2007-12-01)	\N	7	2007	\N	\N	75628	\N	\N	\N	caa5f84942ff35e134fdb9f53a89bfaf
78355	El gran día	\N	7	2004	\N	G653	78333	3	20	\N	20717a71fa68f64a4047c0333cb72029
48641	(#1.25)	\N	7	\N	\N	\N	48623	1	25	\N	8e4bafb2e0b9307690e84334dbb47a32
98837	The Victim: Part 6	\N	7	1980	\N	V2351	98776	3	6	\N	194bf2933b3d1dfb8721a30d3dccb96c
49026	Tenkôsei, daikangei!	\N	7	2009	\N	T5232	49014	1	7	\N	f28e21b51953ec26b226c328f6b4c76e
48704	(#1.129)	\N	7	1963	\N	\N	48670	1	129	\N	dc5bfa280fe87407e7fb5156ae7f46f2
99542	Space Tourism	\N	7	2001	\N	S1236	99529	1	1	\N	5d81919cf4f528a1ebb85ec87ed054cc
72069	Fluids	\N	7	2007	\N	F432	72068	1	4	\N	67c9dbc06b87a6208638c2585969eea5
109479	(2001-11-21)	\N	7	2001	\N	\N	108733	\N	\N	\N	2012b8cf01432c5bb1049548045c791e
133816	Stone Cold	\N	7	2000	\N	S3524	133643	11	5	\N	f812f7ea6a08671e88aa4c6270a3037c
18510	Framework for a Badge	\N	7	1962	\N	F6562	18466	4	37	\N	671c48a24a7a08a8ade1ced63d4b6522
89133	(2001-05-13)	\N	7	2001	\N	\N	87087	\N	\N	\N	2f6321a609c6031f15d9a424a4e17515
22285	Aquele do Papagaio	\N	7	2006	\N	A2431	22239	3	9	\N	ab3c6755e4fad6aaabcee0b63d9bcb78
183355	I Still Call Australia Home... Oh	\N	7	2006	\N	S3424	183343	3	6	\N	ff8cde73db19340447e110e742b1e029
161757	(#1.10)	\N	7	2007	\N	\N	161755	1	10	\N	d737752e6b1398d3e0beb497817b2329
65440	Capitulo 23	\N	7	2001	\N	C134	65424	1	23	\N	4b7399532da32a6c0635854a5b7daa7b
199974	(#1.56)	\N	7	2009	\N	\N	199897	1	56	\N	8189718bde734443fed5f7bd4451a372
189916	(#1.9)	\N	7	2008	\N	\N	189905	1	9	\N	14d86ab92855951a5f3917220f9754a6
27873	Ronnie Scrote	\N	7	1990	\N	R5263	27869	1	4	\N	8c3638f7ccc68bd232248a96432d5fce
70040	Tampa Bay Auditions: Part 2	\N	7	2012	\N	T5135	69890	7	9	\N	f33764d220d1f02be850001f1f764d57
7102	(2002-11-14)	\N	7	2002	\N	\N	6845	\N	\N	\N	e0dedd304cdf352fa2fcf55389c4914d
23030	(#1.83)	\N	7	2005	\N	\N	22880	1	83	\N	faa4ccfe43f8746f72af69888b7206c8
47	The Followup	\N	7	2013	\N	F41	44	1	4	\N	b11754fab9d56c798325f80960e4f989
6284	Wählt Frau Heinrich	\N	7	2012	\N	W4316	6239	3	9	\N	0832a2f560fb774abc727dadf073d01e
26149	Seann William Scott 2	\N	7	2012	\N	S5452	26109	\N	\N	\N	025e0f918581383c26a2b6f1b614553e
128876	(2000-05-09)	\N	7	2000	\N	\N	128714	\N	\N	\N	a39c2d3a7dd9c9b7412a20de3a408d84
126384	(#16.12)	\N	7	1973	\N	\N	126283	16	12	\N	0f191e8276662d969eac41775c8ff3e9
183580	Brobyggerne	\N	2	1991	\N	B6126	\N	\N	\N	1991-1998	ba115737564d70019599c6a10cf8ccc0
18673	7live	\N	2	2011	\N	L1	\N	\N	\N	2011-????	435dc9ee014e6f6b899f2e1265ffab4e
127084	(2006-01-11)	\N	7	2006	\N	\N	126998	\N	\N	\N	7f5ab44dc076fde72a71dda46dabc5f1
110047	Nobu Matsuhisa	\N	7	2009	\N	N1532	110022	\N	\N	\N	60e53fe22b4a7202fc0f60c5de46f624
30957	A Word from Our Sponsors	\N	2	2011	\N	W6316	\N	\N	\N	2011-????	6cebfb9b209784bd2044d6c5d7c4d726
36748	(2012-05-05)	\N	7	2012	\N	\N	36138	\N	\N	\N	edc0345471937c9cefd92a8287d88b5f
131594	Een leuk Spaans dorp	\N	7	1979	\N	L2152	131589	1	7	\N	0f8c974088c54f96af6b02a8fcc93086
50365	El rey del cóctel	\N	7	1999	\N	R3423	49991	2	202	\N	8c9e325655c589deba5866f9ca860563
963	.hack//Tasogare no udewa densetsu	\N	2	2003	\N	H2326	\N	\N	\N	2003-????	7962083515704aa4dc7d3e91ed68ce42
108473	(#1.25)	\N	7	1999	\N	\N	108405	1	25	\N	9f1ceb5abb64143b58dc37ba03a0d5ef
6513	Pets	\N	7	2009	\N	P32	6438	1	30	\N	ee750a0b276a38adf3436a8150979af3
73197	Second Half Preliminary Round 1: Clark vs. Jackson/Odita vs. Ferguson	\N	7	1993	\N	S2534	73091	6	12	\N	949991ff0435a2f8f2caddfc2cb05422
144102	Beretninger fra Økoland	\N	2	2000	\N	B6352	\N	\N	\N	2000-2003	db7812c584fe6a7bf50c83734d62be24
82250	The New Boy	\N	7	2009	\N	N1	82204	2	25	\N	f6d21d0212291cbebac27e2de91809d2
105755	(2006-04-14)	\N	7	2006	\N	\N	103385	\N	\N	\N	eb810749fff548efd18d868e9634f8e5
26158	Decapod Crustaceans	\N	7	2012	\N	D2132	26157	1	3	\N	5c80c7ffb201acaf7e4c8276ed25ccdf
129280	(2003-11-06)	\N	7	2003	\N	\N	128714	\N	\N	\N	5eaf21c3e302c5f6d3a48612039b1bd2
145157	Late Again	\N	7	2004	\N	L325	145131	6	12	\N	5a7d060293e9aebd42c7778863ed97de
151120	Raiders of the Tomb	\N	7	1996	\N	R3621	151087	1	30	\N	30be5671ae9e395617f89fab4e4a6178
11318	Annie Jade	\N	7	\N	\N	A523	11299	2	7	\N	6e229d6376b65c4e90244bc81e1a4d7e
198790	(#1.149)	\N	7	2010	\N	\N	198734	1	149	\N	9821fb240e2d16ab0dcf0b3ebf44db26
111053	Geek Love	\N	7	2001	\N	G241	111044	2	6	\N	a9e08f7c26aa7ee333979a7709da861a
17669	(1984-11-04)	\N	7	1984	\N	\N	17625	\N	\N	\N	ec901e77097b32345512ffed33b17640
63988	(2010-04-09)	\N	7	2010	\N	\N	63983	\N	\N	\N	0f95b8ecd807c9e10b5181ffab8b6bf7
25133	(#1.27)	\N	7	1999	\N	\N	25062	1	27	\N	925e2efd9f4e95b80edbbbf38759938e
82257	(#5.10)	\N	7	1979	\N	\N	82255	5	10	\N	c5802b2feecc1d783f14bda92899a50c
185998	(#5.7)	\N	7	1991	\N	\N	185959	5	7	\N	30cf5886a966d4da1f1dd159ded20efd
33954	General Eisenhower on the Military Churchill	\N	7	1967	\N	G5642	33947	1	16	\N	0079ad412642399647b862bb4e286ed0
87479	(1995-08-02)	\N	7	1995	\N	\N	87087	\N	\N	\N	083811267d53d30120b364dc14e809f9
83199	(#2.9)	\N	7	2007	\N	\N	83167	2	9	\N	56f3d689d80b2d0fc9a243842b4ff9e8
152240	(#9.15)	\N	7	2008	\N	\N	151798	9	15	\N	2a6b17a05e2c6d01c50168772972d929
39361	ActorsE Chat with Larry Hankin and Cerris Morgan-Moyer	\N	7	2012	\N	A2362	39009	4	72	\N	32e72d7ced2b4e07439c24a4c6fcc604
118188	(#1.311)	\N	7	\N	\N	\N	117506	1	311	\N	fe951b7ba3f751f8d976246dbb2cb89e
145083	Baseball	\N	7	\N	\N	B214	145076	\N	\N	\N	2d04164df6823ea250aba18bf67eac5a
49927	(2007-04-13)	\N	7	2007	\N	\N	49889	\N	\N	\N	8ea18429c73df38701aa8b62d7a9eb8b
93315	A Man from Ginger Nell's Past	\N	7	1978	\N	M5165	93314	1	6	\N	62cde8efb01f9c4656d2c47dcca4aa2c
183670	Holden at Love	\N	7	2012	\N	H4353	183664	1	5	\N	0355df41089af87017c4a6455c27cff1
34295	Ein Sommer der Liebe	\N	7	2005	\N	S5636	34290	1	13	\N	d6ac3c3ebc39baa18e02a06836253c95
39635	ActorsE Chat: Jay Matsueda/Greg Swiller/Kristina Nikols	\N	7	2010	\N	A2362	39009	2	164	\N	88517124096b4ede467c2fd2e45141e3
122788	Trouble with Tumbling Tiles	\N	7	2006	\N	T6143	122773	1	11	\N	4a428342d3a160068ec36e1232d8fcb8
128741	(1999-04-08)	\N	7	1999	\N	\N	128714	\N	\N	\N	9e83b21dea19e68fc887d08c34608af5
76658	(#1.11)	\N	7	2011	\N	\N	76655	1	11	\N	7c4fbb480dc955e89ff739302b91c77f
47147	(#1.12)	\N	7	2004	\N	\N	47143	1	12	\N	bec2ce2afef692090c1bb72a0e71386b
78151	(#3.26)	\N	7	2007	\N	\N	78132	3	26	\N	b2b9a0a6240a4a685c405f76aaff8b2e
12305	(1990-03-16)	\N	7	1990	\N	\N	12300	\N	\N	\N	19d0abf41d73931b450e851e1696dfc1
180319	(2011-05-22)	\N	7	2011	\N	\N	178599	\N	\N	\N	ba7b27fedfb23d4bf6340f3952416b1a
196285	Donkeys and Dollars	\N	7	2012	\N	D5253	196265	1	1	\N	e3853636de489a19feab23ef11de0d0a
106041	(#1.1)	\N	7	2007	\N	\N	106040	1	1	\N	9d9c8980046b2d2b3b9c435950ceb0ae
186544	Buccaneers and Bones	\N	2	2010	\N	B2562	\N	\N	\N	2010-????	5a66f975ecff286c2a6914c8e1cdf50e
189441	Macke naopacke	\N	7	2005	\N	M2512	189425	1	24	\N	cbe1e7dc9fa39714ab2c113fa3a8be1c
86142	Unsere armen Abgeordneten - Überlastet und unterbezahlt?	\N	7	2007	\N	U5265	86014	1	9	\N	26cf39df15fea9c822b12b521f237a85
157939	(#38.22)	\N	7	2010	\N	\N	157571	38	22	\N	eeccf7d15f37850891cbed4c10146fe0
78552	(1997-08-05)	\N	7	1997	\N	\N	78428	\N	\N	\N	2040881703d2d545eb35816c81c4e4c1
42152	Castaways	\N	7	1960	\N	C232	42137	1	13	\N	cd1bee0f36d58beec7586475d16b5cd9
196563	(2012-07-28)	\N	7	2012	\N	\N	196548	\N	\N	\N	bb26e8eac3e45409f719bd192d231e26
4340	De zangwedstrijd (Amersfoort)	\N	7	1990	\N	Z5232	4316	\N	\N	\N	ff180cfd88127ca7aa24de4f6d794e31
79986	(2011-07-29)	\N	7	2011	\N	\N	79712	\N	\N	\N	a561113920435fea0594de2aa6c40af2
87644	(1996-01-26)	\N	7	1996	\N	\N	87087	\N	\N	\N	74ce99e2bdb7508f2ac612bee77608be
178393	(2001-08-19)	\N	7	2001	\N	\N	178355	\N	\N	\N	91ed85fe49747eac1261686d25c555d7
12658	When Love Dies	\N	7	1990	\N	W5413	12639	1	9	\N	086599562627c037ea700023bfb71f5c
84360	Durarara Review	\N	7	2012	\N	D61	84358	1	2	\N	c0dcdd975689aa50bd0343377c7e89f1
115867	(#1.26)	\N	7	2010	\N	\N	115848	1	26	\N	e85e3129cc6e66a5c781617605ea27ae
76806	(#1.116)	\N	7	2005	\N	\N	76786	1	116	\N	c9a8eb286eef2cf2ec05159eaf806ced
183809	Shadow of Jesse James	\N	7	1960	\N	S3125	183770	2	9	\N	d2cfec9fa903beebaf28a3b9b67d09a6
177451	The Monkey's Paw	\N	7	2004	\N	M521	177390	1	22	\N	0d1afcb0c422799c12195991b57b9df1
44012	After Judgment	\N	2	2008	\N	A1362	\N	\N	\N	2008-????	8f6be96afe4d50014505aeadd2c6cbfc
121979	Best of BackStage	\N	7	\N	\N	B2312	121977	7	9	\N	e008d3d3da2547e4359d394e980f85d9
121790	(2004-02-16)	\N	7	2004	\N	\N	121788	\N	\N	\N	ebb6920bd2c2d3478f2c0bfd25cac0b1
94722	(2001-02-12)	\N	7	2001	\N	\N	94664	\N	\N	\N	9c2a43e6921831045d6652a5c0e7ea50
107553	(#1.13)	\N	7	\N	\N	\N	107548	1	13	\N	4f86b3f6220584a7d751b6d6a96f4fc8
142099	(#1.163)	\N	7	2008	\N	\N	142028	1	163	\N	dfcdb49122b15aa28c2dd6d5b8147665
64920	Sasowanaideyo!!	\N	7	2006	\N	S253	64910	1	1	\N	d577b8fce9e95926a0f815046405e8b3
86833	(1989-05-18)	\N	7	1989	\N	\N	86671	\N	\N	\N	e07cb5a750cc8ef2d63cb5e1b314c973
169672	(1984-10-16)	\N	7	1984	\N	\N	169549	\N	\N	\N	276fd2792a6b2b2f24c17aa2a381aa1c
162948	Get Ready, Freddie	\N	7	2010	\N	G3631	162947	1	3	\N	523db348919d8636e25cd45af38a5d51
85767	Under anklage del 1 - Skuddet	\N	7	2008	\N	U5365	85744	3	9	\N	5ecb02b9bb056949e743c9aedb9902ba
46269	(2001-06-26)	\N	7	2001	\N	\N	46022	\N	\N	\N	f5638bce63d6bd100a568cca1851261d
50774	No te pases de la raya	\N	7	1997	\N	N3123	49991	1	74	\N	5be373bb5f268660bc3a663e0ce4818b
193400	Raaz 25 Saal Purani Laash Ka	\N	7	2012	\N	R2416	192964	1	804	\N	93f72a9539c59714737d6e36fa9fd8bc
128524	Girls Day Off	\N	7	2006	\N	G6423	128428	7	3	\N	69962f39ee131657cae7632039cff21e
158380	(2000-04-01)	\N	7	2000	\N	\N	157571	\N	\N	\N	aa23897fd6f5be2a26dacbcf1cc523c1
49865	(2008-03-14)	\N	7	2008	\N	\N	49809	\N	\N	\N	67dcf1bf8ce50fca84e89585936e7fc6
76727	Confesiones	\N	7	2006	\N	C5125	76719	1	37	\N	6d4d52701a32289f03da73fd259ed018
180436	(2011-09-16)	\N	7	2011	\N	\N	178599	\N	\N	\N	51e4250743be7a477a50d858a944cb03
105634	(2005-10-03)	\N	7	2005	\N	\N	103385	\N	\N	\N	5cf67375fedb882d10fd437bebf60ce2
25010	Shortstop	\N	7	1993	\N	S6323	25006	1	4	\N	f8afbea69898ad8ff9bed3ca6835ca10
172717	Book Club Reads...'Stars in the Darkness' by Barbara Joosse	\N	7	2012	\N	B2416	172708	1	8	\N	eb25214e9265b3eefa315c5925bb0a8d
92335	The Legend of Rosie Ruiz	\N	7	\N	\N	L2531	92323	\N	\N	\N	ccf363207d4c3a167b718c4e83d26835
120523	(#1.40)	\N	7	2009	\N	\N	120488	1	40	\N	4b323c7acb03da042dc0d8982bc04cef
115107	Heaven Sent	\N	7	2010	\N	H1525	114979	15	19	\N	995f254bdc52b6bb5fc5f7dfe6e9e9da
64893	(#1.87)	\N	7	\N	\N	\N	64750	1	87	\N	d2db98dfe0662294cfb25428acc83809
154621	Jill Scott/Jakob Dylan	\N	7	2012	\N	J4232	154463	6	4	\N	92928d029620a03b899431ca0f514dff
89408	(2002-02-22)	\N	7	2002	\N	\N	87087	\N	\N	\N	51f0084395d13c97a57301643345c7fb
80699	(#1.166)	\N	7	2010	\N	\N	80624	1	166	\N	91dfed285311cebc3136056b9025553a
55075	Cumings and Goings	\N	7	2009	\N	C5253	55073	1	3	\N	d9badc77cea8709ab237ff44aceef8f4
128117	Willa na przedmiesciu	\N	7	\N	\N	W4516	128111	1	7	\N	47e0714a9e5a7bf4f74b80ec998a259e
193445	Raaz Qatil Auzar Ka	\N	7	2012	\N	R2342	192964	1	852	\N	0d367a3bc4005211fff3c8a72ebb2429
8991	Day 8: 12:00 p.m.-1:00 p.m.	\N	7	2010	\N	D1515	8805	8	21	\N	86faa7f85ae8db0422bc13e201585cce
43959	Blue Ribbon Sushi	\N	7	2006	\N	B4615	43953	1	1	\N	0d50892dc433459b1ef52a7e9c2da1e6
78534	(1997-07-08)	\N	7	1997	\N	\N	78428	\N	\N	\N	ab6b6b501a5997a538930cd0f1d95bb0
105846	(2006-10-12)	\N	7	2006	\N	\N	103385	\N	\N	\N	1741b3ccc5eb9f55ffdc37e98289c0c8
15992	Faith, Hope & Politics/The Sunni Triangle/The Man with the Golden Ears	\N	7	2004	\N	F3143	15711	36	18	\N	c1ee8766dd778196dc55a7a1aef18e69
149499	(2012-09-17)	\N	7	2012	\N	\N	149492	\N	\N	\N	266672b205a5ef8fdbbffb2c9fb7f8b2
128899	(2000-10-27)	\N	7	2000	\N	\N	128714	\N	\N	\N	76eb8e3b32f22d814022efa483b4d0c1
1856	Let It Snow	\N	7	2009	\N	L325	1852	1	4	\N	90945fa9a28be4131ee5d4cdcfb4dacb
76470	Amor Chicko	\N	2	2007	\N	A562	\N	\N	\N	2007-????	f4294e38ff76baf81cc600ffc47e7e2c
174407	A Night to Remember	\N	7	1998	\N	N2365	174406	1	2	\N	ae55d41a70cb372f395148915b6c1ffd
190327	Fearless Leader	\N	7	2009	\N	F6424	190285	3	4	\N	a93cc07ede060b43a108b16e4db50cd5
85833	Das Fotoshooting	\N	7	2008	\N	F3235	85788	1	4	\N	b0caf8008f549b602a12cae6ad838fc0
92478	Brad Paisley	\N	7	2003	\N	B6312	92450	\N	\N	\N	aad132a5c320bb30d7cf395cf3a6b7c4
180028	(2010-06-28)	\N	7	2010	\N	\N	178599	\N	\N	\N	f1edcd6997eb13239281e8b9bbf0dbbc
93605	2-and-a-Half-Star Wars Out of Five/Pink Man	\N	7	2009	\N	A5341	93602	6	7	\N	c94da4b9a7a32309a97d973238207eee
160969	Frankenstajn!	\N	7	2010	\N	F6525	160925	5	19	\N	85d0afc6be48595ac7b25f394505de56
127231	Three Kitchen Renovations in New Orleans	\N	7	2010	\N	T6232	127172	3	7	\N	d0b1c878c867e097ab968dc423fe8468
74930	Las Vegas Finals, Part 1	\N	7	2012	\N	V2154	74891	4	19	\N	7bc18b92f2c814c96f4fb2f63317600e
154628	Jon Bon Jovi/Kermit the Frog/Christina Milian	\N	7	2012	\N	J5152	154463	6	54	\N	80f495144231250197f0b9c0bfe05d6e
95096	(2003-06-10)	\N	7	2003	\N	\N	94664	\N	\N	\N	10fe144fec2a3c845bff8aff01a3936a
133800	Shark Fever	\N	7	1996	\N	S6216	133643	7	1	\N	c2648b8f65abd257966c52cc1d9679f7
30415	Que Fim Levou Alain Vieira?	\N	7	2010	\N	Q1541	30397	1	7	\N	afd4f053507615b791b7bff62d7d6c4d
21869	They Shoot Cows Don't They: Part 1	\N	7	1981	\N	T2323	20918	1	7	\N	55ce90436443251f2336c6256b6f6d96
47368	Independence Day	\N	7	2009	\N	I5315	47326	3	8	\N	0fdb44f8dd4ed32f254cccdaebfd0afe
40102	Actors	\N	2	2009	\N	A2362	\N	\N	\N	2009-????	f5aad1904d305c167b62d8ca18aca401
102325	(2005-06-30)	\N	7	2005	\N	\N	102292	\N	\N	\N	5a8246f2173bb56997dbcee85feff183
24857	Crisis	\N	7	1998	\N	C62	24845	1	8	\N	bfece4b155a03073e30e7bab11220def
192087	(#1.30)	\N	7	2006	\N	\N	192063	1	30	\N	5d02efb1bcf6b59146a7be61cdb720c1
69682	(#7.9)	\N	7	\N	\N	\N	69220	7	9	\N	00ae0c8102b16c6312bc2e0ac479af9a
194554	(2004-11-26)	\N	7	2004	\N	\N	194511	\N	\N	\N	ad390cdfd50cd87f5cb899a1c778f8e9
71444	Exposed: Part 1	\N	7	2008	\N	E2123	71412	\N	\N	\N	169e9800782bd244ffa6bd9e5fd0e940
46713	(#1.38)	\N	7	2007	\N	\N	46681	1	38	\N	983ce7eac5814dce4157b0ef2fdf9fbf
91911	Tomorrow's Antiques, Season 9	\N	7	2004	\N	T5625	91762	8	4	\N	0c2db1ff915966ef1623d663f9a207e2
167849	Iota	\N	7	2013	\N	I3	167764	6	62	\N	1aaebd6f2bca868b5a9ab310cc26130a
6518	So-Cal Surfing	\N	7	2011	\N	S2426	6438	3	30	\N	6136ed6e3d9e86beecf46c7364962b9b
107439	(#1.14)	\N	7	2010	\N	\N	107433	1	14	\N	8ddb064dc5d8cfdf315969728373817f
4960	(#3.17)	\N	7	2007	\N	\N	4951	3	17	\N	16adf1f3c3665623e03b114e76790384
112681	(1985-12-05)	\N	7	1985	\N	\N	112680	\N	\N	\N	1acb8e091e43d1a65eaa48b40d0555f7
114996	A Man Called Boy	\N	7	2006	\N	M5243	114979	11	17	\N	6b0d7721de411ac257676d223e7c3072
10856	Mexitalian	\N	7	2009	\N	M2345	10671	\N	\N	\N	d7415c6cc94a2e10f7bc325ba19b742c
165894	Akuma no tsuigeki	\N	7	2007	\N	A2532	165892	1	24	\N	673f8d9b5a3e60d7483fb02cc193749f
98882	(#1.5)	\N	7	1997	\N	\N	98877	1	5	\N	11693712b2c3d0cbf1397a9fd85f37b7
6658	(#1.1)	\N	7	2008	\N	\N	6657	1	1	\N	f9569c4006f60030d8561a6d0d97933d
140965	The Game	\N	7	2012	\N	G5	140768	\N	\N	\N	5a88acdd2e94bb8517bf046e84e359a6
96336	Un Chien Tangerine	\N	7	2013	\N	C5352	96289	4	10	\N	842eeff87d0db4b4ce64898f4b8c4d87
178841	(2004-10-20)	\N	7	2004	\N	\N	178599	\N	\N	\N	e01121d0c093958b2fb5ab456169b9b8
59976	Muslims Moving On	\N	7	2011	\N	M2452	59970	1	5	\N	15fa52b0ded4eb19e7d82828952a3f64
31005	A Year in Provence	\N	7	1993	\N	Y6516	31004	1	12	\N	85bbd6aadb512c2603737c450677163b
165906	Hisohiso no dokkan	\N	7	2007	\N	H2532	165892	1	36	\N	2b4116f7b3de8e0fa2838559c5da2076
128719	(1999-03-03)	\N	7	1999	\N	\N	128714	\N	\N	\N	0b40df9322c04d540aa496bf719eb265
188991	(#3.1)	\N	7	2010	\N	\N	188979	3	1	\N	fb4dbe7cc275010e266f7e0d33f46af7
56962	(#1.8538)	\N	7	2003	\N	\N	55774	1	8538	\N	344b076d334adf0216ac883f5ef39ac0
32508	(2008-11-17)	\N	7	2008	\N	\N	32442	\N	\N	\N	cdafe809b0c7f5c861e19610d46c91c3
100333	Michael 2	\N	7	2013	\N	M24	100296	4	2	\N	aecfa4436883696fd3a25ada79f88403
158897	Chevy Chase	\N	7	2009	\N	C12	158683	\N	\N	\N	587959718a92a6bb9316bd4546d8a099
182822	Yes, Minister	\N	7	2004	\N	Y2523	182810	1	5	\N	30c3a1c163a2afd2f6cb8d5f06d78a5d
115392	Australian Survivor	\N	2	2002	\N	A2364	\N	\N	\N	2002-????	d0df0d35d4e6c5e046e7758c0562521e
42112	The Big Booga Bank	\N	7	2010	\N	B2121	42094	1	9	\N	34522bb1e1a0052b848bdc062717edc2
77842	(2005-09-22)	\N	7	2005	\N	\N	77676	\N	\N	\N	6b6293532247e1b55d541d50d3aec9aa
147791	(#7.4)	\N	7	2011	\N	\N	147712	7	4	\N	77a05faa46d96dd04b789a78eb61405f
54411	Alice où es-tu?	\N	2	1969	\N	A423	\N	\N	\N	1969-????	171c7a3e03355149e78f9b1cebb92467
187474	(2011-01-31)	\N	7	2011	\N	\N	187057	\N	\N	\N	8341bd01a9a13f90110ed0895128c3ee
84593	(#1.139)	\N	7	2011	\N	\N	84548	1	139	\N	9d730df68848c3b5868cb22ebfba4cc4
67806	(#3.6)	\N	7	2006	\N	\N	67743	3	6	\N	d50f5cb05ba4c33f3369e5b8d64cab6b
163911	A Touch of the Unknown	\N	7	1972	\N	T2135	163906	2	12	\N	d65e502b9aeb34388fc4e45af6da8ce7
149784	(#1.64)	\N	7	2002	\N	\N	149675	1	64	\N	e8417ee27aa47834b31d6cda379f0d2e
12434	New Best Friend	\N	7	2013	\N	N1231	12433	1	3	\N	9002eef5ad46236af79c0c7be159668b
124596	Blading with the Stars!	\N	7	2002	\N	B4352	124578	1	22	\N	c7799598433fce5fc0ff03ee60208d3e
26856	Eye for an Eye	\N	7	1953	\N	E165	26855	1	1	\N	9112831baab2b1ba932cdfe2d8981d0c
42761	The Steam Wagon	\N	7	1956	\N	S3525	42661	7	13	\N	6b8becf280ec69aadd96b72a217544f2
45784	Agurknytt	\N	2	1999	\N	A2625	\N	\N	\N	1999-????	f9bf27535e292849579a982d7b39cd63
141774	Up the Tower	\N	7	2011	\N	U136	141748	1	13	\N	c6974dfbf33ada92134357ed6a1cb91e
44225	(#2.2)	\N	7	2000	\N	\N	44217	2	2	\N	2c16313724a97fce6d26282c94591628
55018	Ticket to Fame	\N	7	2011	\N	T2315	55010	1	1	\N	e54a52b78e824032edfb5a68569bc048
60793	Freja	\N	7	1994	\N	F62	60785	1	4	\N	51e9365733df7ad1f5aa679b740fa37e
29647	(2004-05-19)	\N	7	2002	\N	\N	29216	\N	\N	\N	e822cfce7e7b1ef38edf01db9210bbea
196335	Cake Boss	\N	2	2009	\N	C212	\N	\N	\N	2009-????	d524dba1d9e477be0d68fdf4f5c46564
86394	(#1.8)	\N	7	1974	\N	\N	86385	1	8	\N	307f2347139f77ae559f35a5d12f6c21
148671	Samantha's Good News	\N	7	1969	\N	S5323	148510	5	28	\N	80f9d3d0f06f1330b97e32dcb8bc02ab
133023	First Flight	\N	7	2012	\N	F6231	133015	1	1	\N	b0c82f8654e3b456b6285861a77f1f68
29589	(2004-02-25)	\N	7	2002	\N	\N	29216	\N	\N	\N	39adf232d2cd66d14bf13090863e0b84
65367	(#1.50)	\N	7	2003	\N	\N	65220	1	50	\N	e05623beb7856c665393d2f1867aef81
43711	(2012-04-10)	\N	7	2012	\N	\N	43320	\N	\N	\N	2569dd79bb5aa5cfb702f62ee911abd3
173273	A Mummy for Owen	\N	7	2009	\N	M5165	173272	1	7	\N	b9d794d62a0e92d4aec49dba9783a282
149072	The Curse of Hampton Manor	\N	7	2000	\N	C6215	148968	\N	\N	\N	0e91e832f6e3104404751bc18675dba1
193524	The Case of Dangerous Lady	\N	7	2007	\N	C2135	192964	1	457	\N	0aaa16e8bbc4b5a0fa9c3e7bd68c6191
163968	Who's Minding the Baby?	\N	7	1974	\N	W2535	163906	4	3	\N	785c3f3b2bb71d5f41bcf3adcefc20c7
172813	Alexandria, Va.	\N	7	2013	\N	A4253	172759	\N	\N	\N	d23c70faed795eef691b82bc7db00b80
21582	Paddling Your Own Canoe: Part 2	\N	7	1988	\N	P3452	20918	8	50	\N	e34175e11d8360ca0e252ef9ee0834d1
185962	(#1.11)	\N	7	1986	\N	\N	185959	1	11	\N	b69b2eeada7b6eedb198a6814defa4b2
71919	Bullfighting	\N	7	2008	\N	B4123	71915	1	6	\N	c093046349b9baedf028d4e9c4f91d4f
142266	Belinder auktioner	\N	2	2003	\N	B4536	\N	\N	\N	2003-????	39c3e1cea663101102224764cf1c7167
118853	(#1.910)	\N	7	\N	\N	\N	117506	1	910	\N	259442de042ff9fdf27b482b07828240
109725	(2010-01-04)	\N	7	2010	\N	\N	109693	\N	\N	\N	a3ee822c5e48f29313f30f674c5e9e13
14311	(2010-09-06)	\N	7	2010	\N	\N	14095	\N	\N	\N	643aaf0c584a79f74819e1dcd6746eb6
190779	Busted	\N	2	2001	\N	B23	\N	\N	\N	2001-????	dfd1167be1d9bf39002e28096e90ae4b
185284	Family Day	\N	7	2007	\N	F543	185257	1	11	\N	7c4d0a4576b84ddaa62bf04923af535b
196615	(2011-03-20)	\N	7	2011	\N	\N	196597	\N	\N	\N	95360085ee9c9a1d58122cbf087da7b5
113814	Schwierige Verhältnisse	\N	7	2006	\N	S2621	113797	2	8	\N	8e6f928b9fb4002e4932345af5096df6
140203	Before They Were Rock Stars	\N	2	1999	\N	B1636	\N	\N	\N	1999-2001	b091c017c408240a80167b923e297a6b
62094	(2005-07-02)	\N	7	2005	\N	\N	62082	\N	\N	\N	a222a40461ab153e65a691ef5d831ba4
136795	Aamin na si Maya sa kaniyang pamilya	\N	7	2013	\N	A5252	136791	1	132	\N	b7247f7e71707e7e7c16478d551b8d48
25431	A Loja de Camilo	\N	2	1999	\N	L2325	\N	\N	\N	1999-????	bb0fd082faf07856cc5dac0b2c6ea382
154940	Friends Take Cab from New York to Los Angeles	\N	7	2011	\N	F6532	154911	2	46	\N	4395531af720fe3ca8ea0b4d7e7af983
195848	(2007-02-16)	\N	7	2007	\N	\N	195563	\N	\N	\N	a70b9cbc0c9d08bc20f7acc27238a850
36773	(2012-06-04)	\N	7	2012	\N	\N	36138	\N	\N	\N	53cd0876234155e79706c5c1bd81c11c
85644	Louis, the Pawn	\N	7	1972	\N	L2315	85640	1	8	\N	838df6faadd8c24aa92cc3d35f28c7b7
158079	(1992-03-21)	\N	7	1992	\N	\N	157571	\N	\N	\N	6b502186255f981539e0b13f40fb947f
157013	(1967-07-29)	\N	7	1967	\N	\N	156990	\N	\N	\N	a4dc82d14b67ea011f89e4e388cd45eb
68733	Roosevelt Estates	\N	7	1997	\N	R2143	68692	1	13	\N	7fd4e25d4e9147808cf1fc8785d8b3a6
156148	The Adventure Begins, Part 1	\N	7	2006	\N	A3153	156124	1	1	\N	c69d480fe8abaaea4c2b21e8c77d3c18
123843	Séductions	\N	7	2008	\N	S3235	123710	2	69	\N	90e70043289cd36bd56a2e4f169d3639
85045	(#1.217)	\N	7	2002	\N	\N	84913	1	217	\N	ce13b5148e684751bc33b06795285a48
184504	Campaign Plan	\N	7	1983	\N	C5125	184043	1	30	\N	b19d65f9f0b6e45d9526a01181bece37
129964	4	\N	7	2000	\N	\N	129957	\N	\N	\N	82b9dbea096a03c1196f820927458e91
160888	Watashi datte karega hoshii! Gôkasen no wana	\N	7	1992	\N	W3232	160846	1	12	\N	80cabf442aa6e6da6432d8b1b4927784
165888	(#1.5)	\N	7	2004	\N	\N	165883	1	5	\N	a7beb44c3d7fa2ea21c1609cab3f1217
101026	Joe Cain Day in Alabama	\N	7	2011	\N	J2535	100979	7	5	\N	cd17461ce789f395f7f065c13190b652
161791	Story of Elijah	\N	7	2009	\N	S3614	161786	\N	\N	\N	18a50053389e150afa3af5c024cd65ad
197984	(#1.124)	\N	7	\N	\N	\N	197955	1	124	\N	c6a98d0211b6336f42fd90414aefb871
7269	(2012-06-24)	\N	7	2012	\N	\N	6845	\N	\N	\N	02ec3cdc52ca65d9f70739b11f52e085
104497	(#1.13682)	\N	7	2010	\N	\N	103385	1	13682	\N	fffcd6727bb0df6017641ce5e5a5a73a
161006	Pocinje rat	\N	7	2009	\N	P2526	160925	\N	\N	\N	594ad14820b4f771416d490fdb1fa90c
11284	(#1.4)	\N	7	2002	\N	\N	11281	1	4	\N	334b16cc119ab6f00c0bf57a104efd39
47322	Pilot Training School	\N	7	2005	\N	P4365	47315	1	6	\N	a0abee55f0eca4fbb751491fe45b4d08
47623	Don't Take No for an Answer	\N	7	2004	\N	D5325	47612	1	15	\N	91140b30c5bd7406d8a8b1f7b887e3bf
34911	New Voices 2004: Taubman Sucks	\N	7	2006	\N	N1231	34877	\N	\N	\N	aedc6f893949f366733828cadf34ca6f
27118	(2002-12-16)	\N	7	2002	\N	\N	27080	\N	\N	\N	18e761723e8ad22b5033f867b10628f1
104177	(#1.13361)	\N	7	2008	\N	\N	103385	1	13361	\N	8277b6c11592db80cf7301f59bf95ba4
177387	Brandvägg	\N	2	2006	\N	B6531	\N	\N	\N	2006-????	a80e1cd55889d0a75e4ef838f9bcbe3b
124947	Balitang Kris	\N	2	2001	\N	B4352	\N	\N	\N	2001-????	d1861d8a836b0cf43d45defbcd3760aa
198713	Ring Reward	\N	7	1962	\N	R5263	198700	1	23	\N	db2e2881a2d9caec42facfdbccf9038c
122489	Revolving Doors	\N	7	2001	\N	R1415	122400	3	13	\N	cbfc4ba33f4011169d2028285967f21a
56087	(#1.10311)	\N	7	2010	\N	\N	55774	1	10311	\N	e0f03fe82d6bb8b19930844d098c224c
82376	(#8.30)	\N	7	1982	\N	\N	82255	8	30	\N	a448ec506555570ef7a2b5f196dc3ce0
4156	A Great Distance in the Wind, the Sky at Dawn: Part 12	\N	7	2003	\N	G6323	4152	1	35	\N	4e8caa75906ee1ce5af679c080237bef
85480	(#1.5)	\N	7	1995	\N	\N	85474	1	5	\N	407414b8d9767e93201309bbb6f3c202
73957	Hollywood Round: Part 2	\N	7	2010	\N	H4365	73710	9	10	\N	8b30134874cd4b72eb71b9c93a98e8e6
99657	Around the World in Eighty Dreams	\N	2	1992	\N	A6536	\N	\N	\N	1992-????	2c7621abeb7a195b8638570550d51919
156453	Freiburg - Stadt der Sonne	\N	7	2006	\N	F6162	156260	\N	\N	\N	b7fc2827bc4d09df1b77ea21774b159d
46375	(2004-01-31)	\N	7	2004	\N	\N	46022	\N	\N	\N	3fc651295dc459286a726e65919b7640
29903	(2005-09-14)	\N	7	2005	\N	\N	29216	\N	\N	\N	996b7819d753206d198b655b86d5ae0f
104732	(1967-02-17)	\N	7	1967	\N	\N	103385	\N	\N	\N	920dceb21e7cde525c6810887f4fbf00
37624	The Smile: Part 3	\N	7	1970	\N	S5416	37579	1	12	\N	74d9deec41a21a5dac25da0f195e1930
113533	(2011-02-04)	\N	7	2011	\N	\N	113519	\N	\N	\N	2d1ae1b417294cad332d248a5654604b
47776	Tracks	\N	7	1986	\N	T62	47723	3	21	\N	12398c47091ab9919b7c8357b08e3e20
50946	Secretos	\N	7	2000	\N	S2632	49991	5	52	\N	4c52cd7736adf0e09e94fb52692c9a3e
165489	(#1.2)	\N	7	1979	\N	\N	165487	1	2	\N	19205a6798b19a6d5e7e565cb3242f8f
137266	The Shining Example	\N	7	1975	\N	S5251	137259	1	6	\N	96079366a96c9677ef31870bb8afe7d9
117597	(#1.108)	\N	7	2008	\N	\N	117506	1	108	\N	6cd576d1c4f8af87368936b88287cc06
134820	(2009-12-03)	\N	7	2009	\N	\N	134557	\N	\N	\N	06d0840903d8644bb6377f9c57b6cc7c
18706	7th Heaven	\N	2	1996	\N	T15	\N	\N	\N	1996-2007	542066d6036466c1eb1201a5f33cf346
6374	(#5.3)	\N	7	2010	\N	\N	6370	5	3	\N	9b31714b1424ec9da28e245f79ba7231
49597	Las limonsas	\N	7	1970	\N	L52	49588	\N	\N	\N	7996a594a1f429f60531ca3291b70877
55673	The Blockbuster	\N	7	1971	\N	B4212	55507	2	8	\N	307bce612fe13bae94a284b468f49814
15511	(#9.7)	\N	7	2006	\N	\N	15336	9	7	\N	c315a0550da07dbe907f434a258f2601
4255	The Climate of Doubt	\N	7	1964	\N	C4531	4209	1	5	\N	714226a98e3c0f37cbfbac447b001d53
95217	(2004-05-06)	\N	7	2004	\N	\N	94664	\N	\N	\N	97d9991b5bc5552492537b62ce043098
130600	Winner Takes All	\N	7	2012	\N	W5632	130580	1	13	\N	102958e9c24b1e1b24d47d493f566f66
83829	(2010-01-16)	\N	7	2010	\N	\N	83811	\N	\N	\N	678b23914f9cb8df1da3cda77a23a5eb
170911	(1998-09-04)	\N	7	1998	\N	\N	170883	\N	\N	\N	89fb6eeb513fa71d6ff93498a87134b5
94998	(2002-10-04)	\N	7	2002	\N	\N	94664	\N	\N	\N	01e729a2751c05485cb52f7e78f7b21f
172839	Arlen Specter	\N	7	2012	\N	A6452	172759	\N	\N	\N	ddfab4c5ef1a94df1c32c081afc315be
164372	(#2.114)	\N	7	\N	\N	\N	164254	2	114	\N	c7d2554fddd9ffb215097edc90c66822
132650	Tatakau riyû	\N	7	1998	\N	T326	132629	1	18	\N	4138944da0863be10ff108e1dbbdc7d5
100889	(2002-08-30)	\N	7	2002	\N	\N	100757	\N	\N	\N	729950200b5fb71204656be2c1285658
143159	The Widening Gyre	\N	7	2011	\N	W3526	143112	2	20	\N	47514be15199073d41f4f8acf124fc46
58381	(2002-08-23)	\N	7	2002	\N	\N	55774	\N	\N	\N	340371ffdbe634d5140da110555d51db
69983	New York Auditions	\N	7	2011	\N	N6235	69890	6	7	\N	654d84c6c6212e93614b30e2cd3cc9d2
196144	Blues for a Junkman: Arthur Troy	\N	7	1962	\N	B4216	196140	1	21	\N	fc083621383368bcd6218b53339e3198
134603	(2009-01-26)	\N	7	2009	\N	\N	134557	\N	\N	\N	797459431a30f0eb95ca831668d8ce89
91061	Osa 12. Helsinki, Suomenlinnan lelu-ja nukkemuseo	\N	7	1997	\N	O2425	91033	2	3	\N	024276e9161bc4ab7bdb13e581179b2e
7318	Child Stars: Where Are They Now?	\N	7	2008	\N	C4323	7301	6	6	\N	0d1dac3be5dccaec1c9bc1542b2b3471
88190	(1998-10-02)	\N	7	1998	\N	\N	87087	\N	\N	\N	70d57114e486a4c690ee2275bd474154
41082	South Wales	\N	7	2011	\N	S342	41043	1	10	\N	a2cf109e0a49eb7b4ad2639678a16e19
66572	La nochebuena de 1947 en el bar de Marcelino	\N	7	2007	\N	N2153	65509	\N	\N	\N	690da2196e744f1166e2d9701d426545
89821	(2003-11-17)	\N	7	2003	\N	\N	87087	\N	\N	\N	747d18c87d13c466bcf7c3f83c5d5790
37731	(#1.1)	\N	7	2010	\N	\N	37730	1	1	\N	4ad24497eacd6cc255cdcad5befc3dba
114345	Mahone-Coming at Bjorn's	\N	7	2013	\N	M5252	114300	1	27	\N	697b8ee25067e6895f89616276a07a93
175432	(#1.34)	\N	7	2006	\N	\N	175404	1	34	\N	45d4de23f45a766d83c7b63c73d46019
94575	(2006-12-06)	\N	7	2006	\N	\N	93972	\N	\N	\N	5ebb70f8cf92949f6c4e966c965e4904
84544	Anjo Mau	\N	2	1976	\N	A525	\N	\N	\N	1976-????	0f2a3b2920a8c375a1277e73cd4c7e86
60928	Fakiren	\N	7	2003	\N	F265	60908	3	2	\N	b0eaa815fc1198cceccd25f8134a0bb5
45343	(2000-11-18)	\N	7	2000	\N	\N	45248	\N	\N	\N	77fed3385c5dcb997d597120d2bdf34e
2589	Sick as a Dog	\N	7	2001	\N	S232	2558	2	8	\N	fd0f58bd64afc68de83c1b28b1dcf1f2
113499	No Sex Please, We're Brickies	\N	7	1986	\N	N2142	113474	2	7	\N	f2b575adf5dc9f82b5e8839b19edb32f
125861	BANCO! - Ein Spiel um Sackgeld	\N	2	1979	\N	B5252	\N	\N	\N	1979-????	8a6214e52de9b88e755b48d5b3c3a892
141550	A Spectre Calls	\N	7	2012	\N	S1236	141549	4	4	\N	ffc7167f2cbe63cb115924454bce8d5c
137277	(#3.1)	\N	7	1988	\N	\N	137271	3	1	\N	ab44fd353e87ba2aabae885db289ada4
185268	An Ideal Husband	\N	7	2010	\N	I3421	185257	5	6	\N	33a1aeaa7bbe76061f202fa6a58f2729
60873	Allir litir hafsins eru kaldir	\N	2	2005	\N	A4643	\N	\N	\N	2005-????	d909ff551acac496378e2c4b8486b87a
2465	Anna Tells Sophia That She Is Her Daughter	\N	7	2011	\N	A5342	2417	1	116	\N	c9aea173379234e2ca364556d6353623
58086	(1996-05-07)	\N	7	1996	\N	\N	55774	\N	\N	\N	42b649865724e1a9211c3f9d1071195b
113631	Aujourd'hui Madame	\N	2	1970	\N	A2635	\N	\N	\N	1970-1982	a8328006a5088c04c5ddd25296eb219d
185532	Something Old, Something New	\N	7	1989	\N	S5352	185452	\N	\N	\N	58ce5171f3e33f78829ee2b21f2300a4
10511	Home Sweet Home	\N	7	2010	\N	H5235	10506	1	6	\N	626536573ddd567cbaa308422208503f
75552	Level Three: Random Encounter	\N	7	2013	\N	L1436	75546	1	3	\N	b6230e51976726ee65353cdb037c6bb7
89467	(2002-04-23)	\N	7	2002	\N	\N	87087	\N	\N	\N	105270af433f19cb5eb65618fe73f5ce
65485	Bheem's Quest	\N	7	\N	\N	B523	65481	1	12	\N	fc07a64bbdd9388b4fa58ecdf1825087
96789	The Mr. Almost Episode	\N	7	2011	\N	M6452	96719	2	25	\N	0bf43ad12d29b86136bd590486e4dc70
166397	Spinning the Yarn	\N	7	1998	\N	S1523	166010	5	22	\N	6c39c828778d18d003128b8cc815ac6a
197938	(2013-01-17)	\N	7	2013	\N	\N	197899	\N	\N	\N	0474cb9deed3a8758a8d77fd8ecc2c7a
153978	Movie Night Madness	\N	7	2011	\N	M1523	153923	6	5	\N	313838116ea04c497b805709563d4380
196113	Sunday Brunch	\N	7	2000	\N	S5316	195940	\N	\N	\N	98c813c5a2dd7949f78d7a072a7e2dcc
81007	D Minus Zero	\N	7	2000	\N	D526	80989	1	4	\N	d7efb5623ad990d820f6f67412676beb
91520	Kedleston Hall	\N	7	2006	\N	K3423	91279	29	3	\N	953aa9c0aa29f696ff1a05b799ecc51f
151252	A Credit to Us All	\N	7	1969	\N	C6324	151251	1	8	\N	b83a94df5daa80d4e7aea5a6c68cb6c2
37218	Bad Word	\N	7	2002	\N	B363	37204	1	11	\N	6f595dba5b5cc034e8534706365e923d
13509	Abducted	\N	7	2009	\N	A1323	13503	\N	\N	\N	540acdf2458233f7c1d955e3ddebc58e
84714	(#1.248)	\N	7	2011	\N	\N	84548	1	248	\N	374eb4877c96b232566c7fd4588ab919
192405	Thiemes Karriere	\N	7	1982	\N	T526	192389	1	6	\N	3d109c8aea8ea1426f22f57aadd49dfc
45088	Dating	\N	7	2012	\N	D352	45086	1	2	\N	5cace843b5f872c15b375e3e8077c928
188968	Blind Run	\N	7	2009	\N	B4536	188966	2	3	\N	7e3abbf4ca4b83c727d27ad51a554090
35746	(2011-11-24)	\N	7	2011	\N	\N	35537	\N	\N	\N	4b8093f08d1a9de5880edadb265ccda1
13085	¡La revancha!	\N	7	2010	\N	L6152	12994	1	29	\N	b677a9386bb0596707ee34169eb1c44a
180861	Melodi Grand Prix	\N	7	2012	\N	M4326	180845	1	2	\N	e5f01da94f546bfe6163921e846f58c8
186159	Krudt og gamle nisser	\N	7	1998	\N	K6325	186146	1	2	\N	348406378a6206ec0a0706fcd1f6857d
171080	(1994-10-06)	\N	7	1994	\N	\N	171034	\N	\N	\N	a713adfa45febc26cd3f3da6293006d3
106757	(#1.28)	\N	7	2008	\N	\N	106736	1	28	\N	d262896ea387bc650a8b6b33f9abb262
179862	(2010-01-13)	\N	7	2010	\N	\N	178599	\N	\N	\N	6814752dc14b09dbcb2e868600b1afd7
76792	(#1.103)	\N	7	2005	\N	\N	76786	1	103	\N	2c8f5102bc50bd6023b6192a1a9f8439
74821	(2007-07-03)	\N	7	2007	\N	\N	74718	\N	\N	\N	945bd0033213400e541e807e99ecad12
2789	Conductoras vs Conductores	\N	7	2004	\N	C5323	2786	1	5	\N	85ea0593259bb13d82ea609586c41a14
189300	Neapel	\N	7	2000	\N	N14	189273	1	24	\N	15bf09d839867a238e9fd13f8f2591d3
81597	(#1.18)	\N	7	\N	\N	\N	81593	1	18	\N	ef27e74abd86ad99ebd345460f71dbd5
99930	(2011-06-20)	\N	7	2011	\N	\N	99703	\N	\N	\N	cf2eb0e56cc75e49cf9738b240e0ddc2
96197	(#1.8)	\N	7	2009	\N	\N	96154	1	8	\N	45da161fc80aa4aadc0f0d5862c8b41f
64708	Incredible Results	\N	7	1976	\N	I5263	64658	\N	\N	\N	f2cd88fa8b96a0e6aab919bdefbfcc88
129351	(2004-11-02)	\N	7	2004	\N	\N	128714	\N	\N	\N	8cfe73b5905ba27acdcaffd2356d7cea
18159	¿Cuánto te acuestas?	\N	7	2000	\N	C5323	17959	4	11	\N	1ba06e92b329c566354168fc425850ae
44985	Perleberg heißt er	\N	7	1991	\N	P6416	44961	1	12	\N	b26ff1fd84f1422493ea83b0215dcb9d
37477	Cake Walk	\N	7	2006	\N	C242	37458	1	6	\N	186c7599035ed6b69048ba0a07b68e2e
165934	Shû	\N	7	2008	\N	S	165892	1	51	\N	2e5a1109deb56fb72641c4a7266799ec
77320	AmorDiscos	\N	2	2000	\N	A5632	\N	\N	\N	2000-????	24ac0f5d793e64290100320edf433519
80770	(#1.63)	\N	7	2008	\N	\N	80624	1	63	\N	5430b8fb4bf749e0853250b688a4c0df
11141	Florida	\N	7	2013	\N	F463	11108	7	10	\N	6afe0c10d1bdbb6773c63701d12e2c5e
195975	Caillou Flies a Plane	\N	7	1997	\N	C4142	195940	\N	\N	\N	5672f483af0bd5be4a3a6d5edc1a2999
59085	Pushed to the Limit	\N	7	1999	\N	P2345	58754	2	10	\N	ce37bcf13efa50778328bb163a9248a1
97724	(#1.20)	\N	7	2005	\N	\N	97711	1	20	\N	f84e1768875cdc21898933eeb1cf826d
95646	(1996-05-07)	\N	7	1996	\N	\N	95525	\N	\N	\N	482d2bb28ca2ef0a23df15c863c32c03
177384	Yellow for Courage	\N	7	1966	\N	Y4162	177336	2	23	\N	7e3554463ed81a2710ff8189d1019e16
92641	Taylor Swift	\N	7	2008	\N	T4621	92450	\N	\N	\N	a1332e5ada2125e29bf18bd7b0985829
29101	The Things We Do for Love	\N	7	1996	\N	T5231	29062	4	3	\N	c5276af01b19c8f5bdc2c0aefeed9262
78018	An Englishman's Castle	\N	2	1978	\N	E5242	\N	\N	\N	1978-????	1742c19d0ce676108d2c6fbc05fbea66
58204	(1998-09-14)	\N	7	1998	\N	\N	55774	\N	\N	\N	3f24fc2a7c8b81382ff95e7c1fd14dbc
162880	Horizon	\N	7	1979	\N	H625	162861	2	4	\N	b0ba13fafa9ec84524d3354f3fef4b7c
118308	(#1.42)	\N	7	2007	\N	\N	117506	1	42	\N	01ee6c2b7da9dd62653d12ffc9b88beb
198201	(1998-04-03)	\N	7	1998	\N	\N	198109	\N	\N	\N	267c21b5805859dd3ca2a8315c9be6ee
117839	(#1.1298)	\N	7	\N	\N	\N	117506	1	1298	\N	85d041b3de01621ebe3837d01c1df50c
142018	(#1.94)	\N	7	2009	\N	\N	141924	1	94	\N	740c396229122a773ac0648da7e85472
47752	Little Wolf	\N	7	1986	\N	L341	47723	3	16	\N	679d4a3e112ea6eb739503cda85015cf
114754	Auditions: Sydney	\N	7	2005	\N	A3523	114735	3	4	\N	abdcfcdf255d52857c8229f8b56f1658
106287	Members Only	\N	7	2012	\N	M5162	106284	1	1	\N	ba11e84b8f8487993a0ddd8bd00b2447
73976	Let's Learn About Ruben and Clay!	\N	7	2003	\N	L3246	73710	2	38	\N	3c77b7d2262c694c1480b4c41c02f4e4
11154	Hey, Baby, What's Wrong?: Part 1	\N	7	2012	\N	H1326	11108	6	6	\N	f56b6a1082faf9cb2105aa38028a2e74
145645	Beschuldigd	\N	2	2013	\N	B2432	\N	\N	\N	2013-????	b46ac1c6a2565b20798764650fac5422
41092	Yorkshire	\N	7	2013	\N	Y626	41043	2	10	\N	68ebe5f1b43498047bb85c8669077a9e
8922	Day 5: 2:00 a.m.-3:00 a.m.	\N	7	2006	\N	D5	8805	5	20	\N	430ee6781ce6cfbf97e766bd342a9faf
41785	Five Short Graybles	\N	7	2012	\N	F1263	41754	4	2	\N	72a6c723458844282d743259c2237a40
153947	Easy Elegance	\N	7	2010	\N	E2425	153923	3	19	\N	1e9efc6c8e307985fba411ae467d3795
43741	(2012-06-05)	\N	7	2012	\N	\N	43320	\N	\N	\N	9c0232d15edf94a59718aa9a8d35fcef
1892	(#3.2)	\N	7	2013	\N	\N	1865	3	2	\N	afa79fd907980f305fe38d12c7239aa6
151672	BB08: Eviction 1	\N	7	2008	\N	B1235	151550	8	2	\N	873b2e77803b59d3a33b703b638dc3b4
79585	Are You a Curmudgeon?	\N	7	2012	\N	A6265	79583	1	12	\N	5e19c34d4bcd1bce32b7d4cb5b53c359
36942	(2012-12-18)	\N	7	2012	\N	\N	36138	\N	\N	\N	bf5aec1256cf606fbff53fe9e498ef28
133983	(#1.170)	\N	7	2004	\N	\N	133903	1	170	\N	0ded24fd02d9e51dd5b5bf3a8c98611d
105218	(2002-05-21)	\N	7	2002	\N	\N	103385	\N	\N	\N	123a8ee646370bd80c6dfb9f44eb6c15
123091	(#1.259)	\N	7	2012	\N	\N	122913	1	259	\N	0f1e1898f26116db5a6eb9099fd39304
91296	(#8.9)	\N	7	1986	\N	\N	91279	8	9	\N	3e58c839ea5415ce6ac31eb664425f29
53097	(2011-09-30)	\N	7	2011	\N	\N	53071	\N	\N	\N	173226e49b01d7779dae5e8e1edb7c3f
131862	A Picture of Death	\N	7	1960	\N	P2361	131856	2	14	\N	d9005ca985ffbdc83e8ef77544d83762
24194	Quem é Morto Sempre Aparece	\N	7	2004	\N	Q5632	23829	4	23	\N	5d3f07cfe6affd7a2e7944a97e910637
134896	(2010-03-30)	\N	7	2010	\N	\N	134557	\N	\N	\N	cb8cec214a6de3c7ae4a4c114f436beb
100941	Art in Progress: Tony Oursler	\N	7	2005	\N	A6351	100933	\N	\N	\N	37628031d7d93726c79626e51d3854b3
141346	(2008-08-19)	\N	7	2008	\N	\N	141334	\N	\N	\N	c87793423636de80b329595bac4e486f
152514	(#3.41)	\N	7	2002	\N	\N	152267	3	41	\N	428d567a5fdcae01603c102dd452467b
66696	Mario pide en matrimonio a Consuelo	\N	7	2006	\N	M6135	65509	2	28	\N	41d74febae5bb7572422b082e12598b8
192646	(1985-09-09)	\N	7	1985	\N	\N	192645	\N	\N	\N	f2029dd2a67b7abbce51c3cf6a9ff77d
6809	Tricksen, tarnen, täuschen - Der Machtkampf um Hartz-IV	\N	7	2011	\N	T6253	6772	3	15	\N	9f3bdea6732a2c70cdc0df6b96c73422
106343	(#1.101)	\N	7	\N	\N	\N	106339	1	101	\N	7fe2f63e1ce84600ae765d7e33aa2ef0
33432	(2012-06-12)	\N	7	2012	\N	\N	33102	\N	\N	\N	d551be5f8fdff3ad2af6fde54a77c814
11142	Floyd	\N	7	2010	\N	F43	11108	4	16	\N	c6f7c6331d7d76685efbd3beff4f285c
32545	(2011-05-10)	\N	7	2011	\N	\N	32442	\N	\N	\N	eb96159a1bce84552596434741ca4cac
182201	Une absence prolongée	\N	7	1978	\N	U5125	182195	\N	\N	\N	09b813b641d30f6ed0c3790b714dff28
18477	Abra-Cadaver	\N	7	1959	\N	A1623	18466	1	28	\N	bb76bc3cbcd963795fa60eb0ae7b643c
63665	(2000-07-21)	\N	7	2000	\N	\N	63198	\N	\N	\N	6cc842c0df566216663fb5ad46e17c30
128796	(1999-11-04)	\N	7	1999	\N	\N	128714	\N	\N	\N	360e5dc9984057bceebb5cb2b49e4369
96203	Arbeitersaga	\N	2	1988	\N	A6136	\N	\N	\N	1988-????	8d409996a64780aded02aa111ca6668e
187892	(2012-02-28)	\N	7	2012	\N	\N	187850	\N	\N	\N	cce7ddbfc290ff317362fb6c9ac02337
183875	Linke Tour	\N	7	2001	\N	L5236	183869	1	10	\N	8eda97aacd156823107f82b62fd5e8e9
112966	Low	\N	7	2012	\N	L	112963	1	4	\N	0ac2b6a47038935e47ca1469b1a76dea
76935	(#1.87)	\N	7	2005	\N	\N	76786	1	87	\N	08059640af923ce02e64a706260c6ad6
15479	(#3.7)	\N	7	2003	\N	\N	15336	3	7	\N	b2ab15d80d176a68b1bdd326aba0d77b
123943	A Living Doll	\N	7	1996	\N	L1523	123942	1	6	\N	de0dff048b8725c2a07ed9194977b4fe
19093	(#1.6)	\N	7	2005	\N	\N	19086	1	6	\N	f039b6dfaa90093ab8be337a8495542e
106843	(2007-05-14)	\N	7	2007	\N	\N	106822	\N	\N	\N	b7bc0ccdbeceee5e45dff9cc19333b48
175143	Cockroach City	\N	7	2012	\N	C2623	175137	1	19	\N	effbdae2bc8fb7a27808a455bbc841eb
123092	(#1.26)	\N	7	2011	\N	\N	122913	1	26	\N	73000024eb54bc3601627ab4e4ca07f1
91058	Osa 117. Anjalan kartano	\N	7	2003	\N	O2524	91033	16	14	\N	ad6fca78e4a359e155ee57242853b255
129501	Nothin' for Nothin'	\N	7	1976	\N	N3516	129466	3	10	\N	5760a42b3070ec017354e6875cb50ec4
80979	(2005-03-19)	\N	7	2005	\N	\N	80977	\N	\N	\N	e39b64a803928fdaf1159b23886d38e8
151669	BB08 Big Mouth: Week 8	\N	7	2008	\N	B1253	151550	8	15	\N	82347a65260fc1a87906c2b8050b0454
96942	UAE: Camel Race	\N	7	2011	\N	U2546	96831	3	26	\N	87baced6b28649e61c0c0ba896801f75
176531	Big Man in Tin Can	\N	7	1959	\N	B2535	176514	2	21	\N	cb1a1d565cd089d07cad1adb6ee7abac
169129	La ciencia ficcion Espanola	\N	7	2007	\N	C5212	169040	5	68	\N	56a67efe17caa04587018265d4b65ebc
105629	(2005-09-23)	\N	7	2005	\N	\N	103385	\N	\N	\N	02eb1a2ff3e4b1c6879efffea826eaf6
92743	Adulterers: Part 1	\N	7	\N	\N	A3436	92741	1	10	\N	62860438d612a15ef1203db4ece83972
54634	Fifteen Minutes	\N	7	2006	\N	F1353	54632	1	6	\N	ece40374cf9acc4dc235b41e1b9efe20
10038	La rupture	\N	7	\N	\N	R136	10013	1	1	\N	5b94b9bd996c1c8a560fbe923605f8bf
62308	Needle Day/Octo vs. Batty	\N	7	2012	\N	N3432	62280	2	4	\N	570b1bde22deb9ef7c8c601fc13980d0
179309	(2008-04-10)	\N	7	2008	\N	\N	178599	\N	\N	\N	4de36f8075bc67468563b4718ea0837b
147528	Nobody's Fireproof	\N	7	1992	\N	N1321	147509	1	12	\N	c5dd3c6ad0ebe182ba0cff6a276bbe8f
42015	Paul Revere's Heroic Ride	\N	7	\N	\N	P4616	41997	1	3	\N	ff9a47b819af0aa13680c5fb72936305
43704	(2012-03-20)	\N	7	2012	\N	\N	43320	\N	\N	\N	9618f0f033ab4eeafce43028bf645bc8
154675	Lea Thompson/Ciara/Karmin	\N	7	2012	\N	L3512	154463	6	11	\N	b169d3e06dd0e1a1e58ef10da68e9d21
118825	(#1.886)	\N	7	\N	\N	\N	117506	1	886	\N	fc03c7e1c0fde673553dccbd1f98a38b
151507	(#5.9)	\N	7	2009	\N	\N	151442	5	9	\N	16ed6bd45a9177b779c551ea83f46f84
7387	(1980-01-24)	\N	7	1980	\N	\N	7383	\N	\N	\N	c378a37801b8e65b9cea10d697a78250
113943	(#2.3)	\N	7	2009	\N	\N	113934	2	3	\N	dc27ca2af8c102c7320dd7b936ad0907
155348	(#1.1)	\N	7	\N	\N	\N	155347	1	1	\N	f2a3f471ac5126ee7f3879e1191c2950
54657	I, Pierce	\N	7	\N	\N	I162	54649	1	21	\N	4d355eb52056dda1305bdb4b7cd2dfe4
71552	The Girl Who Goes Ballistic	\N	7	2004	\N	G6421	71412	3	10	\N	58637526da02d9e644be63a9a3f54591
127479	Sto miliardów po raz pierwszy	\N	7	\N	\N	S3546	127474	1	4	\N	d3ca7e6642885fb99911c7ed0b45af53
71872	Sweet Endings	\N	7	2011	\N	S3535	71730	\N	\N	\N	e118e1db938e119cb7cfb6eefa29143b
93021	Museo	\N	7	2012	\N	M2	93010	1	13	\N	d6157e7e51d8ba3cfc993cfa2164c986
194009	The Case of the Spotless Kingpin	\N	7	\N	\N	C2132	193950	\N	\N	\N	74120344d829e3d87c34bccd5ac1fbc0
119932	B. Original with Kids' Decor	\N	7	2006	\N	B6254	119910	\N	\N	\N	fbb813e334afd781113d879f9af33797
102945	Alex's Birthday	\N	7	2001	\N	A4216	102943	1	14	\N	0bbc5ac27c17c1e0db79bab3df5b18b0
15068	(#4.39)	\N	7	2011	\N	\N	14924	4	39	\N	035e25bf8f12128d71fc1fe08a95904a
91665	Sherborne	\N	7	\N	\N	S6165	91279	25	20	\N	c1dad75d6514f861ef7bffdb46c892e1
34561	Falso embarazo	\N	7	2012	\N	F4251	34490	1	40	\N	bd67a46ea31a3bfa292e06843ecba0ab
73886	Auditions: Miami	\N	7	2008	\N	A3525	73710	7	6	\N	f05ded8c9d12be603d71ee70e0181b19
136404	(2011-01-16)	\N	7	2011	\N	\N	136169	\N	\N	\N	0e3bb1e3240ebc8544a6c28eea5b97fc
4008	Farbenspiele 1966-1970	\N	7	2005	\N	F6152	4006	1	3	\N	0aa19e58d7156d6a214f7aa732719be4
108186	(#4.2)	\N	7	2013	\N	\N	108154	4	2	\N	cca99be09786b0d280c783bb4f19c8b0
71715	The Guido Family	\N	7	2013	\N	G3154	71708	2	1	\N	839ad74b9e5207ba7fad9711c16b3c7b
15362	(#11.3)	\N	7	2007	\N	\N	15336	11	3	\N	7c1c67601dcc0307b96cfd1a82bfbfe5
107765	(#3.9)	\N	7	1986	\N	\N	107724	3	9	\N	7000143f76038e6842cf0e2998dda3ad
73109	First Half Preliminary Round 1: Hund vs. Perry/Shumski vs. Williams	\N	7	1989	\N	F6234	73091	1	1	\N	462f94769fe7f8c6adca6e6c9b6886e5
181416	La felicitat	\N	7	2010	\N	F423	181409	1	13	\N	d75e24859670d7d6286ffda1e69e27fa
943	Encounter	\N	7	2002	\N	E5253	934	1	6	\N	22f90fecb3b7cfb83624e496a1a2dcdb
38108	(2007-10-23)	\N	7	2007	\N	\N	38084	\N	\N	\N	626f2f23137f94dbca4652f3eb990ce7
128892	(2000-10-18)	\N	7	2000	\N	\N	128714	\N	\N	\N	b224d82c71be7e9369d4931cf8c021a5
139723	Parkinson's Disease	\N	7	2008	\N	P6252	139678	2	4	\N	7b0bb9e9a1d95713c27bda626e3f15ba
102772	La Perle du venin	\N	7	2003	\N	P6431	102764	1	5	\N	37f2e158df600a10028a53d9f40f2137
6111	1996 UEFA European Football Championship	\N	2	1996	\N	U1615	\N	\N	\N	1996-????	f88a11e54b9e69f508f8be2bd903c096
139353	(2006-05-15)	\N	7	2006	\N	\N	139148	\N	\N	\N	b74f07145ced11b66893049aefe839a9
44046	How Chelsea Got Her Groove Back	\N	7	2013	\N	H2423	44034	3	3	\N	6d0856d8d9cc68cb70904d20b7f8be9b
104089	(#1.13272)	\N	7	2008	\N	\N	103385	1	13272	\N	ec63cc8585fde3c6247b11a6b55a02d4
195488	(#15.7)	\N	7	2011	\N	\N	195332	15	7	\N	aa4b83873b99c9cda71eff266395ee92
39552	ActorsE Chat: Bill Hooey/Mary Jo Gruber	\N	7	2011	\N	A2362	39009	3	31	\N	553b10324bc34d12727325bde008c0ad
82304	(#6.25)	\N	7	1980	\N	\N	82255	6	25	\N	b9af26b2498fba33a6cbd1a6a71472ed
171398	Stallion	\N	7	1972	\N	S345	171195	14	8	\N	702cd390dc88bdd36b7238e5bb50f6a4
23271	(#1.148)	\N	7	2008	\N	\N	23216	1	148	\N	733b712123d9f988b17a005e782257b4
131789	(#1.31)	\N	7	2001	\N	\N	131764	1	31	\N	27dd968dcc9cc7e364da033da7fbad95
188464	Norfolk	\N	7	2007	\N	N6142	188443	3	5	\N	00ed0bea52e7e7fad5a3f51c8bc0e0b8
182463	Irish Baby	\N	7	2005	\N	I621	182425	\N	\N	\N	a38f4a6b9a8fba73f650539c57f06d52
191242	Hit the Fan	\N	7	2012	\N	H315	191235	1	13	\N	9a4d112e254cae51da1daeb0aaf8c74a
26433	(#1.1)	\N	7	2005	\N	\N	26432	1	1	\N	397e88ba77f43a7e09c229ae1349592b
46658	Otoko no jierashi	\N	7	2004	\N	O3252	46614	1	33	\N	071783138a9273983035e92cde7bffb5
109761	(2012-08-12)	\N	7	2012	\N	\N	109693	\N	\N	\N	7407c2550fe73e8d73f4235a4f4566ce
142828	(2006-02-02)	\N	7	2006	\N	\N	142752	\N	\N	\N	8833be660537da5063a83f18ced31fe9
68483	(2013-03-12)	\N	7	2013	\N	\N	68184	\N	\N	\N	fe82a8ecd042777a7c458bcb25e1f37a
199769	O Banho	\N	7	1995	\N	B5	199754	1	6	\N	9c4509d881bce44cc40a91905deb77a2
4683	(#1.3)	\N	7	2012	\N	\N	4680	1	3	\N	9be428905f93a6e731e371b2900bbe82
131037	(#1.6241)	\N	7	2012	\N	\N	130636	1	6241	\N	235146197e96b0abb9d440259913fe2e
156746	(2008-12-19)	\N	7	2008	\N	\N	156714	\N	\N	\N	e474b7531d6faf3a3da55631189a224a
156596	Von der Walhalla zum Gäuboden	\N	7	2001	\N	V5364	156260	\N	\N	\N	26bd153b1acd3ae6ae7a0775a20d11d1
126438	(#2.211)	\N	7	1959	\N	\N	126283	2	211	\N	39c51531ef3fefa6488c27e97c6deeea
110418	Little Treasures	\N	7	2003	\N	L3436	110406	1	22	\N	29717840bbb9757023e862453ff99380
172714	Book Club Reads... 'Cougar Enchantments' by Del Mari Fuentes	\N	7	2012	\N	B2416	172708	1	4	\N	eb1bbaa142c89c9d75ef164985b3ad89
150436	(#1.7)	\N	7	2013	\N	\N	150427	1	7	\N	ab8a8b3b624f68ed2db34b1252207b74
18161	¿Por qué lo llamarán sexo si estamos hablando de coches?	\N	7	1999	\N	P6245	17959	1	13	\N	15e4d41fcb82e59c8456abf6afa6d6e5
146433	(#10.4)	\N	7	2003	\N	\N	146429	10	4	\N	eeef6dfdd59056778501d91071fe94c0
97365	Lifeguard Week	\N	7	2010	\N	L1263	97178	\N	\N	\N	1c54fa269c31318f27001a13ca3d3811
106810	(2004-03-21)	\N	7	2004	\N	\N	106808	\N	\N	\N	0129e32918d7e9f508b2ea7b2732da3f
38253	(2008-06-04)	\N	7	2008	\N	\N	38084	\N	\N	\N	51b77d77544f4cbb0ffa206b3c44c70b
42023	The Wildest West	\N	7	\N	\N	W4323	41997	1	8	\N	546a538690aa4bbe6ed52f176b9a72b6
14316	(2010-09-13)	\N	7	2010	\N	\N	14095	\N	\N	\N	20b331fc616463426f10c7c981628796
56302	(#1.10526)	\N	7	2010	\N	\N	55774	1	10526	\N	3088a0207fb3abefdd8e749c4e2f7d8d
158472	(#1.6)	\N	7	2005	\N	\N	158450	1	6	\N	dcdb7d5ce53f9bf88c5d70406a29d863
114958	Up Close & Personal Special	\N	7	2004	\N	U1242	114735	2	29	\N	0c64e59292077ff0d74f69682acb77bd
136413	(2010-01-13)	\N	7	2010	\N	\N	136411	\N	\N	\N	dfa812f4906e90ffe01b9123c3b81481
126862	(#9.52)	\N	7	1966	\N	\N	126283	9	52	\N	ae0fdd4ee0415edda95c2107fc9ec462
94857	(2001-11-23)	\N	7	2001	\N	\N	94664	\N	\N	\N	eed6f4d08558e7311fd36c209ab9185d
45927	aHA! Award 08: Part 2	\N	7	2008	\N	A6316	45903	6	12	\N	1384cb391109aece5bb99b68e6dd68f7
139524	Meet Woody	\N	7	2012	\N	M3	139517	2	5	\N	af9e94a82d33703355734b29ed957231
196559	(2011-10-15)	\N	7	2011	\N	\N	196548	\N	\N	\N	01c9ef03f277ef4c5fba1b18d40dfd7b
197889	The Richmond File: Call Me Enemy	\N	7	1972	\N	R2531	197853	4	11	\N	041a056c02d50d206c6df300e1f621e7
178833	(2004-10-05)	\N	7	2004	\N	\N	178599	\N	\N	\N	8fb1548aed1ba68e5ece62e0a4582ffd
146154	Pilot	\N	7	1981	\N	P43	146146	1	1	\N	42d3ee9c53ccf19634ee5334b370ff1c
127590	(#2.3)	\N	7	2001	\N	\N	127577	2	3	\N	6b0e8438b9799265a55fd39a734d85cb
148784	Beyaz Gelincik	\N	2	2005	\N	B2452	\N	\N	\N	2005-2007	5484638cb8402c02659660e168f0d2a9
129819	Honeymoon with Death	\N	7	1975	\N	H53	129744	4	5	\N	c6f480a04e6495b3757258e26fd2e12f
99821	(2008-10-21)	\N	7	2008	\N	\N	99703	\N	\N	\N	44437f25ffed8174bb872f9ac3e3eb86
60080	Struppi und der kleine Bruder	\N	7	1969	\N	S3615	60069	1	5	\N	bdda5ad5328812667c4653c863ee4a0c
55147	The Scare	\N	7	2001	\N	S26	55135	1	10	\N	aef0cee1212616179b9d4572ee3bec1c
21290	Give Me Shelter: Part 2	\N	7	1989	\N	G1524	20918	9	46	\N	1bd11d28b375eaf3e4f872a3686f88e7
198324	(1999-02-23)	\N	7	1999	\N	\N	198109	\N	\N	\N	5ba49b881dc0d2b59b9cc23190c8d6e6
145951	(#1.1)	\N	7	2000	\N	\N	145950	1	1	\N	ec452beead0aa33b92ffcc00fa16cf69
58788	Awake in Fright	\N	7	2009	\N	A2516	58754	12	7	\N	f79efcaef491f4af5080f14ca40ad16d
126355	(#12.51)	\N	7	1969	\N	\N	126283	12	51	\N	6128818f3af80bfcc2afd7659b9860c6
155595	Too Old for Work?	\N	7	1955	\N	T4316	155360	5	29	\N	3624de67bf83505d2f9cd898945e1562
9048	(#1.21)	\N	7	2008	\N	\N	9046	1	21	\N	30915fdc00ce11febbc684a36bc68536
133367	(#3.3)	\N	7	2010	\N	\N	133358	3	3	\N	f8b1f9b7c112d73c4f10d3e471bc8b2f
2786	100 mexicanos dijeron	\N	2	2001	\N	M2523	\N	\N	\N	2001-2005	52cf4b93e106cdae054c94a814db7cb0
195871	(2008-01-09)	\N	7	2008	\N	\N	195563	\N	\N	\N	cff929514a72920470fcfe2ff98e9bff
77400	(#1.75)	\N	7	2001	\N	\N	77360	1	75	\N	70e930564536fdc1e6fe306c99e36c76
72354	Free Rick	\N	7	2011	\N	F62	72345	2	19	\N	10feeccc19fa06cbc165481492fd06b7
124954	(#1.3)	\N	7	1989	\N	\N	124950	1	3	\N	1c5d97c9bfaf9b34e313a1ef9da799ea
16279	Pelican Bay/Cleaning Up/China Syndrome	\N	7	1993	\N	P4251	15711	25	52	\N	4d2165c6b12f98241dca67a08200e7ff
112461	La queue du diable	\N	7	1980	\N	Q314	112272	\N	\N	\N	be5481f850bc3c6d8f11407fc4589940
17704	(1985-09-15)	\N	7	1985	\N	\N	17625	\N	\N	\N	61742c28d280c1b51f0baaae5e351527
165510	(#1.4)	\N	7	1997	\N	\N	165506	1	4	\N	093ef893c69e9589350af8efd43f52f4
24356	Kilopták a kislányomat a babakocsiból!	\N	7	2012	\N	K4132	24345	1	11	\N	bb6b8c0e5832911f73869a477c10de36
40610	(#3.3)	\N	7	2013	\N	\N	40580	3	3	\N	7fecd4d278753cf14cd57e45f0646d92
145117	The Motorboat	\N	7	\N	\N	M3613	145076	\N	\N	\N	56b4a0b575dc7c5bb1c17557e91afb5a
123870	Baila Comigo	\N	2	1981	\N	B4252	\N	\N	\N	1981-????	ea4bd80e9bb75c5bcee3d9f8d3578585
23127	A Família Boaventura	\N	2	1956	\N	F5415	\N	\N	\N	1956-????	61a79c724ded62c245d7ccaa1eeafdb6
9661	Saturday Night and Sunday Morning	\N	7	1991	\N	S3635	9632	1	2	\N	17c81feccc88a07818a4a41039ef5874
115388	Woman of Steel	\N	7	2008	\N	W5123	114979	13	11	\N	acec4710acfccf2c2352d861312ca14f
9018	Absent Without Leave	\N	7	1963	\N	A1253	9014	1	9	\N	644b98b2b70093726317092be0295beb
14049	5 News Lunchtime - 27 February 2012	\N	7	2012	\N	N2452	13977	\N	\N	\N	d70c39b6a0b9bddbba507847c783cae0
174315	Lo scalatore delle Ande	\N	7	2007	\N	S2436	174287	1	3	\N	973ed3fd62c13574bb8a8a5a7eee9308
56084	(#1.10308)	\N	7	2010	\N	\N	55774	1	10308	\N	9392157a2d7b7e966d4888106e1bdbf8
136325	(2010-05-16)	\N	7	2010	\N	\N	136169	\N	\N	\N	26c727981ef337cd7c65df3677d1168a
59280	(#1.5)	\N	7	2006	\N	\N	59275	1	5	\N	b1a455743d6244438af4e033aa8406b0
32988	(2013-03-03)	\N	7	2013	\N	\N	32442	\N	\N	\N	e377612c0484d42960a221d5caeec951
120748	Not Married with Children	\N	7	1991	\N	N3563	120735	1	20	\N	2dd8c1391fb9418dc75dba91b26654b7
30933	A Winter Harvest	\N	2	1984	\N	W5361	\N	\N	\N	1984-????	94767933a8d3fe1711403687d10ffcde
142755	(2005-11-09)	\N	7	2005	\N	\N	142752	\N	\N	\N	610d7812a1ef1b91353bef5f4951ca3f
33741	Hollywood Sign Land Sale	\N	7	2008	\N	H4325	33102	\N	\N	\N	d7c5fc321a07bf8d2e0c43afbac44e91
83179	(#1.8)	\N	7	2006	\N	\N	83167	1	8	\N	9ec7be0946a241e5428e33efdcd11bd5
141034	Safe House	\N	7	2012	\N	S12	141013	\N	\N	\N	28e8e2c4751ab91c8a268e24f2c73c2f
22210	(1990-12-03)	\N	7	1990	\N	\N	22209	\N	\N	\N	70fc63d91a30ae9ccd818007f1605403
184043	Brookside	\N	2	1982	\N	B623	\N	\N	\N	1982-2003	a083a9273a02f9a255858e674703094a
86191	(#1.29)	\N	7	2008	\N	\N	86169	1	29	\N	0b37ffee01b13b41ced692f0e65bf12f
95682	(1995-12-22)	\N	7	1995	\N	\N	95670	\N	\N	\N	16903230b94aa0a48fe17769d8e35b9c
110010	25 Years of Margaret & David	\N	7	2011	\N	Y6215	109984	8	38	\N	1672ff7fb1ec6c7994514f65e1c35226
125118	High-Flying Rookie	\N	7	1976	\N	H2145	125116	1	3	\N	64433c565fa5ee2d5ddfada4f8316d7a
124250	The Bust	\N	7	1993	\N	B23	124242	1	6	\N	587de3bc953f4c13786705f601b7c7b3
24550	(#2.13)	\N	7	2006	\N	\N	24546	2	13	\N	f1940ea13c5fb8fd0116a5c33501d5c5
176693	The Meat of the Matter	\N	7	2001	\N	M3135	176676	1	5	\N	3d65dd386e4ab79ff64c8223fef3b781
111325	(#1.767)	\N	7	2008	\N	\N	111095	1	767	\N	dbf1ec01f25cde4690e72af62b022f53
193561	The Case of Robbery after Death: Part 2	\N	7	2003	\N	C2161	192964	1	288	\N	be72731755a97f51cf3f193e0f91b7f0
86207	Annemi hatirliyorum	\N	2	1977	\N	A5364	\N	\N	\N	1977-????	b79b552cf1b74926abfba6493e7d3cd2
53538	De watersnood	\N	7	1990	\N	W3625	53511	2	18	\N	a16bbf59ee573882feeae7c8018fa490
74864	(2007-08-31)	\N	7	2007	\N	\N	74718	\N	\N	\N	9fe46e78d340ea8626b8561d72ec6aed
32599	(2012-02-07)	\N	7	2012	\N	\N	32442	\N	\N	\N	863d63ca0cee3e4006f98826f0eb00dc
152298	(#1.37)	\N	7	2000	\N	\N	152267	1	37	\N	0ffe3ce668e9a3a9ab8a331ae20e45cc
65805	(2011-02-14)	\N	7	2011	\N	\N	65509	\N	\N	\N	54e03fe72baf07857a63ef7d6c4b0980
186547	Buchanan High	\N	2	1984	\N	B252	\N	\N	\N	1984-????	9a83246f419667b289d3717e49c6c2d5
1855	Dog Alone	\N	7	2009	\N	D245	1852	1	6	\N	175782a6b387acd7c1435bb915f1725b
116717	Des hommes amoureux	\N	7	2000	\N	D2525	116702	3	6	\N	146ee7cd10bdd286f1bdaeb990d78181
9926	The Jarman Award: The Necromancers	\N	7	2010	\N	J6563	9883	\N	\N	\N	af721699c5f57f3d188e241298b51f5d
3126	(#2.43)	\N	7	2007	\N	\N	3083	2	43	\N	caecd99ebdb9b3bf96dbbb33637529c6
102348	(2005-10-31)	\N	7	2005	\N	\N	102292	\N	\N	\N	5723401048639674da3a3552c6b1046f
130117	Keep on Truckin'	\N	7	2004	\N	K1536	129983	9	9	\N	ca5047430d2fe4cfdf9498156c6267d4
137475	School's In	\N	7	2010	\N	S2425	137414	4	3	\N	21794e9d27fb8e69852d6bc0be2e640d
189120	(#3.22)	\N	7	1984	\N	\N	189078	3	22	\N	d3d4573ac80a963c8bbc6c0a99d5fdd4
185331	Safe at Home	\N	7	2011	\N	S135	185257	5	13	\N	934bc7373e5c9d088a4678cab9bfec84
138336	Villa Maria Christina	\N	7	2011	\N	V4562	138209	10	1	\N	00423244f092a5ee8340b8b4ac51a755
68943	Missing Tools/Funeral Singer	\N	7	2012	\N	M2523	68757	3	7	\N	2c7caf791bdd030d3fae6bf1c87e56a2
52781	Solliciteren is een kunst	\N	7	\N	\N	S4236	52770	1	1	\N	260c0cac930c75c8afc64897f4296ed1
127088	(2006-01-16)	\N	7	2006	\N	\N	126998	\N	\N	\N	5ca213be57d748380cd6b53a27864b35
198093	(#1.85)	\N	7	\N	\N	\N	197955	1	85	\N	6cc275d74441cad999043eee9131043f
180583	Decision Time	\N	7	2012	\N	D2535	180581	1	8	\N	68009b4c96e1e9228c22171b8460b306
110126	(#1.15)	\N	7	2008	\N	\N	110119	1	15	\N	6c2c0e56493a28eed6297c94d27d8c26
111841	(2012-05-14)	\N	7	2012	\N	\N	111095	\N	\N	\N	841ceb30a090e5601376b5f86a2944cf
44472	E Pluribus Unum	\N	7	1993	\N	E1461	44469	1	7	\N	cf1a06f3b9a556a5b20306ab6df2a9b7
178658	(2001-09-06)	\N	7	2001	\N	\N	178599	\N	\N	\N	1377141468ad57bf6617a26efc759e39
197944	(2013-01-28)	\N	7	2013	\N	\N	197899	\N	\N	\N	0367ccc176e0f07653a31a1ed869966d
65104	(#1.91)	\N	7	1998	\N	\N	64962	1	91	\N	92ac7aad828772a7985dd6c9a5862af4
107630	De webcammoord	\N	7	2007	\N	W1256	107585	3	2	\N	96eaf92827f6cb4b53bbb68a7c10f229
181496	(1998-02-08)	\N	7	1998	\N	\N	181423	\N	\N	\N	57dfb71bad51e4866876d78bdefb84e0
148782	Ringer	\N	7	1993	\N	R526	148765	1	11	\N	59bff2399fa7ef09986aac837bc2adef
82595	(#1.12)	\N	7	2011	\N	\N	82591	1	12	\N	62ca195590cd4456471d7c2856454576
75020	One Pony Town	\N	7	2010	\N	O5153	74959	2	8	\N	a06312d294d946353e1f6eee32b56453
45173	Agria paidia	\N	2	2008	\N	A2613	\N	\N	\N	2008-????	78d95971971f8d5f65b601134aad8ce9
89915	(2004-03-02)	\N	7	2004	\N	\N	87087	\N	\N	\N	3cb5e841cd96d81430cad4befb5a2ef9
99476	Sell Mates	\N	7	1970	\N	S4532	99451	1	12	\N	51c25bf9b58ad75b1f68517e2b68744d
74356	The Wife Who Knew Too Much	\N	7	\N	\N	W1253	74241	\N	\N	\N	509278f955ab126d2d1c90ac4807dd71
99003	Fairy Tale	\N	7	1952	\N	F634	98906	2	38	\N	4d66779d5e98d9a8bdd8450cd68f1480
14146	(2009-08-31)	\N	7	2009	\N	\N	14095	\N	\N	\N	181812f7bb1b037f971afa8d0bba9da7
119296	Danzad, danzad, malditas	\N	7	2008	\N	D5235	119249	5	22	\N	eea2213070085feb85700d2acd1f44a2
31562	(#1.7)	\N	7	2005	\N	\N	31555	1	7	\N	af9b8cbeb23c77428b0788d6c7e20db9
183347	A Vegetarian at My Table	\N	7	2009	\N	V2365	183343	5	2	\N	2cd48f9e92806507317dd693e1ed5150
68168	The Gangs of Iraq	\N	7	\N	\N	G5216	68151	1	4	\N	8084dfaa8fc5132647f54a1b4154b7af
43420	(2009-09-16)	\N	7	2009	\N	\N	43320	\N	\N	\N	feb033dc4140c3f1be7186a70a9cadb5
1536	1+1=1	\N	2	1981	\N	\N	\N	\N	\N	1981-1982	8e2510ae514287e1c550e43684a6b520
142329	Mad Harry's Out	\N	7	1981	\N	M3623	142316	1	3	\N	34ddc8eceb4bd8827eae77e49d363205
116565	La foto del benessere	\N	7	2005	\N	F3415	116552	2	5	\N	498cab4e7ce0c08f79abac5df68954fe
29831	(2005-05-04)	\N	7	2005	\N	\N	29216	\N	\N	\N	467799d7b370c7522ff9bcc45e9e5648
94181	(2004-05-26)	\N	7	2004	\N	\N	93972	\N	\N	\N	535ffcfee2275ae9f33b347207c49b6f
107944	Assassins	\N	2	2011	\N	A252	\N	\N	\N	2011-????	38fc08f3f1ed5ab0ee731676eb435c67
70754	Keir Dulea Sanders/Enrique Casas	\N	7	1988	\N	K6342	70344	2	40	\N	226af242ea66bbcf31a63150720a52c6
17237	Boo, Dude!	\N	7	2004	\N	B3	17206	1	24	\N	b9868db83f5c872146d943114ff754d8
90183	(2005-02-06)	\N	7	2005	\N	\N	87087	\N	\N	\N	f2b3403a8279c08dd9e8c4aa9bd71859
37994	Drew Seeley	\N	7	2011	\N	D624	37984	\N	\N	\N	5197bab91653dde1df417c9b50cf966f
34294	Die Sommergäste kommen	\N	7	2005	\N	S5623	34290	1	2	\N	fe04b50dea97916f1775d18d3f9d2fa7
158797	Bill Robinson: Mr. Bojangles	\N	7	1998	\N	B4615	158683	\N	\N	\N	fe3c013db69cedfb83f4446b30042e39
2963	Death Gets Busy	\N	7	2009	\N	D3232	2931	1	6	\N	a8e3d6656c3ac00eb6c2eeb864d84205
60869	Allez à L.A.!	\N	2	2008	\N	A424	\N	\N	\N	2008-????	a57a0e7e60c1644a9742ddb45cba3980
132113	(#2.6)	\N	7	2007	\N	\N	132101	2	6	\N	3ff1aba83d0835f5f8c75e13ef3f1602
24686	(2004-08-10)	\N	7	2004	\N	\N	24669	\N	\N	\N	e7e99c6f817fd7ac6b6a10a6f1acf3f4
1595	I Thought I Knew You	\N	7	2003	\N	T2325	1576	1	4	\N	4dbac8026222048a1ed7caff61904fd2
119257	Alargador domingo de noviazgo	\N	7	2011	\N	A4623	119249	8	26	\N	11714b4597de7c8363596252a6bde1e4
165928	Rogi, shûrai	\N	7	2007	\N	R26	165892	1	10	\N	e05d7607641ce7c31191daaa2921bd98
109995	(#1.9)	\N	7	2004	\N	\N	109984	1	9	\N	ac8e44ad8ae8d94bb97ac787294fb260
40516	Keep on Truckin'	\N	7	1991	\N	K1536	40489	1	16	\N	f09892b607880662ea23d93e9616e9ea
45533	(2006-01-21)	\N	7	2006	\N	\N	45248	\N	\N	\N	2ef6a6a60030b12a4ca1f8d0251fd8c8
193606	The Case of the Dead Body in Lift: Part 1	\N	7	2001	\N	C2131	192964	1	173	\N	2f6d3ca427439d1015883d97a6858e84
195602	(1997-09-21)	\N	7	1997	\N	\N	195563	\N	\N	\N	e1c63cc4990b94372ffd85e8b0d4d638
151034	The Hiccups	\N	7	2011	\N	H212	150977	3	13	\N	7dcd3562bde1b48610294f677ca505cd
142008	(#1.85)	\N	7	2009	\N	\N	141924	1	85	\N	45eeab3e1852108b7d313fe396cfefd6
66638	Manolita se sorprendre al verse al periódico	\N	7	2010	\N	M5432	65509	\N	\N	\N	a2d72c55c3b53abc63a1ccb390d1ea54
140924	Queen Latifah	\N	7	2000	\N	Q5431	140768	3	37	\N	0203cbf1d33392f9d0b794205bb4200c
36786	(2012-06-19)	\N	7	2012	\N	\N	36138	\N	\N	\N	b080458438db10d7c1b2b0918ba29d89
114936	Top 8 Performance Show: Disco	\N	7	2006	\N	T1616	114735	4	22	\N	feb4d24b208b65bfda67b9475361477a
24783	(2004-12-30)	\N	7	2004	\N	\N	24669	\N	\N	\N	bada06c399e213bbed306ac420012716
149253	The Color of Mad	\N	7	1992	\N	C4615	149217	1	20	\N	d388c64ecddefe4d860301a3a91f74ef
74586	Jasper Johns: Ideas in Paint	\N	7	1989	\N	J2162	74512	4	6	\N	dda20c82f774bb2f22d0f8bd998e9b38
46116	(2000-11-20)	\N	7	2000	\N	\N	46022	\N	\N	\N	d385ac6d2e8d0ecc06b798dd24c07573
164455	(#2.57)	\N	7	\N	\N	\N	164254	2	57	\N	8b0095d4a13d359e464a09ba001fbc76
134070	(#1.83)	\N	7	2004	\N	\N	133903	1	83	\N	95e420bbaab3808679dba6c52acc1066
82678	Defying Gravity	\N	7	2010	\N	D1526	82668	\N	\N	\N	2bbbc6254e36bba89beec8ffbcd86765
102461	(#1.14)	\N	7	1992	\N	\N	102455	1	14	\N	3f88767748a7f2a753e3be69a4353150
121028	Pilot	\N	7	2012	\N	P43	121014	1	1	\N	87bc7e4f21025df66c9c7b69931e65d3
67380	Amazing Eats	\N	2	2012	\N	A5252	\N	\N	\N	2012-????	a8f8934df236db05cdc35db71b8a398a
124556	Merî Abaremasu! Jamejame	\N	7	2003	\N	M6165	124518	1	41	\N	881cf355d9fcee95583ebe530fd0b752
16598	The New Boss/The Harlem Children's Zone/Not Ready to Make Nice	\N	7	2006	\N	N1236	15711	38	34	\N	68ad9ffa6271cf18644d02a9ec3c9a35
27503	(#38.4)	\N	7	2008	\N	\N	27305	38	4	\N	ec21ef27a3ff97fd7976043af1548343
198816	(#1.27)	\N	7	2009	\N	\N	198734	1	27	\N	c01f7f8f26a8351dec8c75740fcfe708
148787	(#1.11)	\N	7	2005	\N	\N	148784	1	11	\N	6a3d7f8dae32878c901f1d4003123d36
117211	The Booty Call	\N	7	2011	\N	B324	117207	2	2	\N	fb59cfaca54ba509bbc74e69b8b9e862
142568	(1993-08-23)	\N	7	1993	\N	\N	142541	\N	\N	\N	28c360d834820eff94a004372ae30f3e
180255	(2011-03-19)	\N	7	2011	\N	\N	178599	\N	\N	\N	8ccf94dad5d72a5a694e429ebaefeace
147735	(#2.6)	\N	7	2008	\N	\N	147712	2	6	\N	1118ac15e34449ccbda58ff5a98bf5a7
82713	A colorear el cielo	\N	7	2010	\N	C4642	82712	2	4	\N	026f7ea5b7301da50d0472e215e8bb8c
192583	Grand jeu pour jour J	\N	7	1996	\N	G6532	192556	1	6	\N	daa4890085ab8e892bbc49e90a938476
48505	Akai giwaku	\N	2	1975	\N	A2	\N	\N	\N	1975-1976	4cdd1f5be02fa7d09aa87bad110a5747
422	De zaak van de beschadigde bokser	\N	7	1969	\N	Z2153	419	1	2	\N	1b7a8791954f88a290a7c06fd95b1ea6
101709	Het patroon	\N	7	1964	\N	P365	101705	1	9	\N	4bec7298f4fde8e299a6b6333030e104
58713	(#3.10)	\N	7	2013	\N	\N	58711	3	10	\N	070c93497894cab6440d43aa36f3998a
143833	Chain of Command	\N	7	1980	\N	C5125	143813	1	15	\N	04c615ba3f9940e3bc8e7a223417b285
82635	Love Bite	\N	7	1999	\N	L13	82608	1	17	\N	4a5866b26d528120c704b8dd1ca83e47
11912	Sicher, sauber, unerträglich - Leben unter Zwang	\N	7	2005	\N	S2621	11752	\N	\N	\N	c3c11309ac94c54532adfd8ba10e998e
49968	(2007-07-16)	\N	7	2007	\N	\N	49889	\N	\N	\N	a044182b7ee6615fcf9efcabb1a887f8
157005	(1962-04-28)	\N	7	1962	\N	\N	156990	\N	\N	\N	c96129bf3aee46f1781744dae2808a43
190099	Burger Quiz	\N	2	2001	\N	B6262	\N	\N	\N	2001-2002	d0390501fdb806b6c2b1a71ba3c0f1a4
196850	Blossom Trails	\N	7	\N	\N	B4253	196812	\N	\N	\N	fa9b77e48479b382a5be9d441a7c5107
16387	SpaceX/The Murder of an American Nazi/Angelina	\N	7	2012	\N	S1235	15711	44	38	\N	952c537e481ca163a71cc62f8a208a47
43732	(2012-05-16)	\N	7	2012	\N	\N	43320	\N	\N	\N	cb8667c33a219a388bf81b803539fad1
154139	(#2.25)	\N	7	\N	\N	\N	154132	2	25	\N	21e71ad24a6265ea1ace06b2523b8b7f
5712	1972 World Series	\N	2	1972	\N	W6432	\N	\N	\N	1972-????	3dce11595fa8e5470c442520e5d19f2a
88596	(1999-11-16)	\N	7	1999	\N	\N	87087	\N	\N	\N	ec999a934c7e09c64173a44e90f69462
89755	(2003-06-23)	\N	7	2003	\N	\N	87087	\N	\N	\N	f5b64d2e79eb04dd03bfc13bc96063eb
80215	(2012-06-14)	\N	7	2012	\N	\N	79712	\N	\N	\N	58759c780e62dd34fc7443edb1594ae9
131301	Misatsu no kagerô	\N	7	2005	\N	M2325	131289	1	21	\N	1f44d06fecf91968216ef7b67dfb697e
54982	Ritz Carlton Spa	\N	7	2004	\N	R3264	54958	\N	\N	\N	e4918304e4a7a5bc0990e49a783072ea
37238	Deal with the Devlins	\N	7	2003	\N	D4314	37204	2	22	\N	b7058bdaeb3e4692e3f9fb0240317e85
175042	HHHHBBHHBBHU	\N	7	1996	\N	H1	175023	1	21	\N	c71e8377572a0d839a28ce8c420bdf26
119731	(#7.7)	\N	7	2011	\N	\N	119552	7	7	\N	1a2110d9f1a60ea9cd1de5a1a3c3c626
168892	(2010-11-14)	\N	7	2010	\N	\N	168850	\N	\N	\N	31a02d27523ba6e05ed4dd4b66dee09d
73578	Tricks and Treats	\N	7	2012	\N	T6253	73554	2	2	\N	8d438a090f0b428891de0965b93bd970
95194	(2004-03-25)	\N	7	2004	\N	\N	94664	\N	\N	\N	c21b3bb7c458d37b7454ed040701ba92
\.


--
-- Name: aka_name aka_name_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aka_name
    ADD CONSTRAINT aka_name_pkey PRIMARY KEY (id);


--
-- Name: aka_title aka_title_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aka_title
    ADD CONSTRAINT aka_title_pkey PRIMARY KEY (id);


--
-- Name: cast_info cast_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cast_info
    ADD CONSTRAINT cast_info_pkey PRIMARY KEY (id);


--
-- Name: char_name char_name_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.char_name
    ADD CONSTRAINT char_name_pkey PRIMARY KEY (id);


--
-- Name: comp_cast_type comp_cast_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_cast_type
    ADD CONSTRAINT comp_cast_type_pkey PRIMARY KEY (id);


--
-- Name: company_name company_name_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_name
    ADD CONSTRAINT company_name_pkey PRIMARY KEY (id);


--
-- Name: company_type company_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_type
    ADD CONSTRAINT company_type_pkey PRIMARY KEY (id);


--
-- Name: complete_cast complete_cast_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complete_cast
    ADD CONSTRAINT complete_cast_pkey PRIMARY KEY (id);


--
-- Name: info_type info_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.info_type
    ADD CONSTRAINT info_type_pkey PRIMARY KEY (id);


--
-- Name: keyword keyword_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.keyword
    ADD CONSTRAINT keyword_pkey PRIMARY KEY (id);


--
-- Name: kind_type kind_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kind_type
    ADD CONSTRAINT kind_type_pkey PRIMARY KEY (id);


--
-- Name: link_type link_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.link_type
    ADD CONSTRAINT link_type_pkey PRIMARY KEY (id);


--
-- Name: movie_companies movie_companies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movie_companies
    ADD CONSTRAINT movie_companies_pkey PRIMARY KEY (id);


--
-- Name: movie_info_idx movie_info_idx_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movie_info_idx
    ADD CONSTRAINT movie_info_idx_pkey PRIMARY KEY (id);


--
-- Name: movie_info movie_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movie_info
    ADD CONSTRAINT movie_info_pkey PRIMARY KEY (id);


--
-- Name: movie_keyword movie_keyword_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movie_keyword
    ADD CONSTRAINT movie_keyword_pkey PRIMARY KEY (id);


--
-- Name: movie_link movie_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movie_link
    ADD CONSTRAINT movie_link_pkey PRIMARY KEY (id);


--
-- Name: name name_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.name
    ADD CONSTRAINT name_pkey PRIMARY KEY (id);


--
-- Name: person_info person_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person_info
    ADD CONSTRAINT person_info_pkey PRIMARY KEY (id);


--
-- Name: role_type role_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_type
    ADD CONSTRAINT role_type_pkey PRIMARY KEY (id);


--
-- Name: title title_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.title
    ADD CONSTRAINT title_pkey PRIMARY KEY (id);


--
-- Name: ci_movie_id_btree_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ci_movie_id_btree_index ON public.cast_info USING btree (movie_id);


--
-- Name: mc_movie_id_btree_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX mc_movie_id_btree_index ON public.movie_companies USING btree (movie_id);


--
-- Name: mi_idx_movie_id_btree_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX mi_idx_movie_id_btree_index ON public.movie_info_idx USING btree (movie_id);


--
-- Name: mi_movie_id_btree_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX mi_movie_id_btree_index ON public.movie_info USING btree (movie_id);


--
-- Name: mk_movie_id_btree_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX mk_movie_id_btree_index ON public.movie_keyword USING btree (movie_id);


--
-- PostgreSQL database dump complete
--

