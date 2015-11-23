--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    journal_id integer NOT NULL,
    by character varying NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    to_teacher boolean DEFAULT false,
    to_secondary_teacher boolean DEFAULT false
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE documents (
    id integer NOT NULL,
    title character varying,
    description text,
    attachment_file_name character varying,
    attachment_content_type character varying,
    attachment_file_size integer,
    attachment_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category character varying,
    subcategory character varying
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: journals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE journals (
    id integer NOT NULL,
    held_at date NOT NULL,
    start_at time without time zone,
    end_at time without time zone,
    duration integer NOT NULL,
    week integer NOT NULL,
    year integer NOT NULL,
    cancelled boolean DEFAULT false NOT NULL,
    goal text,
    subject text,
    method text,
    outcome text,
    note text,
    kid_id integer NOT NULL,
    mentor_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    month integer
);


--
-- Name: journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE journals_id_seq OWNED BY journals.id;


--
-- Name: kids; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE kids (
    id integer NOT NULL,
    name character varying,
    prename character varying,
    parent character varying,
    address character varying,
    sex character varying,
    grade character varying,
    available text,
    entered_at date,
    meeting_day integer,
    meeting_start_at time without time zone,
    mentor_id integer,
    secondary_mentor_id integer,
    teacher_id integer,
    secondary_teacher_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    phone character varying,
    secondary_active boolean DEFAULT false NOT NULL,
    dob date,
    language character varying,
    translator boolean,
    goal_1 text,
    goal_2 text,
    note text,
    city character varying,
    term character varying,
    inactive boolean DEFAULT false,
    todo text,
    relation_archive text,
    zip character varying,
    street_no character varying,
    checked_at date,
    coached_at date,
    abnormality text,
    abnormality_criticality integer,
    admin_id integer,
    school_id integer,
    exit character varying,
    exit_reason character varying,
    exit_kind character varying,
    exit_at date
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    type character varying,
    name character varying,
    prename character varying,
    address character varying,
    phone character varying,
    personnel_number character varying,
    field_of_study character varying,
    education character varying,
    available text,
    ects boolean,
    entry_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(128) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    absence text,
    city character varying,
    transport character varying,
    term character varying,
    dob date,
    inactive boolean DEFAULT false,
    todo text,
    substitute boolean DEFAULT false,
    zip character varying,
    street_no character varying,
    primary_kids_school_id integer,
    college character varying,
    school_id integer,
    note text,
    primary_kids_meeting_day integer,
    photo_file_name character varying,
    photo_content_type character varying,
    photo_file_size integer,
    photo_updated_at timestamp without time zone,
    receive_journals boolean DEFAULT false,
    primary_kids_admin_id integer,
    exit_kind character varying,
    exit_at date,
    sex character varying
);


--
-- Name: kid_mentor_relations; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW kid_mentor_relations AS
 SELECT kids.id AS kid_id,
    kids.exit_kind AS kid_exit_kind,
    kids.exit_at AS kid_exit_at,
    kids.school_id,
    kids.name AS kid_name,
    mentors.id AS mentor_id,
    mentors.exit_kind AS mentor_exit_kind,
    mentors.exit_at AS mentor_exit_at,
    mentors.name AS mentor_name,
    admins.id AS admin_id,
    "substring"((kids.term)::text, 6) AS simple_term
   FROM ((kids
     JOIN users mentors ON (((kids.mentor_id = mentors.id) AND ((mentors.type)::text = 'Mentor'::text))))
     LEFT JOIN users admins ON (((kids.admin_id = admins.id) AND ((admins.type)::text = 'Admin'::text))))
  WHERE (kids.inactive = false);


--
-- Name: kids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE kids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE kids_id_seq OWNED BY kids.id;


--
-- Name: principal_school_relations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE principal_school_relations (
    id integer NOT NULL,
    principal_id integer,
    school_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: principal_school_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE principal_school_relations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: principal_school_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE principal_school_relations_id_seq OWNED BY principal_school_relations.id;


--
-- Name: relation_logs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE relation_logs (
    id integer NOT NULL,
    kid_id integer NOT NULL,
    user_id integer NOT NULL,
    role character varying,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: relation_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE relation_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: relation_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE relation_logs_id_seq OWNED BY relation_logs.id;


--
-- Name: reminders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reminders (
    id integer NOT NULL,
    held_at date NOT NULL,
    recipient character varying NOT NULL,
    week integer NOT NULL,
    year integer NOT NULL,
    kid_id integer NOT NULL,
    mentor_id integer NOT NULL,
    sent_at timestamp without time zone,
    secondary_mentor_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    acknowledged_at timestamp without time zone
);


--
-- Name: reminders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reminders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reminders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reminders_id_seq OWNED BY reminders.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reviews (
    id integer NOT NULL,
    held_at date,
    kind character varying,
    reason text,
    content text,
    outcome text,
    note text,
    attendee text,
    kid_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reviews_id_seq OWNED BY reviews.id;


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schedules (
    id integer NOT NULL,
    person_id integer NOT NULL,
    person_type character varying NOT NULL,
    day integer NOT NULL,
    hour integer NOT NULL,
    minute integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE schedules_id_seq OWNED BY schedules.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: schools; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schools (
    id integer NOT NULL,
    name character varying,
    principal_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    street character varying,
    street_no character varying,
    zip character varying,
    city character varying,
    phone character varying,
    homepage character varying DEFAULT 'http://'::character varying,
    social character varying,
    district character varying,
    term character varying,
    note text
);


--
-- Name: schools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE schools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE schools_id_seq OWNED BY schools.id;


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sites (
    id integer NOT NULL,
    footer_address character varying,
    footer_email character varying,
    logo_file_name character varying,
    logo_content_type character varying,
    logo_file_size integer,
    logo_updated_at timestamp without time zone,
    feature_coach boolean DEFAULT true,
    term_collection_start integer DEFAULT 2014,
    term_collection_end integer DEFAULT 2020
);


--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sites_id_seq OWNED BY sites.id;


--
-- Name: substitutions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE substitutions (
    id integer NOT NULL,
    start_at date NOT NULL,
    end_at date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    mentor_id integer
);


--
-- Name: substitutions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE substitutions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: substitutions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE substitutions_id_seq OWNED BY substitutions.id;


--
-- Name: translations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE translations (
    id integer NOT NULL,
    locale character varying DEFAULT 'de'::character varying,
    key character varying,
    value text,
    interpolations text,
    is_proc boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE translations_id_seq OWNED BY translations.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY journals ALTER COLUMN id SET DEFAULT nextval('journals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY kids ALTER COLUMN id SET DEFAULT nextval('kids_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY principal_school_relations ALTER COLUMN id SET DEFAULT nextval('principal_school_relations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY relation_logs ALTER COLUMN id SET DEFAULT nextval('relation_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reminders ALTER COLUMN id SET DEFAULT nextval('reminders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reviews ALTER COLUMN id SET DEFAULT nextval('reviews_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedules ALTER COLUMN id SET DEFAULT nextval('schedules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY schools ALTER COLUMN id SET DEFAULT nextval('schools_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sites ALTER COLUMN id SET DEFAULT nextval('sites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY substitutions ALTER COLUMN id SET DEFAULT nextval('substitutions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY translations ALTER COLUMN id SET DEFAULT nextval('translations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY journals
    ADD CONSTRAINT journals_pkey PRIMARY KEY (id);


--
-- Name: kids_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY kids
    ADD CONSTRAINT kids_pkey PRIMARY KEY (id);


--
-- Name: principal_school_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY principal_school_relations
    ADD CONSTRAINT principal_school_relations_pkey PRIMARY KEY (id);


--
-- Name: relation_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY relation_logs
    ADD CONSTRAINT relation_logs_pkey PRIMARY KEY (id);


--
-- Name: reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reminders
    ADD CONSTRAINT reminders_pkey PRIMARY KEY (id);


--
-- Name: reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: schools_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- Name: sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: substitutions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY substitutions
    ADD CONSTRAINT substitutions_pkey PRIMARY KEY (id);


--
-- Name: translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY translations
    ADD CONSTRAINT translations_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_journals_on_held_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_journals_on_held_at ON journals USING btree (held_at);


--
-- Name: index_journals_on_kid_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_journals_on_kid_id ON journals USING btree (kid_id);


--
-- Name: index_journals_on_mentor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_journals_on_mentor_id ON journals USING btree (mentor_id);


--
-- Name: index_journals_on_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_journals_on_month ON journals USING btree (month);


--
-- Name: index_kids_on_inactive; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_kids_on_inactive ON kids USING btree (inactive);


--
-- Name: index_kids_on_school_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_kids_on_school_id ON kids USING btree (school_id);


--
-- Name: index_relation_logs_on_kid_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_relation_logs_on_kid_id ON relation_logs USING btree (kid_id);


--
-- Name: index_relation_logs_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_relation_logs_on_user_id ON relation_logs USING btree (user_id);


--
-- Name: index_reminders_on_kid_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reminders_on_kid_id ON reminders USING btree (kid_id);


--
-- Name: index_reminders_on_mentor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reminders_on_mentor_id ON reminders USING btree (mentor_id);


--
-- Name: index_reminders_on_secondary_mentor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reminders_on_secondary_mentor_id ON reminders USING btree (secondary_mentor_id);


--
-- Name: index_reminders_on_sent_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reminders_on_sent_at ON reminders USING btree (sent_at);


--
-- Name: index_reviews_on_held_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reviews_on_held_at ON reviews USING btree (held_at);


--
-- Name: index_reviews_on_kid_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reviews_on_kid_id ON reviews USING btree (kid_id);


--
-- Name: index_schedules_on_uniqueness; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_schedules_on_uniqueness ON schedules USING btree (person_id, person_type, day, hour, minute);


--
-- Name: index_substitutions_on_mentor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_substitutions_on_mentor_id ON substitutions USING btree (mentor_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_inactive; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_inactive ON users USING btree (inactive);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20110211123618');

INSERT INTO schema_migrations (version) VALUES ('20110719193512');

INSERT INTO schema_migrations (version) VALUES ('20110723124455');

INSERT INTO schema_migrations (version) VALUES ('20110729092432');

INSERT INTO schema_migrations (version) VALUES ('20110729151700');

INSERT INTO schema_migrations (version) VALUES ('20110805073858');

INSERT INTO schema_migrations (version) VALUES ('20110805103654');

INSERT INTO schema_migrations (version) VALUES ('20110812140743');

INSERT INTO schema_migrations (version) VALUES ('20110819144434');

INSERT INTO schema_migrations (version) VALUES ('20110911185441');

INSERT INTO schema_migrations (version) VALUES ('20111118162206');

INSERT INTO schema_migrations (version) VALUES ('20111122080547');

INSERT INTO schema_migrations (version) VALUES ('20111229132920');

INSERT INTO schema_migrations (version) VALUES ('20120125105317');

INSERT INTO schema_migrations (version) VALUES ('20120127194743');

INSERT INTO schema_migrations (version) VALUES ('20120529151824');

INSERT INTO schema_migrations (version) VALUES ('20120727115954');

INSERT INTO schema_migrations (version) VALUES ('20120727130437');

INSERT INTO schema_migrations (version) VALUES ('20120727130553');

INSERT INTO schema_migrations (version) VALUES ('20120901162007');

INSERT INTO schema_migrations (version) VALUES ('20120901171111');

INSERT INTO schema_migrations (version) VALUES ('20120902211909');

INSERT INTO schema_migrations (version) VALUES ('20120902212518');

INSERT INTO schema_migrations (version) VALUES ('20121019122834');

INSERT INTO schema_migrations (version) VALUES ('20121102212736');

INSERT INTO schema_migrations (version) VALUES ('20121223094306');

INSERT INTO schema_migrations (version) VALUES ('20121223105522');

INSERT INTO schema_migrations (version) VALUES ('20121223111315');

INSERT INTO schema_migrations (version) VALUES ('20121223111316');

INSERT INTO schema_migrations (version) VALUES ('20121223113911');

INSERT INTO schema_migrations (version) VALUES ('20121223113912');

INSERT INTO schema_migrations (version) VALUES ('20130310202615');

INSERT INTO schema_migrations (version) VALUES ('20130310204356');

INSERT INTO schema_migrations (version) VALUES ('20130329212908');

INSERT INTO schema_migrations (version) VALUES ('20130830154020');

INSERT INTO schema_migrations (version) VALUES ('20130901102730');

INSERT INTO schema_migrations (version) VALUES ('20131016173257');

INSERT INTO schema_migrations (version) VALUES ('20140224163124');

INSERT INTO schema_migrations (version) VALUES ('20140329123321');

INSERT INTO schema_migrations (version) VALUES ('20140530141910');

INSERT INTO schema_migrations (version) VALUES ('20140831092941');

INSERT INTO schema_migrations (version) VALUES ('20141228185936');

INSERT INTO schema_migrations (version) VALUES ('20150424163124');

INSERT INTO schema_migrations (version) VALUES ('20150520135622');

INSERT INTO schema_migrations (version) VALUES ('20150524164241');

INSERT INTO schema_migrations (version) VALUES ('20150602204436');

INSERT INTO schema_migrations (version) VALUES ('20150626141604');

INSERT INTO schema_migrations (version) VALUES ('20150713124950');

INSERT INTO schema_migrations (version) VALUES ('20150804205014');

INSERT INTO schema_migrations (version) VALUES ('20150929205014');

INSERT INTO schema_migrations (version) VALUES ('20151113110517');

