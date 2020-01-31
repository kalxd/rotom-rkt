--
-- PostgreSQL database dump
--

-- Dumped from database version 11.4 (Debian 11.4-1)
-- Dumped by pg_dump version 11.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: 分组; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."分组" (
    id integer NOT NULL,
    "名字" text NOT NULL,
    "用户id" integer NOT NULL,
    "创建日期" timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT "分组_check" CHECK ((btrim('名字'::text) <> ''::text))
);


--
-- Name: 分组_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."分组_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: 分组_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."分组_id_seq" OWNED BY public."分组".id;


--
-- Name: 用户; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."用户" (
    id integer NOT NULL,
    "用户名" text NOT NULL,
    "创建日期" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: 用户_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."用户_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: 用户_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."用户_id_seq" OWNED BY public."用户".id;


--
-- Name: 用户_视图; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."用户_视图" AS
 SELECT "用户".id,
    "用户"."用户名",
    md5(("用户"."用户名" || "用户".id)) AS token,
    "用户"."创建日期"
   FROM public."用户";


--
-- Name: 表情; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."表情" (
    id integer NOT NULL,
    "名字" text NOT NULL,
    "链接" text NOT NULL,
    "分组id" integer NOT NULL,
    "创建日期" timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT "表情_链接_check" CHECK ((btrim("链接") <> ''::text))
);


--
-- Name: 表情_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."表情_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: 表情_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."表情_id_seq" OWNED BY public."表情".id;


--
-- Name: 分组 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."分组" ALTER COLUMN id SET DEFAULT nextval('public."分组_id_seq"'::regclass);


--
-- Name: 用户 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."用户" ALTER COLUMN id SET DEFAULT nextval('public."用户_id_seq"'::regclass);


--
-- Name: 表情 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."表情" ALTER COLUMN id SET DEFAULT nextval('public."表情_id_seq"'::regclass);


--
-- Name: 分组 分组_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."分组"
    ADD CONSTRAINT "分组_pkey" PRIMARY KEY (id);


--
-- Name: 用户 用户_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."用户"
    ADD CONSTRAINT "用户_pkey" PRIMARY KEY (id);


--
-- Name: 表情 表情_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."表情"
    ADD CONSTRAINT "表情_pkey" PRIMARY KEY (id);


--
-- Name: 分组 分组_用户id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."分组"
    ADD CONSTRAINT "分组_用户id_fkey" FOREIGN KEY ("用户id") REFERENCES public."用户"(id);


--
-- Name: 表情 表情_分组id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."表情"
    ADD CONSTRAINT "表情_分组id_fkey" FOREIGN KEY ("分组id") REFERENCES public."分组"(id);


--
-- PostgreSQL database dump complete
--

