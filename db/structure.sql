SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: school_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.school_kind AS ENUM (
    'high_school',
    'gymnasium',
    'secondary_school',
    'primary_school'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp without time zone NOT NULL,
    service_name character varying NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    journal_id integer NOT NULL,
    by character varying NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    to_teacher boolean DEFAULT false,
    to_secondary_teacher boolean DEFAULT false,
    to_third_teacher boolean,
    created_by_id integer
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id integer NOT NULL,
    title character varying,
    description text,
    attachment_file_name character varying,
    attachment_content_type character varying,
    attachment_file_size integer,
    attachment_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category0 character varying,
    category1 character varying,
    category2 character varying,
    category3 character varying,
    category4 character varying,
    category5 character varying,
    category6 character varying,
    admin_only boolean DEFAULT false NOT NULL
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: first_year_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.first_year_assessments (
    id bigint NOT NULL,
    kid_id bigint NOT NULL,
    teacher_id integer,
    mentor_id integer,
    created_by_id integer,
    held_at date,
    duration integer,
    development_teacher text,
    development_mentor text,
    goals_teacher text,
    goals_mentor text,
    relation_mentor text,
    motivation text,
    collaboration text,
    breaking_off boolean,
    breaking_reason text,
    goal_1 text,
    goal_2 text,
    goal_3 text,
    improvements text,
    mentor_stays boolean,
    note text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: first_year_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.first_year_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: first_year_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.first_year_assessments_id_seq OWNED BY public.first_year_assessments.id;


--
-- Name: journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journals (
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
    month integer,
    important boolean DEFAULT false NOT NULL,
    meeting_type integer
);


--
-- Name: journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.journals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.journals_id_seq OWNED BY public.journals.id;


--
-- Name: kids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kids (
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
    exit_at date,
    third_teacher_id integer,
    parent_country character varying,
    latitude double precision,
    longitude double precision,
    simplified_schedule text,
    goal_3 boolean,
    goal_4 boolean,
    goal_5 boolean,
    goal_6 boolean,
    goal_7 boolean,
    goal_8 boolean,
    goal_9 boolean,
    goal_10 boolean,
    goal_11 boolean,
    goal_12 boolean,
    goal_13 boolean,
    goal_14 boolean,
    goal_15 boolean,
    goal_16 boolean,
    goal_17 boolean,
    goal_18 boolean,
    goal_19 boolean,
    goal_20 boolean,
    goal_21 boolean,
    goal_22 boolean,
    goal_23 boolean,
    goal_24 boolean,
    goal_25 boolean,
    goal_26 boolean,
    goal_27 boolean,
    goal_28 boolean,
    goal_29 boolean,
    goal_30 boolean,
    goal_31 boolean,
    goal_32 boolean,
    goal_33 boolean,
    goal_34 boolean,
    goal_35 boolean,
    goals_updated_at timestamp without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
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
    ects_legacy boolean DEFAULT false NOT NULL,
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
    college character varying,
    school_id integer,
    note text,
    photo_file_name character varying,
    photo_content_type character varying,
    photo_file_size integer,
    photo_updated_at timestamp without time zone,
    receive_journals boolean DEFAULT true,
    exit_kind character varying,
    exit_at date,
    sex character varying,
    latitude double precision,
    longitude double precision,
    ects integer,
    state character varying DEFAULT 'accepted'::character varying,
    inactive_at timestamp without time zone,
    no_kids_reminder boolean DEFAULT true,
    exit character varying,
    exit_kind_updated_at timestamp without time zone
);


--
-- Name: kid_mentor_relations; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.kid_mentor_relations AS
 SELECT kids.id AS kid_id,
    kids.exit_kind AS kid_exit_kind,
    kids.exit_at AS kid_exit_at,
    kids.school_id,
    kids.name AS kid_name,
    mentors.id AS mentor_id,
    mentors.exit_kind AS mentor_exit_kind,
    mentors.exit_at AS mentor_exit_at,
    mentors.name AS mentor_name,
    mentors.ects AS mentor_ects,
    admins.id AS admin_id,
    "substring"((kids.term)::text, 6) AS simple_term
   FROM ((public.kids
     LEFT JOIN public.users mentors ON (((kids.mentor_id = mentors.id) AND ((mentors.type)::text = 'Mentor'::text))))
     LEFT JOIN public.users admins ON (((kids.admin_id = admins.id) AND ((admins.type)::text = 'Admin'::text))))
  WHERE (kids.inactive = false);


--
-- Name: kids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kids_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kids_id_seq OWNED BY public.kids.id;


--
-- Name: mentor_matchings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mentor_matchings (
    id bigint NOT NULL,
    mentor_id bigint,
    kid_id bigint,
    state character varying DEFAULT 'pending'::character varying,
    message text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: mentor_matchings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mentor_matchings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mentor_matchings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mentor_matchings_id_seq OWNED BY public.mentor_matchings.id;


--
-- Name: principal_school_relations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.principal_school_relations (
    id integer NOT NULL,
    principal_id integer,
    school_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: principal_school_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.principal_school_relations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: principal_school_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.principal_school_relations_id_seq OWNED BY public.principal_school_relations.id;


--
-- Name: relation_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.relation_logs (
    id integer NOT NULL,
    kid_id integer,
    user_id integer,
    role character varying,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: relation_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.relation_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: relation_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.relation_logs_id_seq OWNED BY public.relation_logs.id;


--
-- Name: reminders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reminders (
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

CREATE SEQUENCE public.reminders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reminders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reminders_id_seq OWNED BY public.reminders.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id integer NOT NULL,
    held_at date,
    kind character varying,
    reason text,
    content text,
    note text,
    outcome text,
    attendee text,
    kid_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedules (
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

CREATE SEQUENCE public.schedules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schedules_id_seq OWNED BY public.schedules.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: schools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schools (
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
    note text,
    school_kind public.school_kind
);


--
-- Name: schools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schools_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schools_id_seq OWNED BY public.schools.id;


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sites (
    id integer NOT NULL,
    footer_address character varying,
    footer_email character varying,
    logo_file_name character varying,
    logo_content_type character varying,
    logo_file_size integer,
    logo_updated_at timestamp without time zone,
    feature_coach boolean DEFAULT true,
    term_collection_start integer DEFAULT 2014,
    term_collection_end integer DEFAULT 2020,
    comment_bcc character varying,
    notifications_default_email character varying,
    teachers_can_access_reviews boolean,
    kids_schedule_hourly boolean DEFAULT true,
    terms_of_use_content text,
    terms_of_use_content_parsed text,
    public_signups_active boolean DEFAULT false,
    title character varying,
    css text
);


--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sites_id_seq OWNED BY public.sites.id;


--
-- Name: substitutions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.substitutions (
    id integer NOT NULL,
    start_at date NOT NULL,
    end_at date NOT NULL,
    inactive boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    mentor_id integer,
    secondary_mentor_id integer,
    kid_id integer,
    comments text
);


--
-- Name: substitutions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.substitutions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: substitutions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.substitutions_id_seq OWNED BY public.substitutions.id;


--
-- Name: termination_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.termination_assessments (
    id bigint NOT NULL,
    kid_id bigint NOT NULL,
    teacher_id integer,
    created_by_id integer NOT NULL,
    held_at date,
    development text,
    goals text,
    goals_reached text,
    note text,
    improvements text,
    collaboration text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: termination_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.termination_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: termination_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.termination_assessments_id_seq OWNED BY public.termination_assessments.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: first_year_assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.first_year_assessments ALTER COLUMN id SET DEFAULT nextval('public.first_year_assessments_id_seq'::regclass);


--
-- Name: journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journals ALTER COLUMN id SET DEFAULT nextval('public.journals_id_seq'::regclass);


--
-- Name: kids id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kids ALTER COLUMN id SET DEFAULT nextval('public.kids_id_seq'::regclass);


--
-- Name: mentor_matchings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentor_matchings ALTER COLUMN id SET DEFAULT nextval('public.mentor_matchings_id_seq'::regclass);


--
-- Name: principal_school_relations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.principal_school_relations ALTER COLUMN id SET DEFAULT nextval('public.principal_school_relations_id_seq'::regclass);


--
-- Name: relation_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relation_logs ALTER COLUMN id SET DEFAULT nextval('public.relation_logs_id_seq'::regclass);


--
-- Name: reminders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reminders ALTER COLUMN id SET DEFAULT nextval('public.reminders_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- Name: schedules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules ALTER COLUMN id SET DEFAULT nextval('public.schedules_id_seq'::regclass);


--
-- Name: schools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools ALTER COLUMN id SET DEFAULT nextval('public.schools_id_seq'::regclass);


--
-- Name: sites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites ALTER COLUMN id SET DEFAULT nextval('public.sites_id_seq'::regclass);


--
-- Name: substitutions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.substitutions ALTER COLUMN id SET DEFAULT nextval('public.substitutions_id_seq'::regclass);


--
-- Name: termination_assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.termination_assessments ALTER COLUMN id SET DEFAULT nextval('public.termination_assessments_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: first_year_assessments first_year_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.first_year_assessments
    ADD CONSTRAINT first_year_assessments_pkey PRIMARY KEY (id);


--
-- Name: journals journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journals
    ADD CONSTRAINT journals_pkey PRIMARY KEY (id);


--
-- Name: kids kids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kids
    ADD CONSTRAINT kids_pkey PRIMARY KEY (id);


--
-- Name: mentor_matchings mentor_matchings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentor_matchings
    ADD CONSTRAINT mentor_matchings_pkey PRIMARY KEY (id);


--
-- Name: principal_school_relations principal_school_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.principal_school_relations
    ADD CONSTRAINT principal_school_relations_pkey PRIMARY KEY (id);


--
-- Name: relation_logs relation_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relation_logs
    ADD CONSTRAINT relation_logs_pkey PRIMARY KEY (id);


--
-- Name: reminders reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reminders
    ADD CONSTRAINT reminders_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: substitutions substitutions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.substitutions
    ADD CONSTRAINT substitutions_pkey PRIMARY KEY (id);


--
-- Name: termination_assessments termination_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.termination_assessments
    ADD CONSTRAINT termination_assessments_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_first_year_assessments_on_kid_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_first_year_assessments_on_kid_id ON public.first_year_assessments USING btree (kid_id);


--
-- Name: index_journals_on_held_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journals_on_held_at ON public.journals USING btree (held_at);


--
-- Name: index_journals_on_kid_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journals_on_kid_id ON public.journals USING btree (kid_id);


--
-- Name: index_journals_on_mentor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journals_on_mentor_id ON public.journals USING btree (mentor_id);


--
-- Name: index_journals_on_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journals_on_month ON public.journals USING btree (month);


--
-- Name: index_kids_on_inactive; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kids_on_inactive ON public.kids USING btree (inactive);


--
-- Name: index_kids_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kids_on_school_id ON public.kids USING btree (school_id);


--
-- Name: index_mentor_matchings_on_kid_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mentor_matchings_on_kid_id ON public.mentor_matchings USING btree (kid_id);


--
-- Name: index_mentor_matchings_on_mentor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mentor_matchings_on_mentor_id ON public.mentor_matchings USING btree (mentor_id);


--
-- Name: index_relation_logs_on_kid_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_relation_logs_on_kid_id ON public.relation_logs USING btree (kid_id);


--
-- Name: index_relation_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_relation_logs_on_user_id ON public.relation_logs USING btree (user_id);


--
-- Name: index_reminders_on_kid_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reminders_on_kid_id ON public.reminders USING btree (kid_id);


--
-- Name: index_reminders_on_mentor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reminders_on_mentor_id ON public.reminders USING btree (mentor_id);


--
-- Name: index_reminders_on_secondary_mentor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reminders_on_secondary_mentor_id ON public.reminders USING btree (secondary_mentor_id);


--
-- Name: index_reminders_on_sent_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reminders_on_sent_at ON public.reminders USING btree (sent_at);


--
-- Name: index_reviews_on_held_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_held_at ON public.reviews USING btree (held_at);


--
-- Name: index_reviews_on_kid_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_kid_id ON public.reviews USING btree (kid_id);


--
-- Name: index_schedules_on_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schedules_on_uniqueness ON public.schedules USING btree (person_id, person_type, day, hour, minute);


--
-- Name: index_schools_on_school_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schools_on_school_kind ON public.schools USING btree (school_kind);


--
-- Name: index_substitutions_on_kid_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_substitutions_on_kid_id ON public.substitutions USING btree (kid_id);


--
-- Name: index_substitutions_on_mentor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_substitutions_on_mentor_id ON public.substitutions USING btree (mentor_id);


--
-- Name: index_substitutions_on_secondary_mentor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_substitutions_on_secondary_mentor_id ON public.substitutions USING btree (secondary_mentor_id);


--
-- Name: index_termination_assessments_on_kid_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_termination_assessments_on_kid_id ON public.termination_assessments USING btree (kid_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_inactive; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_inactive ON public.users USING btree (inactive);


--
-- Name: index_users_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_school_id ON public.users USING btree (school_id);


--
-- Name: termination_assessments fk_rails_090a7af30c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.termination_assessments
    ADD CONSTRAINT fk_rails_090a7af30c FOREIGN KEY (kid_id) REFERENCES public.kids(id);


--
-- Name: first_year_assessments fk_rails_24a626e8e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.first_year_assessments
    ADD CONSTRAINT fk_rails_24a626e8e4 FOREIGN KEY (kid_id) REFERENCES public.kids(id);


--
-- Name: mentor_matchings fk_rails_4c288c1844; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentor_matchings
    ADD CONSTRAINT fk_rails_4c288c1844 FOREIGN KEY (kid_id) REFERENCES public.kids(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: mentor_matchings fk_rails_eba31d6cb5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentor_matchings
    ADD CONSTRAINT fk_rails_eba31d6cb5 FOREIGN KEY (mentor_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250209132950'),
('20250105000000'),
('20240321000000'),
('20240202182155'),
('20240202180408'),
('20240128181032'),
('20240127154844'),
('20230806083333'),
('20230413143047'),
('20220916134500'),
('20220701111518'),
('20211126131246'),
('20210929155237'),
('20210711111518'),
('20210525111518'),
('20210522155536'),
('20210518155536'),
('20210518095427'),
('20210517155237'),
('20210517150849'),
('20210516141014'),
('20210516141013'),
('20210510130754'),
('20210510083920'),
('20210117110314'),
('20210117110313'),
('20210114145126'),
('20201016140039'),
('20201016140038'),
('20201001135348'),
('20200818093430'),
('20200611153304'),
('20200604123200'),
('20200528120329'),
('20200526130657'),
('20200526121729'),
('20200525155228'),
('20181021000000'),
('20181001152303'),
('20180531175849'),
('20180531173049'),
('20171022132950'),
('20170120100844'),
('20170118161950'),
('20170112142758'),
('20170111165510'),
('20161222121149'),
('20161219202230'),
('20161216161405'),
('20161211000000'),
('20160203164912'),
('20151231101854'),
('20151225123405'),
('20151113110517'),
('20150929205014'),
('20150804205014'),
('20150713124950'),
('20150626141604'),
('20150602204436'),
('20150524164241'),
('20150520135622'),
('20150424163124'),
('20141228185936'),
('20140831092941'),
('20140530141910'),
('20140329123321'),
('20140224163124'),
('20131016173257'),
('20130901102730'),
('20130830154020'),
('20130329212908'),
('20130310204356'),
('20130310202615'),
('20121223113912'),
('20121223113911'),
('20121223111316'),
('20121223111315'),
('20121223105522'),
('20121223094306'),
('20121102212736'),
('20121019122834'),
('20120902212518'),
('20120902211909'),
('20120901171111'),
('20120901162007'),
('20120727130553'),
('20120727130437'),
('20120727115954'),
('20120529151824'),
('20120127194743'),
('20120125105317'),
('20111229132920'),
('20111122080547'),
('20111118162206'),
('20110911185441'),
('20110819144434'),
('20110812140743'),
('20110805103654'),
('20110805073858'),
('20110729151700'),
('20110729092432'),
('20110723124455'),
('20110719193512'),
('20110211123618');

