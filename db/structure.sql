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

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: f_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
                SELECT public.immutable_unaccent(regdictionary 'public.unaccent', $1)
                $_$;


--
-- Name: immutable_unaccent(regdictionary, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.immutable_unaccent(regdictionary, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/unaccent', 'unaccent_dict';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    sex character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    age_min integer,
    age_max integer
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feedbacks (
    id integer NOT NULL,
    text text,
    email character varying,
    ip character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: feedbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.feedbacks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.feedbacks_id_seq OWNED BY public.feedbacks.id;


--
-- Name: geocode_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.geocode_results (
    id bigint NOT NULL,
    address character varying,
    response jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: geocode_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.geocode_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geocode_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.geocode_results_id_seq OWNED BY public.geocode_results.id;


--
-- Name: merge_runners_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merge_runners_requests (
    id integer NOT NULL,
    merged_first_name character varying,
    merged_last_name character varying,
    merged_club_or_hometown character varying,
    merged_nationality character varying,
    merged_sex character varying,
    merged_birth_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: merge_runners_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.merge_runners_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merge_runners_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.merge_runners_requests_id_seq OWNED BY public.merge_runners_requests.id;


--
-- Name: merge_runners_requests_runners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merge_runners_requests_runners (
    runner_id integer NOT NULL,
    merge_runners_request_id integer NOT NULL
);


--
-- Name: organizers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizers (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: organizers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizers_id_seq OWNED BY public.organizers.id;


--
-- Name: routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.routes (
    id integer NOT NULL,
    length double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: routes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.routes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.routes_id_seq OWNED BY public.routes.id;


--
-- Name: run_day_category_aggregates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.run_day_category_aggregates (
    id integer NOT NULL,
    category_id integer NOT NULL,
    run_day_id integer NOT NULL,
    mean_duration integer,
    runs_count integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    min_duration integer
);


--
-- Name: run_day_category_aggregates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.run_day_category_aggregates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: run_day_category_aggregates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.run_day_category_aggregates_id_seq OWNED BY public.run_day_category_aggregates.id;


--
-- Name: run_days; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.run_days (
    id integer NOT NULL,
    organizer_id integer,
    date date,
    weather character varying,
    route_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    alpha_foto_id character varying
);


--
-- Name: run_days_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.run_days_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: run_days_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.run_days_id_seq OWNED BY public.run_days.id;


--
-- Name: runners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.runners (
    id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    birth_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sex character varying,
    club_or_hometown character varying,
    nationality character varying,
    runs_count integer DEFAULT 0,
    geocode_result_id bigint
);


--
-- Name: runners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.runners_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: runners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.runners_id_seq OWNED BY public.runners.id;


--
-- Name: runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.runs (
    id integer NOT NULL,
    runner_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category_id integer,
    duration bigint,
    run_day_id integer,
    interim_times integer[],
    start_number integer
);


--
-- Name: runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.runs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.runs_id_seq OWNED BY public.runs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: feedbacks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks ALTER COLUMN id SET DEFAULT nextval('public.feedbacks_id_seq'::regclass);


--
-- Name: geocode_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geocode_results ALTER COLUMN id SET DEFAULT nextval('public.geocode_results_id_seq'::regclass);


--
-- Name: merge_runners_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merge_runners_requests ALTER COLUMN id SET DEFAULT nextval('public.merge_runners_requests_id_seq'::regclass);


--
-- Name: organizers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizers ALTER COLUMN id SET DEFAULT nextval('public.organizers_id_seq'::regclass);


--
-- Name: routes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routes ALTER COLUMN id SET DEFAULT nextval('public.routes_id_seq'::regclass);


--
-- Name: run_day_category_aggregates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.run_day_category_aggregates ALTER COLUMN id SET DEFAULT nextval('public.run_day_category_aggregates_id_seq'::regclass);


--
-- Name: run_days id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.run_days ALTER COLUMN id SET DEFAULT nextval('public.run_days_id_seq'::regclass);


--
-- Name: runners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runners ALTER COLUMN id SET DEFAULT nextval('public.runners_id_seq'::regclass);


--
-- Name: runs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runs ALTER COLUMN id SET DEFAULT nextval('public.runs_id_seq'::regclass);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: geocode_results geocode_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geocode_results
    ADD CONSTRAINT geocode_results_pkey PRIMARY KEY (id);


--
-- Name: merge_runners_requests merge_runners_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merge_runners_requests
    ADD CONSTRAINT merge_runners_requests_pkey PRIMARY KEY (id);


--
-- Name: organizers organizers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizers
    ADD CONSTRAINT organizers_pkey PRIMARY KEY (id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: run_day_category_aggregates run_day_category_aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.run_day_category_aggregates
    ADD CONSTRAINT run_day_category_aggregates_pkey PRIMARY KEY (id);


--
-- Name: run_days run_days_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.run_days
    ADD CONSTRAINT run_days_pkey PRIMARY KEY (id);


--
-- Name: runners runners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runners
    ADD CONSTRAINT runners_pkey PRIMARY KEY (id);


--
-- Name: runs runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT runs_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: index_admins_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admins_on_email ON public.admins USING btree (email);


--
-- Name: index_admins_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admins_on_reset_password_token ON public.admins USING btree (reset_password_token);


--
-- Name: index_run_day_category_aggregates_on_run_day_id_and_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_run_day_category_aggregates_on_run_day_id_and_category_id ON public.run_day_category_aggregates USING btree (run_day_id, category_id);


--
-- Name: index_run_days_on_organizer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_run_days_on_organizer_id ON public.run_days USING btree (organizer_id);


--
-- Name: index_run_days_on_route_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_run_days_on_route_id ON public.run_days USING btree (route_id);


--
-- Name: index_runners_on_club_or_hometown; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runners_on_club_or_hometown ON public.runners USING btree (club_or_hometown);


--
-- Name: index_runners_on_first_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runners_on_first_name ON public.runners USING btree (first_name);


--
-- Name: index_runners_on_geocode_result_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runners_on_geocode_result_id ON public.runners USING btree (geocode_result_id);


--
-- Name: index_runners_on_last_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runners_on_last_name ON public.runners USING btree (last_name);


--
-- Name: index_runners_on_nationality; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runners_on_nationality ON public.runners USING btree (nationality);


--
-- Name: index_runners_on_runs_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runners_on_runs_count ON public.runners USING btree (runs_count);


--
-- Name: index_runners_on_sex; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runners_on_sex ON public.runners USING btree (sex);


--
-- Name: index_runs_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runs_on_category_id ON public.runs USING btree (category_id);


--
-- Name: index_runs_on_run_day_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runs_on_run_day_id ON public.runs USING btree (run_day_id);


--
-- Name: index_runs_on_run_day_id_and_duration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runs_on_run_day_id_and_duration ON public.runs USING btree (run_day_id, duration);


--
-- Name: index_runs_on_runner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runs_on_runner_id ON public.runs USING btree (runner_id);


--
-- Name: runners_unaccent_concat_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX runners_unaccent_concat_gin_idx ON public.runners USING gin (public.f_unaccent((((((first_name)::text || ';'::text) || (last_name)::text) || ';'::text) || (club_or_hometown)::text)) public.gin_trgm_ops);


--
-- Name: runners fk_rails_606e0bc425; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runners
    ADD CONSTRAINT fk_rails_606e0bc425 FOREIGN KEY (geocode_result_id) REFERENCES public.geocode_results(id);


--
-- Name: runs fk_rails_7c3352bd6e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT fk_rails_7c3352bd6e FOREIGN KEY (run_day_id) REFERENCES public.run_days(id);


--
-- Name: run_days fk_rails_ae5be13faf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.run_days
    ADD CONSTRAINT fk_rails_ae5be13faf FOREIGN KEY (route_id) REFERENCES public.routes(id);


--
-- Name: run_days fk_rails_be5fa6c951; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.run_days
    ADD CONSTRAINT fk_rails_be5fa6c951 FOREIGN KEY (organizer_id) REFERENCES public.organizers(id);


--
-- Name: runs fk_rails_e5061847ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT fk_rails_e5061847ad FOREIGN KEY (runner_id) REFERENCES public.runners(id);


--
-- Name: runs fk_rails_eda834a081; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT fk_rails_eda834a081 FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20150521120128'),
('20150521154154'),
('20150525151343'),
('20150525155211'),
('20150525155233'),
('20150525160043'),
('20150818114548'),
('20150818122310'),
('20150821080852'),
('20150821082018'),
('20150821120523'),
('20150822114648'),
('20150823081526'),
('20150831131336'),
('20150831135119'),
('20150903070910'),
('20150907192559'),
('20150915161842'),
('20150919184314'),
('20160328202203'),
('20160331165854'),
('20160516132505'),
('20161124091625'),
('20181216151409'),
('20181229114139'),
('20200418192010'),
('20200505153123');


