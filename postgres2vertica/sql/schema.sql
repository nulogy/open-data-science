--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: array_sort(anyarray); Type: FUNCTION; Schema: public; Owner: nulogy
--

CREATE FUNCTION array_sort(anyarray) RETURNS anyarray
    LANGUAGE sql
    AS $_$
      SELECT ARRAY(
          SELECT DISTINCT $1[s.i] AS "foo"
          FROM
              generate_series(array_lower($1,1), array_upper($1,1)) AS s(i)
          ORDER BY foo
      );
      $_$;


ALTER FUNCTION public.array_sort(anyarray) OWNER TO nulogy;

--
-- Name: for_all_schemas(text); Type: FUNCTION; Schema: public; Owner: nulogy
--

CREATE FUNCTION for_all_schemas(raw_query text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE 
final_statement text;
  all_schema_query text;
  schema RECORD;
  schema_names text[];
  name text;

  temptable_select text;
  temptable_selects text[];

BEGIN
  -- kill temp tables
  DISCARD TEMP;

  -- get all the schemas
  FOR schema IN SELECT nspname AS schema_name FROM pg_catalog.pg_namespace WHERE nspname = 'public' OR nspname LIKE '%account_%'
  LOOP
    schema_names := array_append(schema_names, CAST(schema.schema_name AS text));
    final_statement := 'CREATE TEMPORARY TABLE ' || schema.schema_name || '_temptable AS '
      || 'SELECT ' 
      || 'CAST(''' || schema.schema_name || ''' AS text) AS schema_name, '
      || 'q.* FROM ('
      || raw_query
      || ') AS q';
    EXECUTE 'SET search_path = ' || schema.schema_name || ', public';
    EXECUTE final_statement;
  END LOOP;

  FOREACH name IN ARRAY schema_names
  LOOP
    temptable_select := 'SELECT * FROM ' || name || '_temptable';
    temptable_selects := array_append(temptable_selects, temptable_select);
  END LOOP;
  final_statement := 'CREATE TEMPORARY TABLE temptable AS ' 
    || array_to_string(temptable_selects, ' UNION ALL ')
    || ' ORDER BY schema_name';
  EXECUTE final_statement;
  RETURN 0;
END;$$;


ALTER FUNCTION public.for_all_schemas(raw_query text) OWNER TO nulogy;

--
-- Name: get_sa(); Type: FUNCTION; Schema: public; Owner: nulogy
--

CREATE FUNCTION get_sa() RETURNS SETOF pg_stat_activity
    LANGUAGE sql SECURITY DEFINER
    AS $$ SELECT * FROM pg_catalog.pg_stat_activity; $$;


ALTER FUNCTION public.get_sa() OWNER TO nulogy;

--
-- Name: array_accum(anyelement); Type: AGGREGATE; Schema: public; Owner: nulogy
--

CREATE AGGREGATE array_accum(anyelement) (
    SFUNC = array_append,
    STYPE = anyarray,
    INITCOND = '{}'
);


ALTER AGGREGATE public.array_accum(anyelement) OWNER TO nulogy;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    name text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unit_of_weight text DEFAULT 'lb'::text,
    estimating_library boolean DEFAULT false,
    use_reject_reasons text DEFAULT 'not_enabled'::character varying,
    quickbooks boolean DEFAULT false NOT NULL,
    income_gl_account_id integer,
    cogs_gl_account_id integer,
    applied_labour_gl_account_id integer,
    inventory_adjustment_expense_gl_account_id integer,
    finished_good_asset_gl_account_id integer,
    raw_materials_asset_gl_account_id integer,
    non_production_labour_gl_account_id integer,
    netsuite boolean DEFAULT false NOT NULL,
    netsuite_email text,
    netsuite_account text,
    netsuite_password text,
    project_code_unique boolean DEFAULT true,
    default_performance_level numeric(16,5) DEFAULT 1,
    use_project_charges boolean DEFAULT false,
    labour_default_markup_value numeric(16,5) DEFAULT 0.0,
    labour_default_markup_type text DEFAULT 'per unit'::character varying,
    materials_default_markup_value numeric(16,5) DEFAULT 0.0,
    materials_default_markup_type text DEFAULT 'per unit'::character varying,
    overhead_default_markup_value numeric(16,5) DEFAULT 0.0,
    overhead_default_markup_type text DEFAULT 'per unit'::character varying,
    subcomponent_estimate_default_update text DEFAULT 'all values'::character varying,
    mobile_menu_key text DEFAULT '42'::character varying,
    require_ship_confirm boolean DEFAULT true,
    log_all_qb_xml boolean DEFAULT false,
    quality boolean DEFAULT false,
    use_custom_qc_outputs boolean DEFAULT false,
    specify_price_on_ship_orders boolean DEFAULT false,
    show_logo_on_pdfs boolean DEFAULT false,
    allow_custom_item_fields boolean DEFAULT false,
    allow_helpdesk boolean DEFAULT false,
    allow_subcomponent_substitutions boolean DEFAULT false,
    error_on_negative_quantities_in_quickbooks boolean DEFAULT true,
    allow_transaction_posting boolean DEFAULT true,
    allow_email_domain_lockdown boolean DEFAULT true,
    allow_expiry_date_formats boolean DEFAULT false,
    allow_invoicing_posted_jobs boolean DEFAULT false,
    use_quickbooks_reference_number_for_invoices boolean DEFAULT true,
    use_quickbooks_reference_number_for_receive_orders boolean DEFAULT true,
    setting_use_default_estimate_expiry boolean DEFAULT false,
    add_number_of_days_from_estimated_on_for_expiry_date integer,
    number_of_project_charge_settings integer DEFAULT 0,
    use_pallet_charges boolean DEFAULT false,
    number_of_pallet_charge_settings integer DEFAULT 0,
    allow_custom_scenario_fields boolean,
    show_lot_code_and_expiry_date_on_shipment_invoices boolean DEFAULT false,
    allow_receiving_mixed_pallets boolean DEFAULT true,
    allow_users_to_import_items boolean DEFAULT false,
    copy_to_quickbooks_po_number integer DEFAULT 0,
    use_custom_fields_on_estimate boolean DEFAULT false,
    allow_stock_transfers boolean DEFAULT false NOT NULL,
    setting_create_receive_orders_from_projects boolean,
    company_id integer,
    overhead_default_cost_value numeric(16,5) DEFAULT 0.0,
    active boolean DEFAULT true NOT NULL,
    intelligent_code_generation_module boolean DEFAULT false,
    wms boolean DEFAULT false,
    locale text DEFAULT 'en_US'::character varying NOT NULL,
    partitioned boolean DEFAULT false NOT NULL,
    file_export_delimiter text DEFAULT ','::text NOT NULL,
    file_export_encoding text DEFAULT 'UTF-8'::text NOT NULL,
    mobile_packmanager character varying(255) DEFAULT 'off'::character varying,
    default_customer_product_code_to_item_code boolean DEFAULT true NOT NULL,
    restrict_item_modification_when_producing boolean DEFAULT true,
    background_task_rate_limit integer DEFAULT 1,
    group_shipment_by_po boolean DEFAULT false,
    enable_custom_uoms boolean DEFAULT false,
    allow_manual_recording_of_consumption boolean DEFAULT false NOT NULL,
    estimate_and_scenario_name_unique boolean DEFAULT true NOT NULL
);


ALTER TABLE public.accounts OWNER TO nulogy;

--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_id_seq OWNER TO nulogy;

--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: allowed_accounts; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE allowed_accounts (
    id integer NOT NULL,
    account_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.allowed_accounts OWNER TO nulogy;

--
-- Name: allowed_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE allowed_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.allowed_accounts_id_seq OWNER TO nulogy;

--
-- Name: allowed_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE allowed_accounts_id_seq OWNED BY allowed_accounts.id;


--
-- Name: allowed_sites; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE allowed_sites (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    user_id integer
);


ALTER TABLE public.allowed_sites OWNER TO nulogy;

--
-- Name: allowed_sites_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE allowed_sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.allowed_sites_id_seq OWNER TO nulogy;

--
-- Name: allowed_sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE allowed_sites_id_seq OWNED BY allowed_sites.id;


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE announcements (
    id integer NOT NULL,
    title text,
    message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    posted_at timestamp without time zone,
    sticky boolean DEFAULT false,
    expiry_date_at timestamp without time zone
);


ALTER TABLE public.announcements OWNER TO nulogy;

--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE announcements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.announcements_id_seq OWNER TO nulogy;

--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE announcements_id_seq OWNED BY announcements.id;


--
-- Name: application_configurations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE application_configurations (
    id integer NOT NULL,
    log_activity boolean DEFAULT true,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    statement_timeout text DEFAULT '1min'::character varying NOT NULL,
    identity_map_enabled boolean DEFAULT true,
    enforce_per_page boolean DEFAULT false,
    notification_polling_interval integer DEFAULT 0,
    event_handling_option text DEFAULT 'transmit'::text,
    background_shipping_limit integer,
    use_new_production_focus_page boolean DEFAULT true,
    xml_api_identity_map_enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.application_configurations OWNER TO nulogy;

--
-- Name: application_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE application_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.application_configurations_id_seq OWNER TO nulogy;

--
-- Name: application_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE application_configurations_id_seq OWNED BY application_configurations.id;


--
-- Name: assembly_item_templates; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE assembly_item_templates (
    id integer NOT NULL,
    name text,
    description text,
    people numeric(16,5) DEFAULT 1.0,
    seconds numeric(16,5) DEFAULT 0.0,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tid text
);


ALTER TABLE public.assembly_item_templates OWNER TO nulogy;

--
-- Name: assembly_item_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE assembly_item_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.assembly_item_templates_id_seq OWNER TO nulogy;

--
-- Name: assembly_item_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE assembly_item_templates_id_seq OWNED BY assembly_item_templates.id;


--
-- Name: assembly_steps; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE assembly_steps (
    id integer NOT NULL,
    name text,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    assembly_procedure_id integer,
    "position" integer,
    people numeric(16,5) DEFAULT 1,
    seconds numeric(16,5) DEFAULT 0,
    repetitions_per_unit_value numeric(16,5) DEFAULT 1.0,
    suggested_people numeric(16,5) DEFAULT 0,
    assembly_item_template_id integer,
    item_code text,
    account_id integer NOT NULL,
    "group" integer,
    repetitions_per_unit text
);


ALTER TABLE public.assembly_steps OWNER TO nulogy;

--
-- Name: assembly_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE assembly_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.assembly_items_id_seq OWNER TO nulogy;

--
-- Name: assembly_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE assembly_items_id_seq OWNED BY assembly_steps.id;


--
-- Name: assembly_procedures; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE assembly_procedures (
    id integer NOT NULL,
    scenario_id integer,
    sku_id integer,
    account_id integer,
    personnel numeric(16,5) DEFAULT 0.0,
    performance numeric(16,5) DEFAULT 1,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    standard_units_per_hour numeric(16,5) DEFAULT 0.0,
    production_rate_depends_on_number_of_people boolean DEFAULT true NOT NULL
);


ALTER TABLE public.assembly_procedures OWNER TO nulogy;

--
-- Name: assembly_procedures_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE assembly_procedures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.assembly_procedures_id_seq OWNER TO nulogy;

--
-- Name: assembly_procedures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE assembly_procedures_id_seq OWNED BY assembly_procedures.id;


--
-- Name: background_report_results; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE background_report_results (
    id integer NOT NULL,
    background_task_id integer,
    user_id integer,
    data text,
    urls text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    metadata text
);


ALTER TABLE public.background_report_results OWNER TO nulogy;

--
-- Name: background_query_results_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE background_query_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.background_query_results_id_seq OWNER TO nulogy;

--
-- Name: background_query_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE background_query_results_id_seq OWNED BY background_report_results.id;


--
-- Name: background_tasks; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE background_tasks (
    id integer NOT NULL,
    name text,
    result text,
    user_id integer,
    run_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    status integer DEFAULT 5 NOT NULL,
    account_id integer,
    scheduled_at timestamp without time zone,
    action_class_name text,
    action_args text,
    action_errors text,
    site_id integer,
    company_id integer,
    task_type text,
    completed_at timestamp without time zone,
    queued_at timestamp without time zone,
    lock_version integer DEFAULT 0
);


ALTER TABLE public.background_tasks OWNER TO nulogy;

--
-- Name: background_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE background_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.background_tasks_id_seq OWNER TO nulogy;

--
-- Name: background_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE background_tasks_id_seq OWNED BY background_tasks.id;


--
-- Name: badge_types; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE badge_types (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    prefix text,
    name text,
    machine boolean DEFAULT false,
    site_id integer,
    rate numeric(16,5) DEFAULT 0.0,
    inactive boolean DEFAULT false
);


ALTER TABLE public.badge_types OWNER TO nulogy;

--
-- Name: badge_types_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE badge_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.badge_types_id_seq OWNER TO nulogy;

--
-- Name: badge_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE badge_types_id_seq OWNED BY badge_types.id;


--
-- Name: barcode_configurations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE barcode_configurations (
    id integer NOT NULL,
    account_id integer,
    customer_id integer,
    segment_delimiter text,
    barcode_terminator text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.barcode_configurations OWNER TO nulogy;

--
-- Name: barcode_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE barcode_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.barcode_configurations_id_seq OWNER TO nulogy;

--
-- Name: barcode_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE barcode_configurations_id_seq OWNED BY barcode_configurations.id;


--
-- Name: barcode_segments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE barcode_segments (
    id integer NOT NULL,
    account_id integer,
    barcode_configuration_id integer,
    application_identifier text,
    length integer,
    packmanager_field text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    fixed boolean DEFAULT false,
    editable boolean DEFAULT true NOT NULL,
    field_type character varying(255) DEFAULT 'string'::character varying
);


ALTER TABLE public.barcode_segments OWNER TO nulogy;

--
-- Name: barcode_segments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE barcode_segments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.barcode_segments_id_seq OWNER TO nulogy;

--
-- Name: barcode_segments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE barcode_segments_id_seq OWNED BY barcode_segments.id;


--
-- Name: bc_snapshot_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE bc_snapshot_items (
    id integer NOT NULL,
    site_id integer,
    location_id integer,
    pallet_id integer,
    sku_id integer,
    blind_count_id integer,
    lot_code text,
    expiry_date text,
    base_quantity numeric(16,5) DEFAULT 0.0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    blind_count_row_id integer,
    inventory_status_id integer
);


ALTER TABLE public.bc_snapshot_items OWNER TO nulogy;

--
-- Name: bc_snapshot_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE bc_snapshot_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bc_snapshot_items_id_seq OWNER TO nulogy;

--
-- Name: bc_snapshot_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE bc_snapshot_items_id_seq OWNED BY bc_snapshot_items.id;


--
-- Name: blind_count_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE blind_count_items (
    id integer NOT NULL,
    blind_count_id integer,
    lot_code text,
    expiry_date text,
    unit_quantity numeric(16,5) DEFAULT 0,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pallet_id integer,
    sku_id integer,
    old_each_quantity numeric(16,5),
    matched boolean DEFAULT false NOT NULL,
    accepted boolean DEFAULT false NOT NULL,
    blind_count_row_id integer,
    inventory_status_id integer,
    unit_uom_id integer
);


ALTER TABLE public.blind_count_items OWNER TO nulogy;

--
-- Name: blind_count_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE blind_count_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blind_count_items_id_seq OWNER TO nulogy;

--
-- Name: blind_count_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE blind_count_items_id_seq OWNED BY blind_count_items.id;


--
-- Name: blind_count_rows; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE blind_count_rows (
    id integer NOT NULL,
    pallet_id integer,
    site_id integer NOT NULL,
    blind_count_id integer NOT NULL,
    accepted integer DEFAULT 0 NOT NULL,
    matched boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.blind_count_rows OWNER TO nulogy;

--
-- Name: blind_count_rows_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE blind_count_rows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blind_count_rows_id_seq OWNER TO nulogy;

--
-- Name: blind_count_rows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE blind_count_rows_id_seq OWNED BY blind_count_rows.id;


--
-- Name: blind_counts; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE blind_counts (
    id integer NOT NULL,
    location_id integer,
    notes text,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    count_ended_at timestamp without time zone,
    count_started_at timestamp without time zone,
    status integer DEFAULT 1,
    counted_by_id integer,
    sign_off_user_id integer,
    signed_off_at timestamp without time zone
);


ALTER TABLE public.blind_counts OWNER TO nulogy;

--
-- Name: blind_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE blind_counts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blind_counts_id_seq OWNER TO nulogy;

--
-- Name: blind_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE blind_counts_id_seq OWNED BY blind_counts.id;


--
-- Name: bom_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE bom_items (
    id integer NOT NULL,
    sku_id integer,
    subcomponent_id integer,
    old_quantity numeric(26,15) DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "position" integer,
    account_id integer NOT NULL,
    optional boolean DEFAULT false,
    priority integer,
    substitute_for_id integer,
    external_identifier text,
    subcomponent_unit_quantity numeric(16,5) NOT NULL,
    subcomponent_uom_id integer NOT NULL,
    finished_good_unit_quantity numeric(16,5) NOT NULL,
    finished_good_uom_id integer NOT NULL
);


ALTER TABLE public.bom_items OWNER TO nulogy;

--
-- Name: bom_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE bom_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bom_items_id_seq OWNER TO nulogy;

--
-- Name: bom_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE bom_items_id_seq OWNED BY bom_items.id;


--
-- Name: bookmark_users; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE bookmark_users (
    id integer NOT NULL,
    site_id integer NOT NULL,
    user_id integer,
    bookmark_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.bookmark_users OWNER TO nulogy;

--
-- Name: bookmark_users_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE bookmark_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bookmark_users_id_seq OWNER TO nulogy;

--
-- Name: bookmark_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE bookmark_users_id_seq OWNED BY bookmark_users.id;


--
-- Name: bookmarks; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE bookmarks (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    name text,
    role_access text,
    financial_access text DEFAULT 'none'::text,
    url text,
    account_id integer
);


ALTER TABLE public.bookmarks OWNER TO nulogy;

--
-- Name: bookmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE bookmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bookmarks_id_seq OWNER TO nulogy;

--
-- Name: bookmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE bookmarks_id_seq OWNED BY bookmarks.id;


--
-- Name: breaks; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE breaks (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    started_at timestamp without time zone,
    ended_at timestamp without time zone,
    job_id integer,
    site_id integer NOT NULL,
    notes text,
    downtime_reason_id integer
);


ALTER TABLE public.breaks OWNER TO nulogy;

--
-- Name: breaks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE breaks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.breaks_id_seq OWNER TO nulogy;

--
-- Name: breaks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE breaks_id_seq OWNED BY breaks.id;


--
-- Name: cancel_pick_up_picks; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE cancel_pick_up_picks (
    id integer NOT NULL,
    pick_list_pick_id integer,
    pick_up_pick_id integer,
    from_adjustment_id integer,
    to_adjustment_id integer,
    site_id integer NOT NULL,
    sku_id integer,
    unit_uom_id integer,
    unit_quantity numeric,
    lot_code text,
    expiry_date text,
    source_pallet_id integer,
    destination_pallet_id integer,
    source_location_id integer,
    destination_location_id integer,
    inventory_status_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.cancel_pick_up_picks OWNER TO nulogy;

--
-- Name: cancel_pick_up_picks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE cancel_pick_up_picks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cancel_pick_up_picks_id_seq OWNER TO nulogy;

--
-- Name: cancel_pick_up_picks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE cancel_pick_up_picks_id_seq OWNED BY cancel_pick_up_picks.id;


--
-- Name: carriers; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE carriers (
    id integer NOT NULL,
    code text,
    name text,
    contact text,
    phone text,
    email text,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    qb_list_id text,
    qb_last_sync_at timestamp without time zone,
    carrier_type text
);


ALTER TABLE public.carriers OWNER TO nulogy;

--
-- Name: carriers_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE carriers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.carriers_id_seq OWNER TO nulogy;

--
-- Name: carriers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE carriers_id_seq OWNED BY carriers.id;


--
-- Name: cc_historical_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE cc_historical_items (
    id integer NOT NULL,
    cycle_count_item_id integer,
    location_id integer,
    pallet_id integer,
    sku_id integer,
    lot_code text,
    expiry_date text,
    unit_quantity numeric(16,5) DEFAULT 0,
    old_each_quantity numeric(16,5) DEFAULT 0,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    inventory_status_id integer,
    unit_uom_id integer,
    inventory_base_quantity_snapshot numeric(16,5)
);


ALTER TABLE public.cc_historical_items OWNER TO nulogy;

--
-- Name: cc_historical_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE cc_historical_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cc_historical_items_id_seq OWNER TO nulogy;

--
-- Name: cc_historical_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE cc_historical_items_id_seq OWNED BY cc_historical_items.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE companies (
    id integer NOT NULL,
    name text,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    partitioned boolean DEFAULT false NOT NULL
);


ALTER TABLE public.companies OWNER TO nulogy;

--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.companies_id_seq OWNER TO nulogy;

--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE companies_id_seq OWNED BY companies.id;


--
-- Name: company_locales; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE company_locales (
    id integer NOT NULL,
    company_id integer,
    locale text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.company_locales OWNER TO nulogy;

--
-- Name: company_locales_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE company_locales_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.company_locales_id_seq OWNER TO nulogy;

--
-- Name: company_locales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE company_locales_id_seq OWNED BY company_locales.id;


--
-- Name: consignee_custom_outputs; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE consignee_custom_outputs (
    id integer NOT NULL,
    consignee_id integer,
    custom_output_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    site_id integer
);


ALTER TABLE public.consignee_custom_outputs OWNER TO nulogy;

--
-- Name: consignee_custom_outputs_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE consignee_custom_outputs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.consignee_custom_outputs_id_seq OWNER TO nulogy;

--
-- Name: consignee_custom_outputs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE consignee_custom_outputs_id_seq OWNED BY consignee_custom_outputs.id;


--
-- Name: consignees; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE consignees (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name text,
    address text,
    city text,
    province text,
    postal_code text,
    code text,
    phone text,
    attention text,
    country text,
    address_2 text,
    site_id integer,
    facility_number text,
    external_identifier character varying(255)
);


ALTER TABLE public.consignees OWNER TO nulogy;

--
-- Name: consignees_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE consignees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.consignees_id_seq OWNER TO nulogy;

--
-- Name: consignees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE consignees_id_seq OWNED BY consignees.id;


--
-- Name: consumption_entries; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE consumption_entries (
    id integer NOT NULL,
    consumption_plan_id integer,
    subcomponent_id integer,
    bom_item_id integer,
    consume boolean,
    lot_code character varying(255),
    expiry_date character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    site_id integer NOT NULL
);


ALTER TABLE public.consumption_entries OWNER TO nulogy;

--
-- Name: consumption_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE consumption_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.consumption_entries_id_seq OWNER TO nulogy;

--
-- Name: consumption_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE consumption_entries_id_seq OWNED BY consumption_entries.id;


--
-- Name: consumption_plans; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE consumption_plans (
    id integer NOT NULL,
    job_id integer,
    finished_good_id integer,
    finished_good_lot_code character varying(255),
    finished_good_expiry_date character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    site_id integer NOT NULL
);


ALTER TABLE public.consumption_plans OWNER TO nulogy;

--
-- Name: consumption_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE consumption_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.consumption_plans_id_seq OWNER TO nulogy;

--
-- Name: consumption_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE consumption_plans_id_seq OWNED BY consumption_plans.id;


--
-- Name: current_inventory_levels; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE current_inventory_levels (
    id integer NOT NULL,
    site_id integer,
    location_id integer,
    pallet_id integer,
    sku_id integer,
    lot_code text,
    expiry_date text,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    lock_version integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    expires_on date,
    held_for_id integer,
    held_for_class text,
    base_quantity numeric(16,5) DEFAULT 0.0,
    inventory_status_id integer
);


ALTER TABLE public.current_inventory_levels OWNER TO nulogy;

--
-- Name: current_inventory_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE current_inventory_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.current_inventory_levels_id_seq OWNER TO nulogy;

--
-- Name: current_inventory_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE current_inventory_levels_id_seq OWNED BY current_inventory_levels.id;


--
-- Name: custom_charge_settings; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE custom_charge_settings (
    id integer NOT NULL,
    account_id integer,
    name text,
    default_percentage numeric(16,5) DEFAULT 0.0,
    default_source text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    default_markup numeric(16,5) DEFAULT 0.0,
    default_markup_type text,
    enabled boolean DEFAULT true
);


ALTER TABLE public.custom_charge_settings OWNER TO nulogy;

--
-- Name: custom_charge_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE custom_charge_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_charge_settings_id_seq OWNER TO nulogy;

--
-- Name: custom_charge_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE custom_charge_settings_id_seq OWNED BY custom_charge_settings.id;


--
-- Name: custom_fields; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE custom_fields (
    id integer NOT NULL,
    name text,
    identifier text NOT NULL,
    enabled boolean DEFAULT false,
    account_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    field_type text,
    index integer,
    site_id integer
);


ALTER TABLE public.custom_fields OWNER TO nulogy;

--
-- Name: custom_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE custom_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_fields_id_seq OWNER TO nulogy;

--
-- Name: custom_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE custom_fields_id_seq OWNED BY custom_fields.id;


--
-- Name: custom_output_attachments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE custom_output_attachments (
    id integer NOT NULL,
    size integer,
    content_type text,
    document text,
    description text,
    custom_output_id integer,
    site_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.custom_output_attachments OWNER TO nulogy;

--
-- Name: custom_output_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE custom_output_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_output_attachments_id_seq OWNER TO nulogy;

--
-- Name: custom_output_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE custom_output_attachments_id_seq OWNED BY custom_output_attachments.id;


--
-- Name: custom_output_mappings; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE custom_output_mappings (
    id integer NOT NULL,
    site_id integer,
    case_label_custom_output_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pallet_tag_custom_output_id integer,
    bill_of_lading_custom_output_id integer,
    invoice_custom_output_id integer,
    quote_custom_output_id integer,
    item_docket_custom_output_id integer,
    line_activity_detail_custom_output_id integer,
    ship_order_custom_output_id integer,
    move_pick_sheet_custom_output_id integer,
    shipment_pick_sheet_custom_output_id integer,
    receive_order_custom_output_id integer,
    receipt_sheet_custom_output_id integer,
    item_label_custom_output_id integer,
    job_docket_custom_output_id integer,
    wms_move_pick_sheet_custom_output_id integer,
    packing_slip_custom_output_id integer,
    pick_list_custom_output_id integer,
    bill_of_lading_by_stop_custom_output_id integer,
    shipment_label_custom_output_id integer,
    project_docket_custom_output_id integer
);


ALTER TABLE public.custom_output_mappings OWNER TO nulogy;

--
-- Name: custom_output_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE custom_output_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_output_mappings_id_seq OWNER TO nulogy;

--
-- Name: custom_output_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE custom_output_mappings_id_seq OWNED BY custom_output_mappings.id;


--
-- Name: custom_outputs; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE custom_outputs (
    id integer NOT NULL,
    name text,
    preview_id character varying(255),
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT false,
    parameters text,
    prince boolean DEFAULT true NOT NULL,
    content text,
    output_type text
);


ALTER TABLE public.custom_outputs OWNER TO nulogy;

--
-- Name: custom_outputs_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE custom_outputs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_outputs_id_seq OWNER TO nulogy;

--
-- Name: custom_outputs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE custom_outputs_id_seq OWNED BY custom_outputs.id;


--
-- Name: custom_per_unit_charges; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE custom_per_unit_charges (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name text,
    scenario_charge_id integer,
    account_id integer,
    cost_per_unit numeric(16,5) DEFAULT 0.0,
    charge_per_unit numeric(16,5) DEFAULT 0.0,
    markup_per_unit numeric(16,5) DEFAULT 0.0,
    markup_percentage numeric(16,5) DEFAULT 0.0,
    percentage numeric(16,5) DEFAULT 0.0,
    source text,
    markup_type text
);


ALTER TABLE public.custom_per_unit_charges OWNER TO nulogy;

--
-- Name: custom_per_unit_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE custom_per_unit_charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_per_unit_charges_id_seq OWNER TO nulogy;

--
-- Name: custom_per_unit_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE custom_per_unit_charges_id_seq OWNED BY custom_per_unit_charges.id;


--
-- Name: custom_project_field_values; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE custom_project_field_values (
    id integer NOT NULL,
    description text,
    custom_project_field_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer
);


ALTER TABLE public.custom_project_field_values OWNER TO nulogy;

--
-- Name: custom_project_field_values_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE custom_project_field_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_project_field_values_id_seq OWNER TO nulogy;

--
-- Name: custom_project_field_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE custom_project_field_values_id_seq OWNED BY custom_project_field_values.id;


--
-- Name: custom_project_fields; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE custom_project_fields (
    id integer NOT NULL,
    label text DEFAULT 'Custom Project Field'::character varying,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.custom_project_fields OWNER TO nulogy;

--
-- Name: custom_project_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE custom_project_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_project_fields_id_seq OWNER TO nulogy;

--
-- Name: custom_project_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE custom_project_fields_id_seq OWNED BY custom_project_fields.id;


--
-- Name: customer_access_configurations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE customer_access_configurations (
    id integer NOT NULL,
    customer_id integer,
    has_job_productivity boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    has_item_information boolean DEFAULT false,
    has_receive_order boolean DEFAULT false,
    account_id integer NOT NULL,
    has_availability boolean DEFAULT false,
    has_current_inventory boolean DEFAULT false,
    has_ship_order boolean DEFAULT false,
    has_shipped_item boolean DEFAULT false NOT NULL,
    has_edi_transaction boolean DEFAULT false NOT NULL,
    has_production_timeline boolean DEFAULT false,
    has_project_status boolean DEFAULT false NOT NULL,
    has_production_report boolean DEFAULT false NOT NULL,
    has_receipt_item boolean DEFAULT false NOT NULL,
    has_ist_report boolean DEFAULT false NOT NULL,
    has_ost_report boolean DEFAULT false NOT NULL
);


ALTER TABLE public.customer_access_configurations OWNER TO nulogy;

--
-- Name: customer_access_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE customer_access_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.customer_access_configurations_id_seq OWNER TO nulogy;

--
-- Name: customer_access_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE customer_access_configurations_id_seq OWNED BY customer_access_configurations.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE customers (
    id integer NOT NULL,
    name text,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer,
    billing_address text,
    code text,
    qb_list_id text,
    qb_last_sync_at timestamp without time zone,
    netsuite_id text,
    netsuite_last_sync_at timestamp without time zone,
    inactive boolean DEFAULT false,
    shipment_notes text,
    reference text,
    enable_shelf_life boolean DEFAULT false,
    show_expiry_date_warning boolean DEFAULT true,
    validate_materials_on_lot_code_generation boolean DEFAULT false NOT NULL,
    expiry_date_range_limit integer,
    validate_subcomponent_expiry_date_limit_exceeded boolean DEFAULT false NOT NULL,
    validate_expiry_date_range boolean DEFAULT false NOT NULL,
    finished_good_production_date_limit integer,
    validate_manufacturing_from_same_origin boolean DEFAULT false NOT NULL,
    external_identifier character varying(255)
);


ALTER TABLE public.customers OWNER TO nulogy;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.customers_id_seq OWNER TO nulogy;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE customers_id_seq OWNED BY customers.id;


--
-- Name: cycle_count_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE cycle_count_items (
    id integer NOT NULL,
    reference_id integer,
    location_id integer,
    pallet_id integer,
    sku_id integer,
    lot_code text,
    expiry_date text,
    unit_quantity numeric(16,5) DEFAULT 0,
    old_each_quantity numeric(16,5) DEFAULT 0,
    site_id integer,
    cycle_count_id integer,
    checked boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ad_hoc boolean DEFAULT false NOT NULL,
    inventory_status_id integer,
    unit_uom_id integer,
    inventory_base_quantity_snapshot numeric(16,5)
);


ALTER TABLE public.cycle_count_items OWNER TO nulogy;

--
-- Name: cycle_count_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE cycle_count_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cycle_count_items_id_seq OWNER TO nulogy;

--
-- Name: cycle_count_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE cycle_count_items_id_seq OWNED BY cycle_count_items.id;


--
-- Name: cycle_counts; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE cycle_counts (
    id integer NOT NULL,
    performed_at timestamp without time zone,
    counted_by_id integer,
    status integer DEFAULT 1 NOT NULL,
    notes text,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    total_units numeric(16,5) DEFAULT 0.0,
    sign_off_user_id integer,
    closed_at timestamp without time zone,
    qb_txn_id text,
    synchronized_status text,
    qb_last_sync_at timestamp without time zone,
    frozen_units_changed numeric(16,5),
    frozen_value_changed numeric(16,5),
    frozen_accuracy numeric(16,5)
);


ALTER TABLE public.cycle_counts OWNER TO nulogy;

--
-- Name: cycle_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE cycle_counts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cycle_counts_id_seq OWNER TO nulogy;

--
-- Name: cycle_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE cycle_counts_id_seq OWNED BY cycle_counts.id;


--
-- Name: deleted_entities; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE deleted_entities (
    id integer NOT NULL,
    entity_type text,
    entity_id integer,
    deleted_at timestamp without time zone,
    account_id integer,
    site_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.deleted_entities OWNER TO nulogy;

--
-- Name: deleted_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE deleted_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deleted_entities_id_seq OWNER TO nulogy;

--
-- Name: deleted_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE deleted_entities_id_seq OWNED BY deleted_entities.id;


--
-- Name: discrepancy_reasons; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE discrepancy_reasons (
    id integer NOT NULL,
    code text,
    reason text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer
);


ALTER TABLE public.discrepancy_reasons OWNER TO nulogy;

--
-- Name: discrepancy_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE discrepancy_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.discrepancy_reasons_id_seq OWNER TO nulogy;

--
-- Name: discrepancy_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE discrepancy_reasons_id_seq OWNED BY discrepancy_reasons.id;


--
-- Name: dock_appointments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE dock_appointments (
    id integer NOT NULL,
    site_id integer,
    external_identifier text,
    customer_id integer,
    bill_to text,
    bill_to_address text,
    carrier_name text,
    carrier_code text,
    carrier_type text,
    carrier_contact text,
    carrier_phone text,
    bill_of_lading_number bigint,
    tracking_number text,
    freight_charge_amount numeric,
    freight_charge_terms text,
    expected_ship_at timestamp without time zone,
    ship_from_phone text,
    ship_from text,
    internal_notes text,
    expected_arrival_at timestamp without time zone,
    min_temperature numeric,
    min_temperature_unit text,
    max_temperature numeric,
    max_temperature_unit text,
    reference_1 text,
    reference_2 text,
    reference_3 text,
    integration_reference_1 text,
    integration_reference_2 text,
    outbound_trailer_route_id integer NOT NULL,
    trailer_length numeric,
    trailer_length_unit text,
    equipment_type text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    outbound_trailer_id integer,
    cancelled boolean DEFAULT false NOT NULL,
    staging_location_id integer
);


ALTER TABLE public.dock_appointments OWNER TO nulogy;

--
-- Name: dock_appointments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE dock_appointments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dock_appointments_id_seq OWNER TO nulogy;

--
-- Name: dock_appointments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE dock_appointments_id_seq OWNED BY dock_appointments.id;


--
-- Name: downtime_reasons; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE downtime_reasons (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    paid boolean DEFAULT false NOT NULL,
    planned boolean DEFAULT false NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    site_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.downtime_reasons OWNER TO nulogy;

--
-- Name: downtime_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE downtime_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.downtime_reasons_id_seq OWNER TO nulogy;

--
-- Name: downtime_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE downtime_reasons_id_seq OWNED BY downtime_reasons.id;


--
-- Name: drop_off_picks; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE drop_off_picks (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    pick_list_pick_id integer,
    from_adjustment_id integer,
    to_adjustment_id integer,
    site_id integer NOT NULL,
    pallet_id integer,
    unit_quantity numeric,
    sku_id integer,
    pick_up_location_id integer,
    destination_location_id integer,
    unit_uom_id integer
);


ALTER TABLE public.drop_off_picks OWNER TO nulogy;

--
-- Name: drop_off_picks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE drop_off_picks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.drop_off_picks_id_seq OWNER TO nulogy;

--
-- Name: drop_off_picks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE drop_off_picks_id_seq OWNED BY drop_off_picks.id;


--
-- Name: edi_configurations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE edi_configurations (
    id integer NOT NULL,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    destination_url_for_outbound_944 text,
    destination_url_for_outbound_850 text,
    ca_certificate_for_outbound_850_file text,
    ca_certificate_for_outbound_944_file text,
    ca_certificate_for_outbound_944_data text,
    ca_certificate_for_outbound_850_data text,
    edi_workflow_mcl_conagra boolean DEFAULT false NOT NULL,
    edi_workflow_exel_clorox boolean DEFAULT false NOT NULL,
    edi_workflow_belvika_hershey boolean DEFAULT false NOT NULL,
    edi_workflow_strive_kraft boolean DEFAULT false,
    edi_workflow_exel_standard boolean DEFAULT false NOT NULL
);


ALTER TABLE public.edi_configurations OWNER TO nulogy;

--
-- Name: edi_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE edi_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edi_configurations_id_seq OWNER TO nulogy;

--
-- Name: edi_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE edi_configurations_id_seq OWNED BY edi_configurations.id;


--
-- Name: edi_customer_triggers; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE edi_customer_triggers (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    customer_id integer,
    site_id integer,
    edi_class text,
    scheduled_846_task_id integer,
    destination_url text
);


ALTER TABLE public.edi_customer_triggers OWNER TO nulogy;

--
-- Name: edi_customer_triggers_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE edi_customer_triggers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edi_customer_triggers_id_seq OWNER TO nulogy;

--
-- Name: edi_customer_triggers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE edi_customer_triggers_id_seq OWNED BY edi_customer_triggers.id;


--
-- Name: edi_inbounds; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE edi_inbounds (
    id integer NOT NULL,
    type text,
    request_xml text,
    site_id integer,
    object_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    details text,
    status integer DEFAULT 0
);


ALTER TABLE public.edi_inbounds OWNER TO nulogy;

--
-- Name: edi_inbounds_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE edi_inbounds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edi_inbounds_id_seq OWNER TO nulogy;

--
-- Name: edi_inbounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE edi_inbounds_id_seq OWNED BY edi_inbounds.id;


--
-- Name: edi_logs; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE edi_logs (
    id integer NOT NULL,
    edi_type text,
    edi_id integer,
    reference_1 text,
    sent_at timestamp without time zone,
    sku_id integer,
    lot_code text,
    expiry_date text,
    transaction_type text,
    unit_quantity numeric(16,5),
    unit_of_measure text,
    site_id integer,
    edi_class text,
    reference_2 text,
    reference_3 text
);


ALTER TABLE public.edi_logs OWNER TO nulogy;

--
-- Name: edi_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE edi_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edi_logs_id_seq OWNER TO nulogy;

--
-- Name: edi_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE edi_logs_id_seq OWNED BY edi_logs.id;


--
-- Name: edi_mapping_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE edi_mapping_items (
    id integer NOT NULL,
    edi_mapping_id integer,
    sku_id integer,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.edi_mapping_items OWNER TO nulogy;

--
-- Name: edi_mapping_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE edi_mapping_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edi_mapping_items_id_seq OWNER TO nulogy;

--
-- Name: edi_mapping_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE edi_mapping_items_id_seq OWNED BY edi_mapping_items.id;


--
-- Name: edi_mappings; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE edi_mappings (
    id integer NOT NULL,
    customer_product_code text,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    default_inbound_item_id integer
);


ALTER TABLE public.edi_mappings OWNER TO nulogy;

--
-- Name: edi_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE edi_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edi_mappings_id_seq OWNER TO nulogy;

--
-- Name: edi_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE edi_mappings_id_seq OWNED BY edi_mappings.id;


--
-- Name: edi_outbounds; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE edi_outbounds (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    sent_at timestamp without time zone,
    status integer DEFAULT 4,
    site_id integer,
    payload text,
    type text,
    source_id integer,
    source_type text,
    source_occurred_at timestamp without time zone,
    customer_id integer,
    error_messages text
);


ALTER TABLE public.edi_outbounds OWNER TO nulogy;

--
-- Name: edi_outbounds_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE edi_outbounds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edi_outbounds_id_seq OWNER TO nulogy;

--
-- Name: edi_outbounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE edi_outbounds_id_seq OWNED BY edi_outbounds.id;


--
-- Name: edi_skip_locations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE edi_skip_locations (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    location_id integer,
    customer_id integer,
    site_id integer
);


ALTER TABLE public.edi_skip_locations OWNER TO nulogy;

--
-- Name: edi_skip_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE edi_skip_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edi_skip_locations_id_seq OWNER TO nulogy;

--
-- Name: edi_skip_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE edi_skip_locations_id_seq OWNED BY edi_skip_locations.id;


--
-- Name: edi_status_locations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE edi_status_locations (
    id integer NOT NULL,
    customer_id integer,
    site_id integer,
    edi_status text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    location_id integer,
    edi_location text
);


ALTER TABLE public.edi_status_locations OWNER TO nulogy;

--
-- Name: edi_status_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE edi_status_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edi_status_locations_id_seq OWNER TO nulogy;

--
-- Name: edi_status_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE edi_status_locations_id_seq OWNED BY edi_status_locations.id;


--
-- Name: email_domains; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE email_domains (
    id integer NOT NULL,
    domain text,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.email_domains OWNER TO nulogy;

--
-- Name: email_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE email_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.email_domains_id_seq OWNER TO nulogy;

--
-- Name: email_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE email_domains_id_seq OWNED BY email_domains.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    event_uid text NOT NULL,
    content text NOT NULL,
    tenant text NOT NULL,
    event_type text NOT NULL,
    site_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    processed boolean DEFAULT false NOT NULL
);


ALTER TABLE public.events OWNER TO nulogy;

--
-- Name: events_conforming_to_cpi; Type: VIEW; Schema: public; Owner: nulogy
--

CREATE VIEW events_conforming_to_cpi AS
 SELECT events.id,
    events.event_uid AS uid,
    events.content,
    events.tenant,
    events.event_type,
    events.site_id,
    events.created_at,
    events.updated_at
   FROM events;


ALTER TABLE public.events_conforming_to_cpi OWNER TO nulogy;

--
-- Name: VIEW events_conforming_to_cpi; Type: COMMENT; Schema: public; Owner: nulogy
--

COMMENT ON VIEW events_conforming_to_cpi IS 'Temporary stopgap for the event shovel until the PM migration shows up and changes the column name properly';


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_id_seq OWNER TO nulogy;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: expected_order_on_dock_appointments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE expected_order_on_dock_appointments (
    id integer NOT NULL,
    site_id integer NOT NULL,
    dock_appointment_id integer NOT NULL,
    ship_order_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.expected_order_on_dock_appointments OWNER TO nulogy;

--
-- Name: expected_order_on_dock_appointments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE expected_order_on_dock_appointments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.expected_order_on_dock_appointments_id_seq OWNER TO nulogy;

--
-- Name: expected_order_on_dock_appointments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE expected_order_on_dock_appointments_id_seq OWNED BY expected_order_on_dock_appointments.id;


--
-- Name: expected_pallet_moves; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE expected_pallet_moves (
    id integer NOT NULL,
    pallet_id integer,
    move_id integer,
    from_location_id integer,
    to_location_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    actualized boolean DEFAULT false,
    site_id integer NOT NULL
);


ALTER TABLE public.expected_pallet_moves OWNER TO nulogy;

--
-- Name: expected_pallet_moves_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE expected_pallet_moves_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.expected_pallet_moves_id_seq OWNER TO nulogy;

--
-- Name: expected_pallet_moves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE expected_pallet_moves_id_seq OWNED BY expected_pallet_moves.id;


--
-- Name: expected_unit_moves; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE expected_unit_moves (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    from_pallet_id integer,
    to_pallet_id integer,
    to_location_id integer,
    sku_id integer,
    lot_code text,
    expiry_date text,
    unit_quantity numeric(16,5) DEFAULT 0,
    move_id integer,
    from_location_id integer,
    actualized boolean DEFAULT false,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    expected_pallet_move_id integer,
    site_id integer NOT NULL,
    inventory_status_id integer,
    unit_uom_id integer
);


ALTER TABLE public.expected_unit_moves OWNER TO nulogy;

--
-- Name: expected_unit_moves_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE expected_unit_moves_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.expected_unit_moves_id_seq OWNER TO nulogy;

--
-- Name: expected_unit_moves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE expected_unit_moves_id_seq OWNED BY expected_unit_moves.id;


--
-- Name: expiry_date_formats; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE expiry_date_formats (
    id integer NOT NULL,
    output_format_string text,
    user_format_guide text,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    input_format_string text
);


ALTER TABLE public.expiry_date_formats OWNER TO nulogy;

--
-- Name: expiry_date_formats_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE expiry_date_formats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.expiry_date_formats_id_seq OWNER TO nulogy;

--
-- Name: expiry_date_formats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE expiry_date_formats_id_seq OWNED BY expiry_date_formats.id;


--
-- Name: external_inventory_levels; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE external_inventory_levels (
    id integer NOT NULL,
    site_id integer,
    sku_id integer,
    lot_code text,
    expiry_date text,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    external_inventory_location_id integer,
    unit_uom_id integer
);


ALTER TABLE public.external_inventory_levels OWNER TO nulogy;

--
-- Name: external_inventory_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE external_inventory_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.external_inventory_levels_id_seq OWNER TO nulogy;

--
-- Name: external_inventory_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE external_inventory_levels_id_seq OWNED BY external_inventory_levels.id;


--
-- Name: external_inventory_locations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE external_inventory_locations (
    id integer NOT NULL,
    site_id integer,
    external_identifier character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.external_inventory_locations OWNER TO nulogy;

--
-- Name: external_inventory_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE external_inventory_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.external_inventory_locations_id_seq OWNER TO nulogy;

--
-- Name: external_inventory_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE external_inventory_locations_id_seq OWNED BY external_inventory_locations.id;


--
-- Name: floor_locations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE floor_locations (
    id integer NOT NULL,
    location_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description text,
    inbound boolean DEFAULT false,
    outbound boolean DEFAULT false,
    site_id integer
);


ALTER TABLE public.floor_locations OWNER TO nulogy;

--
-- Name: floor_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE floor_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.floor_locations_id_seq OWNER TO nulogy;

--
-- Name: floor_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE floor_locations_id_seq OWNED BY floor_locations.id;


--
-- Name: gl_accounts; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE gl_accounts (
    id integer NOT NULL,
    list_id text,
    full_name text,
    account_type text,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.gl_accounts OWNER TO nulogy;

--
-- Name: gl_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE gl_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gl_accounts_id_seq OWNER TO nulogy;

--
-- Name: gl_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE gl_accounts_id_seq OWNED BY gl_accounts.id;


--
-- Name: gs1_gsin_sequences; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE gs1_gsin_sequences (
    id integer NOT NULL,
    site_id integer,
    customer_id integer,
    company_prefix character varying(255),
    current_value integer,
    maximum_value bigint,
    lock_version integer DEFAULT 0,
    active boolean DEFAULT true,
    start_value integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    site_wide boolean DEFAULT false
);


ALTER TABLE public.gs1_gsin_sequences OWNER TO nulogy;

--
-- Name: gs1_gsin_sequences_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE gs1_gsin_sequences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gs1_gsin_sequences_id_seq OWNER TO nulogy;

--
-- Name: gs1_gsin_sequences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE gs1_gsin_sequences_id_seq OWNED BY gs1_gsin_sequences.id;


--
-- Name: gs1_sscc_sequences; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE gs1_sscc_sequences (
    id integer NOT NULL,
    site_id integer,
    customer_id integer,
    extension_digit integer,
    company_prefix character varying(255),
    current_value integer,
    maximum_value integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    lock_version integer DEFAULT 0,
    active boolean DEFAULT true,
    start_value integer,
    site_wide boolean DEFAULT false
);


ALTER TABLE public.gs1_sscc_sequences OWNER TO nulogy;

--
-- Name: gs1_sscc_sequences_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE gs1_sscc_sequences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gs1_sscc_sequences_id_seq OWNER TO nulogy;

--
-- Name: gs1_sscc_sequences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE gs1_sscc_sequences_id_seq OWNED BY gs1_sscc_sequences.id;


--
-- Name: item_shelf_lives; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE item_shelf_lives (
    id integer NOT NULL,
    account_id integer,
    customer_id integer,
    label text,
    shelf_life integer,
    unit text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.item_shelf_lives OWNER TO nulogy;

--
-- Name: icg_item_shelf_lives_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE icg_item_shelf_lives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.icg_item_shelf_lives_id_seq OWNER TO nulogy;

--
-- Name: icg_item_shelf_lives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE icg_item_shelf_lives_id_seq OWNED BY item_shelf_lives.id;


--
-- Name: icg_reference_data_fields; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE icg_reference_data_fields (
    id integer NOT NULL,
    reference_data_table_id integer,
    field_name text,
    length integer,
    required boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    custom boolean DEFAULT true,
    account_id integer
);


ALTER TABLE public.icg_reference_data_fields OWNER TO nulogy;

--
-- Name: icg_reference_data_field_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE icg_reference_data_field_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.icg_reference_data_field_infos_id_seq OWNER TO nulogy;

--
-- Name: icg_reference_data_field_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE icg_reference_data_field_infos_id_seq OWNED BY icg_reference_data_fields.id;


--
-- Name: icg_reference_data_rows; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE icg_reference_data_rows (
    id integer NOT NULL,
    key text,
    reference_data_table_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    data extensions.hstore,
    account_id integer
);


ALTER TABLE public.icg_reference_data_rows OWNER TO nulogy;

--
-- Name: icg_reference_data_tables; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE icg_reference_data_tables (
    id integer NOT NULL,
    customer_id integer,
    table_name text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    editable boolean DEFAULT true,
    key_type text DEFAULT 'string'::character varying,
    account_id integer
);


ALTER TABLE public.icg_reference_data_tables OWNER TO nulogy;

--
-- Name: icg_reference_data_types_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE icg_reference_data_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.icg_reference_data_types_id_seq OWNER TO nulogy;

--
-- Name: icg_reference_data_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE icg_reference_data_types_id_seq OWNED BY icg_reference_data_tables.id;


--
-- Name: icg_reference_datum_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE icg_reference_datum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.icg_reference_datum_id_seq OWNER TO nulogy;

--
-- Name: icg_reference_datum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE icg_reference_datum_id_seq OWNED BY icg_reference_data_rows.id;


--
-- Name: icg_rule_fragments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE icg_rule_fragments (
    id integer NOT NULL,
    rule_id integer,
    name text,
    data_type text,
    reference_table text,
    reference_field_name text,
    "from" integer,
    "to" integer,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    use_for_interpretation boolean DEFAULT false NOT NULL,
    driver text
);


ALTER TABLE public.icg_rule_fragments OWNER TO nulogy;

--
-- Name: icg_rule_fragments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE icg_rule_fragments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.icg_rule_fragments_id_seq OWNER TO nulogy;

--
-- Name: icg_rule_fragments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE icg_rule_fragments_id_seq OWNED BY icg_rule_fragments.id;


--
-- Name: icg_rules; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE icg_rules (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name text,
    description text,
    type text,
    customer_id integer,
    account_id integer,
    lot_code_length integer DEFAULT 0,
    state_name text,
    shelf_life_strategy text,
    operation text,
    date_rounding_field text
);


ALTER TABLE public.icg_rules OWNER TO nulogy;

--
-- Name: icg_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE icg_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.icg_rules_id_seq OWNER TO nulogy;

--
-- Name: icg_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE icg_rules_id_seq OWNED BY icg_rules.id;


--
-- Name: imported_inventories; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE imported_inventories (
    id integer NOT NULL,
    xml_data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id integer NOT NULL
);


ALTER TABLE public.imported_inventories OWNER TO nulogy;

--
-- Name: imported_inventories_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE imported_inventories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.imported_inventories_id_seq OWNER TO nulogy;

--
-- Name: imported_inventories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE imported_inventories_id_seq OWNED BY imported_inventories.id;


--
-- Name: inbound_stock_transfer_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE inbound_stock_transfer_items (
    id integer NOT NULL,
    site_id integer,
    sku_id integer,
    inventory_adjustment_id integer,
    location_id integer,
    unit_quantity numeric(16,5) DEFAULT 0,
    old_each_quantity numeric(16,5) DEFAULT 0,
    lot_code text,
    expiry_date text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    inbound_stock_transfer_pallet_id integer,
    external_identifier text,
    inventory_status_id integer,
    unit_uom_id integer
);


ALTER TABLE public.inbound_stock_transfer_items OWNER TO nulogy;

--
-- Name: inbound_stock_transfer_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE inbound_stock_transfer_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inbound_stock_transfer_items_id_seq OWNER TO nulogy;

--
-- Name: inbound_stock_transfer_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE inbound_stock_transfer_items_id_seq OWNED BY inbound_stock_transfer_items.id;


--
-- Name: inbound_stock_transfer_order_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE inbound_stock_transfer_order_items (
    id integer NOT NULL,
    inbound_stock_transfer_order_id integer,
    sku_id integer,
    pre_rounded_unit_quantity numeric,
    old_each_quantity numeric,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    unit_quantity numeric,
    pre_rounded_uom_code text,
    notes text,
    lot_code character varying(255),
    expiry_date character varying(255),
    unit_uom_id integer
);


ALTER TABLE public.inbound_stock_transfer_order_items OWNER TO nulogy;

--
-- Name: inbound_stock_transfer_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE inbound_stock_transfer_order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inbound_stock_transfer_order_items_id_seq OWNER TO nulogy;

--
-- Name: inbound_stock_transfer_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE inbound_stock_transfer_order_items_id_seq OWNED BY inbound_stock_transfer_order_items.id;


--
-- Name: inbound_stock_transfer_orders; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE inbound_stock_transfer_orders (
    id integer NOT NULL,
    project_id integer,
    unit_quantity numeric,
    deliver_by timestamp without time zone,
    location_id integer,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    job_id integer,
    reference text,
    created_by text,
    status text DEFAULT 'new'::text,
    unit_uom_id integer
);


ALTER TABLE public.inbound_stock_transfer_orders OWNER TO nulogy;

--
-- Name: inbound_stock_transfer_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE inbound_stock_transfer_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inbound_stock_transfer_orders_id_seq OWNER TO nulogy;

--
-- Name: inbound_stock_transfer_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE inbound_stock_transfer_orders_id_seq OWNED BY inbound_stock_transfer_orders.id;


--
-- Name: inbound_stock_transfer_pallets; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE inbound_stock_transfer_pallets (
    id integer NOT NULL,
    inbound_stock_transfer_id integer,
    pallet_id integer,
    site_id integer,
    transferred_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    transfer_status text,
    external_identifier text
);


ALTER TABLE public.inbound_stock_transfer_pallets OWNER TO nulogy;

--
-- Name: inbound_stock_transfer_pallets_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE inbound_stock_transfer_pallets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inbound_stock_transfer_pallets_id_seq OWNER TO nulogy;

--
-- Name: inbound_stock_transfer_pallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE inbound_stock_transfer_pallets_id_seq OWNED BY inbound_stock_transfer_pallets.id;


--
-- Name: inbound_stock_transfers; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE inbound_stock_transfers (
    id integer NOT NULL,
    inbound_stock_transfer_order_id integer,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    transfer_status text DEFAULT 'completed'::character varying NOT NULL,
    external_identifier text
);


ALTER TABLE public.inbound_stock_transfers OWNER TO nulogy;

--
-- Name: inbound_stock_transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE inbound_stock_transfers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inbound_stock_transfers_id_seq OWNER TO nulogy;

--
-- Name: inbound_stock_transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE inbound_stock_transfers_id_seq OWNED BY inbound_stock_transfers.id;


--
-- Name: inventory_adjustments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE inventory_adjustments (
    id integer NOT NULL,
    sku_id integer,
    lot_code text,
    unit_quantity numeric(16,5) DEFAULT NULL::numeric,
    base_quantity_value numeric(16,5) DEFAULT NULL::numeric,
    pallet_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    location_id integer,
    expiry_date text,
    expires_on date,
    unit_uom_id integer,
    inventory_status_id integer
);


ALTER TABLE public.inventory_adjustments OWNER TO nulogy;

--
-- Name: inventory_adjustments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE inventory_adjustments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventory_adjustments_id_seq OWNER TO nulogy;

--
-- Name: inventory_adjustments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE inventory_adjustments_id_seq OWNED BY inventory_adjustments.id;


--
-- Name: inventory_discrepancies; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE inventory_discrepancies (
    id integer NOT NULL,
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    user_id integer,
    reason text,
    remove_adjustment_id integer,
    add_adjustment_id integer,
    site_id integer,
    production_id integer,
    subcomponent_consumption_id integer,
    receipt_item_id integer,
    rejected_item_id integer,
    qb_txn_id text,
    synchronized_status text,
    qb_last_sync_at timestamp without time zone,
    cycle_count_id integer,
    shipment_id integer,
    user_generated boolean DEFAULT false,
    job_reconciliation_id integer,
    discrepancy_reason_id integer,
    blind_count_id integer,
    sign_off_user_id integer,
    external_identifier text
);


ALTER TABLE public.inventory_discrepancies OWNER TO nulogy;

--
-- Name: inventory_discrepancies_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE inventory_discrepancies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventory_discrepancies_id_seq OWNER TO nulogy;

--
-- Name: inventory_discrepancies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE inventory_discrepancies_id_seq OWNED BY inventory_discrepancies.id;


--
-- Name: inventory_snapshot_schedules; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE inventory_snapshot_schedules (
    id integer NOT NULL,
    customer_id integer,
    site_id integer,
    scheduled_task_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    snapshot_type character varying(255),
    include_inventory_in_wip boolean DEFAULT false,
    name text
);


ALTER TABLE public.inventory_snapshot_schedules OWNER TO nulogy;

--
-- Name: inventory_snapshot_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE inventory_snapshot_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventory_snapshot_schedules_id_seq OWNER TO nulogy;

--
-- Name: inventory_snapshot_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE inventory_snapshot_schedules_id_seq OWNED BY inventory_snapshot_schedules.id;


--
-- Name: inventory_snapshots; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE inventory_snapshots (
    id integer NOT NULL,
    site_id integer,
    customer_id integer,
    inventory_snapshot_rows_old text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    xml_payload text
);


ALTER TABLE public.inventory_snapshots OWNER TO nulogy;

--
-- Name: inventory_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE inventory_snapshots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventory_snapshots_id_seq OWNER TO nulogy;

--
-- Name: inventory_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE inventory_snapshots_id_seq OWNED BY inventory_snapshots.id;


--
-- Name: inventory_status_configurations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE inventory_status_configurations (
    id integer NOT NULL,
    site_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    inventory_created_by_blind_count_status_id integer NOT NULL,
    editable boolean DEFAULT false NOT NULL,
    inventory_rejected_on_jobs_status_id integer NOT NULL,
    auto_quarantine_on_receipt integer NOT NULL,
    auto_quarantine_on_receipt_status_id integer,
    auto_quarantine_on_production integer NOT NULL,
    auto_quarantine_on_production_status_id integer
);


ALTER TABLE public.inventory_status_configurations OWNER TO nulogy;

--
-- Name: inventory_status_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE inventory_status_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventory_status_configurations_id_seq OWNER TO nulogy;

--
-- Name: inventory_status_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE inventory_status_configurations_id_seq OWNED BY inventory_status_configurations.id;


--
-- Name: inventory_statuses; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE inventory_statuses (
    id integer NOT NULL,
    name text,
    integration_key text,
    site_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category_id character varying(255),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.inventory_statuses OWNER TO nulogy;

--
-- Name: inventory_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE inventory_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventory_statuses_id_seq OWNER TO nulogy;

--
-- Name: inventory_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE inventory_statuses_id_seq OWNED BY inventory_statuses.id;


--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE invoice_items (
    id integer NOT NULL,
    sku_id integer,
    notes text,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    unit_rate numeric(16,5) DEFAULT 0.0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    invoice_id integer,
    shipment_id integer,
    site_id integer NOT NULL,
    project_id integer,
    lot_code text,
    expiry_date text,
    unit_uom_id integer
);


ALTER TABLE public.invoice_items OWNER TO nulogy;

--
-- Name: invoice_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE invoice_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invoice_items_id_seq OWNER TO nulogy;

--
-- Name: invoice_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE invoice_items_id_seq OWNED BY invoice_items.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE invoices (
    id integer NOT NULL,
    customer_id integer,
    invoiced_at timestamp without time zone,
    terms text,
    payment_due_on date,
    reference_1 text,
    customer_notes text,
    internal_notes text,
    paid_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    invoice_type text,
    bill_to text,
    bill_to_address text,
    site_id integer,
    qb_txn_id text,
    qb_last_sync_at timestamp without time zone,
    synchronized_status text,
    quickbooks_reference_number text,
    quickbooks_po_number text,
    reference_2 text,
    status text DEFAULT 'open'::text
);


ALTER TABLE public.invoices OWNER TO nulogy;

--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invoices_id_seq OWNER TO nulogy;

--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE invoices_id_seq OWNED BY invoices.id;


--
-- Name: ip_white_list_entries; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE ip_white_list_entries (
    id integer NOT NULL,
    address text NOT NULL,
    netmask text NOT NULL,
    enabled boolean DEFAULT true,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description text NOT NULL
);


ALTER TABLE public.ip_white_list_entries OWNER TO nulogy;

--
-- Name: ip_white_list_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE ip_white_list_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ip_white_list_entries_id_seq OWNER TO nulogy;

--
-- Name: ip_white_list_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE ip_white_list_entries_id_seq OWNED BY ip_white_list_entries.id;


--
-- Name: item_carts; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE item_carts (
    id integer NOT NULL,
    user_id integer,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    location_id integer
);


ALTER TABLE public.item_carts OWNER TO nulogy;

--
-- Name: item_carts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE item_carts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.item_carts_id_seq OWNER TO nulogy;

--
-- Name: item_carts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE item_carts_id_seq OWNED BY item_carts.id;


--
-- Name: item_categories; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE item_categories (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name text,
    account_id integer
);


ALTER TABLE public.item_categories OWNER TO nulogy;

--
-- Name: item_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE item_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.item_categories_id_seq OWNER TO nulogy;

--
-- Name: item_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE item_categories_id_seq OWNED BY item_categories.id;


--
-- Name: item_classes; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE item_classes (
    id integer NOT NULL,
    name character varying(255),
    account_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.item_classes OWNER TO nulogy;

--
-- Name: item_classes_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE item_classes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.item_classes_id_seq OWNER TO nulogy;

--
-- Name: item_classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE item_classes_id_seq OWNED BY item_classes.id;


--
-- Name: item_families; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE item_families (
    id integer NOT NULL,
    name text,
    account_id integer,
    customer_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.item_families OWNER TO nulogy;

--
-- Name: item_families_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE item_families_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.item_families_id_seq OWNER TO nulogy;

--
-- Name: item_families_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE item_families_id_seq OWNED BY item_families.id;


--
-- Name: item_types; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE item_types (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name text,
    account_id integer,
    pick_strategy text DEFAULT 'none'::character varying NOT NULL
);


ALTER TABLE public.item_types OWNER TO nulogy;

--
-- Name: item_types_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE item_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.item_types_id_seq OWNER TO nulogy;

--
-- Name: item_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE item_types_id_seq OWNED BY item_types.id;


--
-- Name: job_lot_expiries; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE job_lot_expiries (
    id integer NOT NULL,
    sku_id integer,
    job_id integer,
    lot_code text,
    expiry_date text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL
);


ALTER TABLE public.job_lot_expiries OWNER TO nulogy;

--
-- Name: job_lot_expiries_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE job_lot_expiries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_lot_expiries_id_seq OWNER TO nulogy;

--
-- Name: job_lot_expiries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE job_lot_expiries_id_seq OWNED BY job_lot_expiries.id;


--
-- Name: job_reconciliation_counts; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE job_reconciliation_counts (
    id integer NOT NULL,
    sku_id integer,
    job_reconciliation_id integer,
    lot_code text,
    expiry_date text,
    old_each_quantity numeric(16,5),
    unit_quantity numeric(16,5),
    site_id integer,
    pallet_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    expires_on date,
    unit_uom_id integer
);


ALTER TABLE public.job_reconciliation_counts OWNER TO nulogy;

--
-- Name: job_reconciliation_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE job_reconciliation_counts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_reconciliation_counts_id_seq OWNER TO nulogy;

--
-- Name: job_reconciliation_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE job_reconciliation_counts_id_seq OWNED BY job_reconciliation_counts.id;


--
-- Name: job_reconciliation_records; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE job_reconciliation_records (
    id integer NOT NULL,
    eaches_original numeric(16,5) DEFAULT 0,
    eaches_updated numeric(16,5) DEFAULT 0,
    sku_id integer,
    job_reconciliation_id integer,
    site_id integer,
    created_at timestamp without time zone,
    base_quantity_original numeric(16,5) DEFAULT 0.0,
    base_quantity_updated numeric(16,5) DEFAULT 0.0,
    reconciliation_reason_id integer,
    notes text,
    percentage_adjusted numeric(16,5),
    adjusted_by_id integer
);


ALTER TABLE public.job_reconciliation_records OWNER TO nulogy;

--
-- Name: job_reconciliation_records_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE job_reconciliation_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_reconciliation_records_id_seq OWNER TO nulogy;

--
-- Name: job_reconciliation_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE job_reconciliation_records_id_seq OWNED BY job_reconciliation_records.id;


--
-- Name: job_reconciliations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE job_reconciliations (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    reconciled_at timestamp without time zone
);


ALTER TABLE public.job_reconciliations OWNER TO nulogy;

--
-- Name: job_reconciliations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE job_reconciliations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_reconciliations_id_seq OWNER TO nulogy;

--
-- Name: job_reconciliations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE job_reconciliations_id_seq OWNED BY job_reconciliations.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE jobs (
    id integer NOT NULL,
    project_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    scheduled_start_at timestamp without time zone,
    scheduled_end_at timestamp without time zone,
    review boolean DEFAULT false,
    accepted_by_id integer,
    status text DEFAULT 'stopped'::character varying,
    units_expected numeric(16,5) DEFAULT 0 NOT NULL,
    invoice_item_id integer,
    comments text,
    reference text,
    line_id integer,
    qb_production_txn_id text,
    qb_labor_txn_id text,
    qb_last_sync_at timestamp without time zone,
    synchronized_status text,
    site_id integer NOT NULL,
    qb_non_production_labour_txn_id text,
    base_quantity_produced numeric(16,5) DEFAULT 0.0,
    lock_version integer DEFAULT 0,
    started_at timestamp without time zone,
    ended_at timestamp without time zone,
    wip_pallet_id integer,
    job_reconciliation_id integer,
    reconciliation_status integer DEFAULT 0 NOT NULL,
    pick_plan_id integer,
    efficiency numeric(16,5),
    total_consumed_quantity integer,
    total_rejected_quantity integer,
    actual_uptime numeric(16,5),
    planned_uptime numeric(16,5),
    pallets_produced integer DEFAULT 0 NOT NULL,
    external_identifier text
);


ALTER TABLE public.jobs OWNER TO nulogy;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jobs_id_seq OWNER TO nulogy;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: licensing_events; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE licensing_events (
    id integer NOT NULL,
    holder_id integer,
    holder_type text,
    billee_id integer,
    billee_type text,
    event_type text,
    license_type text,
    occurred_at timestamp without time zone
);


ALTER TABLE public.licensing_events OWNER TO nulogy;

--
-- Name: licensing_events_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE licensing_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.licensing_events_id_seq OWNER TO nulogy;

--
-- Name: licensing_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE licensing_events_id_seq OWNED BY licensing_events.id;


--
-- Name: lines; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE lines (
    id integer NOT NULL,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    location_id integer,
    site_id integer,
    wip_pallet_id integer,
    inactive boolean DEFAULT false
);


ALTER TABLE public.lines OWNER TO nulogy;

--
-- Name: lines_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE lines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lines_id_seq OWNER TO nulogy;

--
-- Name: lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE lines_id_seq OWNED BY lines.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE locations (
    id integer NOT NULL,
    name text,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pallet_capacity integer DEFAULT 1,
    code text,
    active boolean DEFAULT true,
    warehouse_zone_id integer
);


ALTER TABLE public.locations OWNER TO nulogy;

--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.locations_id_seq OWNER TO nulogy;

--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE locations_id_seq OWNED BY locations.id;


--
-- Name: master_reference_documents; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE master_reference_documents (
    id integer NOT NULL,
    document text,
    description text,
    customer_id integer,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.master_reference_documents OWNER TO nulogy;

--
-- Name: master_reference_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE master_reference_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.master_reference_documents_id_seq OWNER TO nulogy;

--
-- Name: master_reference_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE master_reference_documents_id_seq OWNED BY master_reference_documents.id;


--
-- Name: mcl_edi_947_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE mcl_edi_947_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mcl_edi_947_id_seq OWNER TO nulogy;

--
-- Name: modification_restrictions; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE modification_restrictions (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sku_id integer,
    locker_id integer,
    site_id integer NOT NULL
);


ALTER TABLE public.modification_restrictions OWNER TO nulogy;

--
-- Name: modification_restrictions_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE modification_restrictions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.modification_restrictions_id_seq OWNER TO nulogy;

--
-- Name: modification_restrictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE modification_restrictions_id_seq OWNED BY modification_restrictions.id;


--
-- Name: pick_plans; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE pick_plans (
    id integer NOT NULL,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pick_plan_type text
);


ALTER TABLE public.pick_plans OWNER TO nulogy;

--
-- Name: move_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE move_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.move_orders_id_seq OWNER TO nulogy;

--
-- Name: move_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE move_orders_id_seq OWNED BY pick_plans.id;


--
-- Name: moves; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE moves (
    id integer NOT NULL,
    site_id integer,
    requested_at timestamp without time zone,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    assigned_to_id integer,
    status text DEFAULT 'open'::character varying,
    job_id integer,
    pick_plan_id integer,
    pick_constraint_id integer,
    shipment_id integer
);


ALTER TABLE public.moves OWNER TO nulogy;

--
-- Name: moves_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE moves_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.moves_id_seq OWNER TO nulogy;

--
-- Name: moves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE moves_id_seq OWNED BY moves.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id integer,
    company_id integer,
    title text,
    message text,
    message_type text,
    active boolean DEFAULT false NOT NULL,
    require_acknowledgement boolean DEFAULT false NOT NULL
);


ALTER TABLE public.notifications OWNER TO nulogy;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO nulogy;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: outbound_stock_transfer_pallets; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE outbound_stock_transfer_pallets (
    id integer NOT NULL,
    site_id integer,
    pallet_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    status integer DEFAULT 1,
    transferred_at timestamp without time zone,
    outbound_stock_transfer_id integer,
    project_id integer
);


ALTER TABLE public.outbound_stock_transfer_pallets OWNER TO nulogy;

--
-- Name: outbound_stock_transfer_pallets_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE outbound_stock_transfer_pallets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.outbound_stock_transfer_pallets_id_seq OWNER TO nulogy;

--
-- Name: outbound_stock_transfer_pallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE outbound_stock_transfer_pallets_id_seq OWNED BY outbound_stock_transfer_pallets.id;


--
-- Name: outbound_stock_transfer_units; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE outbound_stock_transfer_units (
    id integer NOT NULL,
    site_id integer,
    sku_id integer,
    pallet_id integer,
    location_id integer,
    unit_quantity numeric(16,5) DEFAULT 0,
    old_each_quantity numeric(16,5) DEFAULT 0,
    lot_code text,
    expiry_date text,
    inventory_adjustment_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    outbound_stock_transfer_pallet_id integer,
    inventory_status_id integer,
    unit_uom_id integer
);


ALTER TABLE public.outbound_stock_transfer_units OWNER TO nulogy;

--
-- Name: outbound_stock_transfer_units_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE outbound_stock_transfer_units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.outbound_stock_transfer_units_id_seq OWNER TO nulogy;

--
-- Name: outbound_stock_transfer_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE outbound_stock_transfer_units_id_seq OWNED BY outbound_stock_transfer_units.id;


--
-- Name: outbound_stock_transfers; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE outbound_stock_transfers (
    id integer NOT NULL,
    site_id integer,
    status integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reference_1 text,
    reference_2 text
);


ALTER TABLE public.outbound_stock_transfers OWNER TO nulogy;

--
-- Name: outbound_stock_transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE outbound_stock_transfers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.outbound_stock_transfers_id_seq OWNER TO nulogy;

--
-- Name: outbound_stock_transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE outbound_stock_transfers_id_seq OWNED BY outbound_stock_transfers.id;


--
-- Name: outbound_trailer_routes; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE outbound_trailer_routes (
    id integer NOT NULL,
    site_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.outbound_trailer_routes OWNER TO nulogy;

--
-- Name: outbound_trailer_routes_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE outbound_trailer_routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.outbound_trailer_routes_id_seq OWNER TO nulogy;

--
-- Name: outbound_trailer_routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE outbound_trailer_routes_id_seq OWNED BY outbound_trailer_routes.id;


--
-- Name: outbound_trailer_stops; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE outbound_trailer_stops (
    id integer NOT NULL,
    consignee_name text,
    number integer,
    outbound_trailer_route_id integer,
    site_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    bill_of_lading_number text
);


ALTER TABLE public.outbound_trailer_stops OWNER TO nulogy;

--
-- Name: outbound_trailer_stops_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE outbound_trailer_stops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.outbound_trailer_stops_id_seq OWNER TO nulogy;

--
-- Name: outbound_trailer_stops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE outbound_trailer_stops_id_seq OWNED BY outbound_trailer_stops.id;


--
-- Name: outbound_trailers; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE outbound_trailers (
    id integer NOT NULL,
    site_id integer,
    external_identifier text,
    shipped boolean DEFAULT false,
    customer_id integer,
    bill_to text,
    bill_to_address text,
    carrier_name text,
    carrier_code text,
    carrier_type text,
    carrier_contact text,
    carrier_phone text,
    bill_of_lading_number bigint,
    trailer_number text,
    seal_number text,
    tracking_number text,
    freight_charge_amount numeric,
    freight_charge_terms text,
    expected_ship_at timestamp without time zone,
    actual_ship_at timestamp without time zone,
    ship_from_phone text,
    ship_from text,
    staging_location_id integer,
    internal_notes text,
    invoice_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    expected_arrival_at timestamp without time zone,
    min_temperature numeric,
    min_temperature_unit text,
    max_temperature numeric,
    max_temperature_unit text,
    reference_1 text,
    reference_2 text,
    reference_3 text,
    integration_reference_1 text,
    integration_reference_2 text,
    actual_arrival_at timestamp without time zone,
    trailer_length numeric,
    trailer_length_unit text,
    outbound_trailer_route_id integer NOT NULL,
    equipment_type text,
    dock_appointment_id integer,
    shipped_by_id integer
);


ALTER TABLE public.outbound_trailers OWNER TO nulogy;

--
-- Name: outbound_trailers_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE outbound_trailers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.outbound_trailers_id_seq OWNER TO nulogy;

--
-- Name: outbound_trailers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE outbound_trailers_id_seq OWNED BY outbound_trailers.id;


--
-- Name: overhead_worksheets; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE overhead_worksheets (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    scenario_id integer,
    labour_percentage numeric(16,5) DEFAULT 0.0,
    account_id integer
);


ALTER TABLE public.overhead_worksheets OWNER TO nulogy;

--
-- Name: overhead_worksheets_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE overhead_worksheets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.overhead_worksheets_id_seq OWNER TO nulogy;

--
-- Name: overhead_worksheets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE overhead_worksheets_id_seq OWNED BY overhead_worksheets.id;


--
-- Name: pallet_assignments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE pallet_assignments (
    id integer NOT NULL,
    site_id integer NOT NULL,
    pallet_id integer,
    assigned_for_id integer,
    assigned_for_type text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.pallet_assignments OWNER TO nulogy;

--
-- Name: pallet_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE pallet_assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pallet_assignments_id_seq OWNER TO nulogy;

--
-- Name: pallet_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE pallet_assignments_id_seq OWNED BY pallet_assignments.id;


--
-- Name: pallet_charge_settings; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE pallet_charge_settings (
    id integer NOT NULL,
    account_id integer,
    name text,
    default_charge numeric(16,5) DEFAULT 0,
    default_charge_full_amount_for_partial boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT false
);


ALTER TABLE public.pallet_charge_settings OWNER TO nulogy;

--
-- Name: pallet_charge_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE pallet_charge_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pallet_charge_settings_id_seq OWNER TO nulogy;

--
-- Name: pallet_charge_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE pallet_charge_settings_id_seq OWNED BY pallet_charge_settings.id;


--
-- Name: pallet_charges; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE pallet_charges (
    id integer NOT NULL,
    account_id integer,
    scenario_charge_id integer,
    name text,
    charge numeric(16,5) DEFAULT 0,
    charge_full_amount_for_partial boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.pallet_charges OWNER TO nulogy;

--
-- Name: pallet_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE pallet_charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pallet_charges_id_seq OWNER TO nulogy;

--
-- Name: pallet_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE pallet_charges_id_seq OWNED BY pallet_charges.id;


--
-- Name: pallet_moves; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE pallet_moves (
    id integer NOT NULL,
    move_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    status integer DEFAULT 1 NOT NULL,
    site_id integer NOT NULL
);


ALTER TABLE public.pallet_moves OWNER TO nulogy;

--
-- Name: pallet_moves_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE pallet_moves_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pallet_moves_id_seq OWNER TO nulogy;

--
-- Name: pallet_moves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE pallet_moves_id_seq OWNED BY pallet_moves.id;


--
-- Name: pallet_shipments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE pallet_shipments (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pallet_id integer,
    shipment_id integer,
    site_id integer,
    purchase_order_number text,
    confirmed boolean,
    customer_reference text,
    tracking_number text,
    sscc text
);


ALTER TABLE public.pallet_shipments OWNER TO nulogy;

--
-- Name: pallet_shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE pallet_shipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pallet_shipments_id_seq OWNER TO nulogy;

--
-- Name: pallet_shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE pallet_shipments_id_seq OWNED BY pallet_shipments.id;


--
-- Name: pallets; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE pallets (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    job_id integer,
    reference text,
    site_id integer,
    shipped boolean DEFAULT false,
    number extensions.citext NOT NULL,
    pallet_type integer DEFAULT 0 NOT NULL,
    generated_at timestamp without time zone,
    lock_version integer DEFAULT 0 NOT NULL,
    reserve_for_id integer,
    reserve_for_class text,
    sequence_number integer
);


ALTER TABLE public.pallets OWNER TO nulogy;

--
-- Name: pallets_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE pallets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pallets_id_seq OWNER TO nulogy;

--
-- Name: pallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE pallets_id_seq OWNED BY pallets.id;


--
-- Name: pg_stat_activity_allusers; Type: VIEW; Schema: public; Owner: nulogy
--

CREATE VIEW pg_stat_activity_allusers AS
 SELECT get_sa.datid,
    get_sa.datname,
    get_sa.procpid,
    get_sa.usesysid,
    get_sa.usename,
    get_sa.application_name,
    get_sa.client_addr,
    get_sa.client_hostname,
    get_sa.client_port,
    get_sa.backend_start,
    get_sa.xact_start,
    get_sa.query_start,
    get_sa.waiting,
    get_sa.current_query
   FROM get_sa() get_sa(datid, datname, procpid, usesysid, usename, application_name, client_addr, client_hostname, client_port, backend_start, xact_start, query_start, waiting, current_query, state, query);


ALTER TABLE public.pg_stat_activity_allusers OWNER TO nulogy;

--
-- Name: priority_configurations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE priority_configurations (
    id integer NOT NULL,
    site_id integer,
    pick_plan_id integer,
    sku_id integer,
    lot_code text,
    expiry_date text,
    priority integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.priority_configurations OWNER TO nulogy;

--
-- Name: pick_constraint_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE pick_constraint_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pick_constraint_templates_id_seq OWNER TO nulogy;

--
-- Name: pick_constraint_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE pick_constraint_templates_id_seq OWNED BY priority_configurations.id;


--
-- Name: pick_constraints; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE pick_constraints (
    id integer NOT NULL,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.pick_constraints OWNER TO nulogy;

--
-- Name: pick_list_line_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE pick_list_line_items (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    site_id integer NOT NULL,
    pick_list_id integer NOT NULL,
    sku_id integer NOT NULL,
    unit_quantity numeric(21,10) NOT NULL,
    lot_code text,
    expiry_date text,
    exact_quantity_pick boolean DEFAULT false,
    unit_uom_id integer
);


ALTER TABLE public.pick_list_line_items OWNER TO nulogy;

--
-- Name: pick_list_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE pick_list_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pick_list_line_items_id_seq OWNER TO nulogy;

--
-- Name: pick_list_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE pick_list_line_items_id_seq OWNED BY pick_list_line_items.id;


--
-- Name: pick_list_picks; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE pick_list_picks (
    id integer NOT NULL,
    pick_list_id integer,
    pallet_id integer,
    site_id integer NOT NULL,
    status text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.pick_list_picks OWNER TO nulogy;

--
-- Name: pick_list_picks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE pick_list_picks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pick_list_picks_id_seq OWNER TO nulogy;

--
-- Name: pick_list_picks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE pick_list_picks_id_seq OWNED BY pick_list_picks.id;


--
-- Name: pick_lists; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE pick_lists (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    site_id integer NOT NULL,
    reservable_id integer,
    destination_location_id integer,
    status character varying(255) NOT NULL,
    notes text,
    reservable_type text NOT NULL
);


ALTER TABLE public.pick_lists OWNER TO nulogy;

--
-- Name: pick_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE pick_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pick_lists_id_seq OWNER TO nulogy;

--
-- Name: pick_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE pick_lists_id_seq OWNED BY pick_lists.id;


--
-- Name: pick_plan_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE pick_plan_items (
    id integer NOT NULL,
    sku_id integer,
    site_id integer,
    pick_plan_id integer,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    base_quantity numeric(16,5) DEFAULT 0.0
);


ALTER TABLE public.pick_plan_items OWNER TO nulogy;

--
-- Name: pick_up_picks; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE pick_up_picks (
    id integer NOT NULL,
    pick_list_pick_id integer,
    from_adjustment_id integer,
    to_adjustment_id integer,
    site_id integer NOT NULL,
    source_pallet_id integer,
    destination_pallet_id integer,
    source_location_id integer,
    destination_location_id integer,
    sku_id integer,
    unit_quantity numeric,
    unit_uom_id integer,
    lot_code text,
    expiry_date text,
    inventory_status_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.pick_up_picks OWNER TO nulogy;

--
-- Name: pick_up_picks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE pick_up_picks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pick_up_picks_id_seq OWNER TO nulogy;

--
-- Name: pick_up_picks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE pick_up_picks_id_seq OWNED BY pick_up_picks.id;


--
-- Name: picked_inventory; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE picked_inventory (
    id integer NOT NULL,
    sku_id integer,
    location_id integer,
    lot_code text,
    expiry_date text,
    expected_base_quantity numeric(16,5) DEFAULT 0.0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    exact_quantity_pick boolean DEFAULT false,
    priority integer,
    actual_base_quantity numeric(16,5) DEFAULT 0.0,
    site_id integer,
    pick_constraint_id integer
);


ALTER TABLE public.picked_inventory OWNER TO nulogy;

--
-- Name: planned_receipt_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE planned_receipt_items (
    id integer NOT NULL,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    expiry_date text,
    lot_code text,
    notes text,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    pallet_id integer,
    planned_receipt_id integer,
    receive_order_item_id integer,
    site_id integer NOT NULL,
    sku_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    external_identifier text,
    unit_uom_id integer
);


ALTER TABLE public.planned_receipt_items OWNER TO nulogy;

--
-- Name: planned_receipt_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE planned_receipt_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.planned_receipt_items_id_seq OWNER TO nulogy;

--
-- Name: planned_receipt_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE planned_receipt_items_id_seq OWNED BY planned_receipt_items.id;


--
-- Name: planned_receipts; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE planned_receipts (
    id integer NOT NULL,
    bill_of_lading text,
    expected_receive_at timestamp without time zone,
    internal_notes text,
    reference_1 text,
    reference_2 text,
    trailer_number text,
    carrier_id integer,
    customer_id integer,
    site_id integer,
    vendor_id integer,
    receive_to_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    external_identifier text
);


ALTER TABLE public.planned_receipts OWNER TO nulogy;

--
-- Name: planned_receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE planned_receipts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.planned_receipts_id_seq OWNER TO nulogy;

--
-- Name: planned_receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE planned_receipts_id_seq OWNED BY planned_receipts.id;


--
-- Name: planned_shipment_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE planned_shipment_items (
    id integer NOT NULL,
    site_id integer,
    planned_shipment_id integer,
    sku_id integer,
    base_quantity numeric(16,5) DEFAULT 0.0,
    ship_order_item_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.planned_shipment_items OWNER TO nulogy;

--
-- Name: planned_shipments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE planned_shipments (
    id integer NOT NULL,
    site_id integer,
    customer_id integer,
    consignee_id integer,
    expected_ship_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ship_order_id integer,
    pick_plan_id integer,
    carrier_code text,
    carrier_name text,
    bill_to text,
    staging_location_id integer
);


ALTER TABLE public.planned_shipments OWNER TO nulogy;

--
-- Name: production_archives; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE production_archives (
    id integer NOT NULL,
    archived_record_id integer NOT NULL,
    archived_record_created_at timestamp without time zone,
    archived_record_updated_at timestamp without time zone,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    pallet_id integer NOT NULL,
    lot_code text,
    produced_at timestamp without time zone,
    inventory_adjustment_id integer,
    cost_per_unit numeric(16,5) DEFAULT 0.0 NOT NULL,
    reference text,
    expiry_date text,
    job_id integer NOT NULL,
    site_id integer NOT NULL,
    printed_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    base_quantity numeric(16,5) DEFAULT 0.0
);


ALTER TABLE public.production_archives OWNER TO nulogy;

--
-- Name: production_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE production_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.production_archives_id_seq OWNER TO nulogy;

--
-- Name: production_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE production_archives_id_seq OWNED BY production_archives.id;


--
-- Name: productions; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE productions (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    pallet_id integer NOT NULL,
    lot_code text,
    produced_at timestamp without time zone,
    inventory_adjustment_id integer,
    cost_per_unit numeric(16,5) DEFAULT 0.0 NOT NULL,
    reference text,
    expiry_date text,
    job_id integer NOT NULL,
    site_id integer NOT NULL,
    printed_at timestamp without time zone,
    base_quantity numeric(16,5) DEFAULT 0.0
);


ALTER TABLE public.productions OWNER TO nulogy;

--
-- Name: productions_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE productions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.productions_id_seq OWNER TO nulogy;

--
-- Name: productions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE productions_id_seq OWNED BY productions.id;


--
-- Name: project_attachments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE project_attachments (
    id integer NOT NULL,
    size integer,
    content_type text,
    document text,
    project_id integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL,
    uuid text
);


ALTER TABLE public.project_attachments OWNER TO nulogy;

--
-- Name: project_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE project_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_attachments_id_seq OWNER TO nulogy;

--
-- Name: project_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE project_attachments_id_seq OWNED BY project_attachments.id;


--
-- Name: project_charge_settings; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE project_charge_settings (
    id integer NOT NULL,
    account_id integer,
    name text,
    default_charge numeric(16,5) DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT false
);


ALTER TABLE public.project_charge_settings OWNER TO nulogy;

--
-- Name: project_charge_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE project_charge_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_charge_settings_id_seq OWNER TO nulogy;

--
-- Name: project_charge_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE project_charge_settings_id_seq OWNED BY project_charge_settings.id;


--
-- Name: project_charges; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE project_charges (
    id integer NOT NULL,
    name text,
    charge numeric(16,5) DEFAULT 0,
    scenario_charge_id integer,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.project_charges OWNER TO nulogy;

--
-- Name: project_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE project_charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_charges_id_seq OWNER TO nulogy;

--
-- Name: project_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE project_charges_id_seq OWNED BY project_charges.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    code text,
    description text,
    sku_id integer,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    scenario_id integer,
    customer_id integer,
    long_running boolean DEFAULT false,
    units_expected numeric(16,5) DEFAULT 0.0,
    reference_1 text,
    reference_2 text,
    last_job_completed_at timestamp without time zone,
    due_date_at timestamp without time zone,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    base_quantity_produced numeric(16,5) DEFAULT 0.0,
    lock_version integer DEFAULT 0,
    status integer DEFAULT 0 NOT NULL,
    lot_code text,
    expiry_date text,
    use_lot_code boolean DEFAULT false,
    use_expiry_date boolean DEFAULT false,
    reference_3 text,
    custom_project_field_value_id integer,
    external_identifier text
);


ALTER TABLE public.projects OWNER TO nulogy;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projects_id_seq OWNER TO nulogy;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: qb_logs; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE qb_logs (
    id integer NOT NULL,
    xml text,
    transaction_type text,
    qb_class text,
    object_id integer,
    user_id integer,
    message text,
    qb_error text,
    stack_trace text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    progress text,
    state text,
    account_id integer NOT NULL
);


ALTER TABLE public.qb_logs OWNER TO nulogy;

--
-- Name: qb_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE qb_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qb_logs_id_seq OWNER TO nulogy;

--
-- Name: qb_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE qb_logs_id_seq OWNED BY qb_logs.id;


--
-- Name: qc_sheet_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE qc_sheet_items (
    id integer NOT NULL,
    qc_sheet_id integer,
    name text,
    description text,
    result text,
    notes text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL
);


ALTER TABLE public.qc_sheet_items OWNER TO nulogy;

--
-- Name: qc_sheet_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE qc_sheet_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qc_sheet_items_id_seq OWNER TO nulogy;

--
-- Name: qc_sheet_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE qc_sheet_items_id_seq OWNED BY qc_sheet_items.id;


--
-- Name: qc_sheets; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE qc_sheets (
    id integer NOT NULL,
    qc_template_id integer,
    job_id integer,
    name text,
    sign_off_role text,
    sign_off_user_id integer,
    notes text,
    performed_at timestamp without time zone,
    last_modified_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    shipment_id integer,
    receipt_id integer,
    project_id integer,
    site_id integer NOT NULL
);


ALTER TABLE public.qc_sheets OWNER TO nulogy;

--
-- Name: qc_sheets_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE qc_sheets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qc_sheets_id_seq OWNER TO nulogy;

--
-- Name: qc_sheets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE qc_sheets_id_seq OWNED BY qc_sheets.id;


--
-- Name: qc_template_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE qc_template_items (
    id integer NOT NULL,
    name text,
    description text,
    qc_template_id integer,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer NOT NULL
);


ALTER TABLE public.qc_template_items OWNER TO nulogy;

--
-- Name: qc_template_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE qc_template_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qc_template_items_id_seq OWNER TO nulogy;

--
-- Name: qc_template_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE qc_template_items_id_seq OWNED BY qc_template_items.id;


--
-- Name: qc_templates; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE qc_templates (
    id integer NOT NULL,
    sku_id integer,
    name text,
    sign_off_role text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer,
    report_url text,
    visible_by integer DEFAULT 1
);


ALTER TABLE public.qc_templates OWNER TO nulogy;

--
-- Name: qc_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE qc_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qc_templates_id_seq OWNER TO nulogy;

--
-- Name: qc_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE qc_templates_id_seq OWNED BY qc_templates.id;


--
-- Name: quote_attachments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE quote_attachments (
    id integer NOT NULL,
    size integer,
    content_type text,
    document text,
    quote_id integer,
    description text,
    account_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uuid text
);


ALTER TABLE public.quote_attachments OWNER TO nulogy;

--
-- Name: quote_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE quote_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quote_attachments_id_seq OWNER TO nulogy;

--
-- Name: quote_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE quote_attachments_id_seq OWNED BY quote_attachments.id;


--
-- Name: quote_reference_documents; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE quote_reference_documents (
    id integer NOT NULL,
    master_reference_document_id integer,
    quote_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer NOT NULL
);


ALTER TABLE public.quote_reference_documents OWNER TO nulogy;

--
-- Name: quote_reference_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE quote_reference_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quote_reference_documents_id_seq OWNER TO nulogy;

--
-- Name: quote_reference_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE quote_reference_documents_id_seq OWNED BY quote_reference_documents.id;


--
-- Name: quoted_bom_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE quoted_bom_items (
    id integer NOT NULL,
    item_code text,
    quantity numeric(16,5) DEFAULT 0,
    cost_per_unit numeric(16,5) DEFAULT 0,
    markup_per_unit numeric(16,5) DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    scenario_id integer,
    account_id integer,
    description text,
    "position" integer,
    reject_rate numeric(16,5) DEFAULT 0,
    external_identifier text,
    unit_of_measure_id integer
);


ALTER TABLE public.quoted_bom_items OWNER TO nulogy;

--
-- Name: quoted_bom_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE quoted_bom_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quoted_bom_items_id_seq OWNER TO nulogy;

--
-- Name: quoted_bom_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE quoted_bom_items_id_seq OWNED BY quoted_bom_items.id;


--
-- Name: quotes; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE quotes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name text,
    customer_id integer,
    reference text,
    requestor text,
    estimator text,
    requested_on date,
    estimated_on date,
    expires_on date,
    launch_on date,
    revision integer DEFAULT 0,
    account_id integer,
    custom_estimate_field_1 text,
    custom_estimate_field_2 text,
    custom_estimate_field_3 text,
    custom_estimate_field_4 text,
    custom_estimate_field_5 text,
    external_identifier text,
    status text
);


ALTER TABLE public.quotes OWNER TO nulogy;

--
-- Name: quotes_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE quotes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quotes_id_seq OWNER TO nulogy;

--
-- Name: quotes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE quotes_id_seq OWNED BY quotes.id;


--
-- Name: rack_locations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE rack_locations (
    id integer NOT NULL,
    label1 text,
    break1 text,
    label2 text,
    break2 text,
    label3 text,
    break3 text,
    label4 text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    location_id integer
);


ALTER TABLE public.rack_locations OWNER TO nulogy;

--
-- Name: rack_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE rack_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rack_locations_id_seq OWNER TO nulogy;

--
-- Name: rack_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE rack_locations_id_seq OWNED BY rack_locations.id;


--
-- Name: receipt_attachments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE receipt_attachments (
    id integer NOT NULL,
    size integer,
    content_type text,
    document text,
    receipt_id integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    uuid text
);


ALTER TABLE public.receipt_attachments OWNER TO nulogy;

--
-- Name: receipt_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE receipt_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.receipt_attachments_id_seq OWNER TO nulogy;

--
-- Name: receipt_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE receipt_attachments_id_seq OWNED BY receipt_attachments.id;


--
-- Name: receipt_item_logs; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE receipt_item_logs (
    id integer NOT NULL,
    receipt_item_id integer,
    field_name text,
    changed_from text,
    changed_to text,
    username text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL
);


ALTER TABLE public.receipt_item_logs OWNER TO nulogy;

--
-- Name: receipt_item_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE receipt_item_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.receipt_item_logs_id_seq OWNER TO nulogy;

--
-- Name: receipt_item_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE receipt_item_logs_id_seq OWNED BY receipt_item_logs.id;


--
-- Name: receipt_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE receipt_items (
    id integer NOT NULL,
    receipt_id integer,
    inventory_adjustment_id integer,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    sku_id integer,
    lot_code text,
    expiry_date text,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    purchase_price_per_unit numeric(16,5) DEFAULT 0,
    site_id integer NOT NULL,
    unit_quantity_per_skid numeric(16,5) DEFAULT 0,
    number_of_skids integer DEFAULT 1,
    pallet_id integer,
    receive_to_id integer,
    receive_order_item_id integer,
    reference text,
    external_identifier text,
    unit_uom_id integer,
    inventory_status_id integer
);


ALTER TABLE public.receipt_items OWNER TO nulogy;

--
-- Name: receipt_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE receipt_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.receipt_items_id_seq OWNER TO nulogy;

--
-- Name: receipt_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE receipt_items_id_seq OWNED BY receipt_items.id;


--
-- Name: receipts; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE receipts (
    id integer NOT NULL,
    vendor_id integer,
    site_id integer,
    received_at timestamp without time zone,
    bill_of_lading text,
    packing_slip text,
    internal_notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reference_1 text,
    received_by text,
    reference_2 text,
    trailer_number text,
    synchronized_status text,
    qb_txn_id text,
    qb_last_sync_at timestamp without time zone,
    receive_to_id integer,
    customer_id integer,
    carrier_id integer,
    status integer,
    mobile_receive_order_id integer,
    expected_at timestamp without time zone,
    planned_receipt_id integer,
    external_identifier text
);


ALTER TABLE public.receipts OWNER TO nulogy;

--
-- Name: receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE receipts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.receipts_id_seq OWNER TO nulogy;

--
-- Name: receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE receipts_id_seq OWNED BY receipts.id;


--
-- Name: receive_order_archives; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE receive_order_archives (
    id integer NOT NULL,
    vendor_id integer,
    reference text,
    expected_delivery_at timestamp without time zone,
    vendor_notes text,
    internal_notes text,
    archived_record_id integer NOT NULL,
    archived_record_created_at timestamp without time zone,
    archived_record_updated_at timestamp without time zone,
    site_id integer,
    ro_date_at timestamp without time zone,
    received boolean DEFAULT false,
    customer_id integer,
    project_id integer,
    synchronized_status text,
    qb_txn_id text,
    qb_last_sync_at timestamp without time zone,
    netsuite_id text,
    netsuite_last_sync_at timestamp without time zone,
    carrier_id integer,
    quickbooks_reference_number text,
    sent_edi_940 boolean DEFAULT false,
    external_identifier text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    purchaser text,
    status text,
    code text
);


ALTER TABLE public.receive_order_archives OWNER TO nulogy;

--
-- Name: receive_order_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE receive_order_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.receive_order_archives_id_seq OWNER TO nulogy;

--
-- Name: receive_order_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE receive_order_archives_id_seq OWNED BY receive_order_archives.id;


--
-- Name: receive_order_attachments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE receive_order_attachments (
    id integer NOT NULL,
    size integer,
    content_type text,
    document text,
    receive_order_id integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL,
    uuid text
);


ALTER TABLE public.receive_order_attachments OWNER TO nulogy;

--
-- Name: receive_order_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE receive_order_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.receive_order_attachments_id_seq OWNER TO nulogy;

--
-- Name: receive_order_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE receive_order_attachments_id_seq OWNED BY receive_order_attachments.id;


--
-- Name: receive_order_item_archives; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE receive_order_item_archives (
    id integer NOT NULL,
    archived_record_id integer NOT NULL,
    archived_record_created_at timestamp without time zone,
    archived_record_updated_at timestamp without time zone,
    sku_id integer,
    receive_order_id integer,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    purchase_price_per_unit numeric(16,5) DEFAULT 0.0,
    qb_txn_id text,
    qb_last_sync_at timestamp without time zone,
    "position" integer,
    site_id integer NOT NULL,
    old_each_quantity numeric,
    reference_1 text,
    external_identifier text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unit_uom_id integer
);


ALTER TABLE public.receive_order_item_archives OWNER TO nulogy;

--
-- Name: receive_order_item_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE receive_order_item_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.receive_order_item_archives_id_seq OWNER TO nulogy;

--
-- Name: receive_order_item_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE receive_order_item_archives_id_seq OWNED BY receive_order_item_archives.id;


--
-- Name: receive_order_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE receive_order_items (
    id integer NOT NULL,
    sku_id integer,
    receive_order_id integer,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    purchase_price_per_unit numeric(16,5) DEFAULT 0.0,
    qb_txn_id text,
    qb_last_sync_at timestamp without time zone,
    "position" integer,
    site_id integer NOT NULL,
    old_each_quantity numeric,
    reference_1 text,
    external_identifier text,
    unit_uom_id integer
);


ALTER TABLE public.receive_order_items OWNER TO nulogy;

--
-- Name: receive_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE receive_order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.receive_order_items_id_seq OWNER TO nulogy;

--
-- Name: receive_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE receive_order_items_id_seq OWNED BY receive_order_items.id;


--
-- Name: receive_orders; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE receive_orders (
    id integer NOT NULL,
    vendor_id integer,
    reference text,
    expected_delivery_at timestamp without time zone,
    vendor_notes text,
    internal_notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    ro_date_at timestamp without time zone,
    received boolean DEFAULT false,
    customer_id integer,
    project_id integer,
    synchronized_status text,
    qb_txn_id text,
    qb_last_sync_at timestamp without time zone,
    netsuite_id text,
    netsuite_last_sync_at timestamp without time zone,
    carrier_id integer,
    quickbooks_reference_number text,
    sent_edi_940 boolean DEFAULT false,
    external_identifier text,
    purchaser text DEFAULT 'unspecified'::text,
    status text DEFAULT 'unspecified'::text,
    code text
);


ALTER TABLE public.receive_orders OWNER TO nulogy;

--
-- Name: receive_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE receive_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.receive_orders_id_seq OWNER TO nulogy;

--
-- Name: receive_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE receive_orders_id_seq OWNED BY receive_orders.id;


--
-- Name: reconciliation_reasons; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE reconciliation_reasons (
    id integer NOT NULL,
    code text,
    reason text,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer
);


ALTER TABLE public.reconciliation_reasons OWNER TO nulogy;

--
-- Name: reconciliation_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE reconciliation_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reconciliation_reasons_id_seq OWNER TO nulogy;

--
-- Name: reconciliation_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE reconciliation_reasons_id_seq OWNED BY reconciliation_reasons.id;


--
-- Name: reject_reasons; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE reject_reasons (
    id integer NOT NULL,
    code text,
    reason text,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.reject_reasons OWNER TO nulogy;

--
-- Name: reject_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE reject_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reject_reasons_id_seq OWNER TO nulogy;

--
-- Name: reject_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE reject_reasons_id_seq OWNED BY reject_reasons.id;


--
-- Name: rejected_item_archives; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE rejected_item_archives (
    id integer NOT NULL,
    archived_record_id integer,
    archived_record_created_at timestamp without time zone,
    archived_record_updated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    sku_id integer,
    lot_code text,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    job_id integer,
    cost_per_unit numeric(16,5) DEFAULT 0.0 NOT NULL,
    expiry_date text,
    add_adjustment_id integer,
    remove_adjustment_id integer,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    reject_reason_id integer,
    site_id integer NOT NULL,
    pallet_id integer,
    track_by_job boolean DEFAULT false,
    unit_uom_id integer
);


ALTER TABLE public.rejected_item_archives OWNER TO nulogy;

--
-- Name: rejected_item_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE rejected_item_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rejected_item_archives_id_seq OWNER TO nulogy;

--
-- Name: rejected_item_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE rejected_item_archives_id_seq OWNED BY rejected_item_archives.id;


--
-- Name: rejected_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE rejected_items (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    sku_id integer,
    lot_code text,
    unit_quantity numeric(16,5) DEFAULT 0,
    job_id integer,
    cost_per_unit numeric(16,5) DEFAULT 0.0 NOT NULL,
    expiry_date text,
    add_adjustment_id integer,
    remove_adjustment_id integer,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    reject_reason_id integer,
    site_id integer NOT NULL,
    pallet_id integer,
    track_by_job boolean DEFAULT false,
    unit_uom_id integer
);


ALTER TABLE public.rejected_items OWNER TO nulogy;

--
-- Name: rejected_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE rejected_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rejected_items_id_seq OWNER TO nulogy;

--
-- Name: rejected_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE rejected_items_id_seq OWNED BY rejected_items.id;


--
-- Name: required_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE required_items (
    id integer NOT NULL,
    sku_id integer,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    item_cart_id integer,
    site_id integer NOT NULL,
    unit_uom_id integer
);


ALTER TABLE public.required_items OWNER TO nulogy;

--
-- Name: required_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE required_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.required_items_id_seq OWNER TO nulogy;

--
-- Name: required_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE required_items_id_seq OWNED BY required_items.id;


--
-- Name: reserved_inventory_levels; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE reserved_inventory_levels (
    id integer NOT NULL,
    reservable_id integer,
    reservable_type text,
    sku_id integer,
    lot_code text,
    expiry_date text,
    base_quantity numeric(16,5) DEFAULT 0.0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer
);


ALTER TABLE public.reserved_inventory_levels OWNER TO nulogy;

--
-- Name: scenario_attachments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE scenario_attachments (
    id integer NOT NULL,
    size integer,
    content_type text,
    filename text,
    description text,
    custom_output_id integer,
    account_id integer,
    scenario_id integer,
    document text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uuid text
);


ALTER TABLE public.scenario_attachments OWNER TO nulogy;

--
-- Name: scenario_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE scenario_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scenario_attachments_id_seq OWNER TO nulogy;

--
-- Name: scenario_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE scenario_attachments_id_seq OWNED BY scenario_attachments.id;


--
-- Name: scenario_charges; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE scenario_charges (
    id integer NOT NULL,
    effective_date_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    labour_charge_per_unit numeric(16,5) DEFAULT 0,
    materials_charge_per_unit numeric(16,5) DEFAULT 0,
    overhead_charge_per_unit numeric(16,5) DEFAULT 0,
    overridden_charge_per_unit numeric(16,5) DEFAULT 0.0,
    scenario_id integer,
    labour_cost_per_unit numeric(16,5) DEFAULT 0.0,
    labour_markup_per_unit numeric(16,5) DEFAULT 0.0,
    materials_cost_per_unit numeric(16,5) DEFAULT 0.0,
    materials_markup_per_unit numeric(16,5) DEFAULT 0.0,
    overhead_cost_per_unit numeric(16,5) DEFAULT 0.0,
    overhead_markup_per_unit numeric(16,5) DEFAULT 0.0,
    override_charge boolean DEFAULT false,
    labour_markup_percentage numeric(16,5) DEFAULT 0,
    materials_markup_percentage numeric(16,5) DEFAULT 0,
    overhead_markup_percentage numeric(16,5) DEFAULT 0,
    account_id integer NOT NULL,
    external_identifier text
);


ALTER TABLE public.scenario_charges OWNER TO nulogy;

--
-- Name: scenario_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE scenario_charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scenario_charges_id_seq OWNER TO nulogy;

--
-- Name: scenario_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE scenario_charges_id_seq OWNED BY scenario_charges.id;


--
-- Name: scenario_loss_reasons; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE scenario_loss_reasons (
    id integer NOT NULL,
    reason text,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.scenario_loss_reasons OWNER TO nulogy;

--
-- Name: scenario_loss_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE scenario_loss_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scenario_loss_reasons_id_seq OWNER TO nulogy;

--
-- Name: scenario_loss_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE scenario_loss_reasons_id_seq OWNED BY scenario_loss_reasons.id;


--
-- Name: scenario_to_scenario_attachments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE scenario_to_scenario_attachments (
    id integer NOT NULL,
    scenario_id integer,
    scenario_attachment_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer NOT NULL
);


ALTER TABLE public.scenario_to_scenario_attachments OWNER TO nulogy;

--
-- Name: scenario_to_scenario_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE scenario_to_scenario_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scenario_to_scenario_attachments_id_seq OWNER TO nulogy;

--
-- Name: scenario_to_scenario_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE scenario_to_scenario_attachments_id_seq OWNED BY scenario_to_scenario_attachments.id;


--
-- Name: scenarios; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE scenarios (
    id integer NOT NULL,
    quote_id integer,
    name text,
    description text,
    volume numeric(16,5) DEFAULT 0,
    production_time numeric(16,5) DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    item text,
    account_id integer,
    wage numeric(16,5) DEFAULT 0.0,
    status character varying(255) DEFAULT NULL::character varying,
    item_description text,
    item_type_id integer,
    item_category_id integer,
    scenario_loss_reason_id integer,
    eaches_per_case numeric(16,5) DEFAULT 1.0,
    cases_per_pallet numeric(16,5) DEFAULT 1.0,
    item_family_id integer,
    custom_scenario_field_1 text,
    custom_scenario_field_2 text,
    custom_scenario_field_3 text,
    custom_scenario_field_4 text,
    custom_scenario_field_5 text,
    custom_scenario_field_6 text,
    custom_scenario_field_7 text,
    custom_scenario_field_8 text,
    custom_scenario_field_9 text,
    custom_scenario_field_10 text,
    custom_scenario_field_11 text,
    custom_scenario_field_12 text,
    custom_scenario_field_13 text,
    custom_scenario_field_14 text,
    custom_scenario_field_15 text,
    external_identifier text,
    unit_of_measure_id integer NOT NULL,
    chargeable_units_per_pallet numeric(16,5) DEFAULT 1
);


ALTER TABLE public.scenarios OWNER TO nulogy;

--
-- Name: scenarios_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE scenarios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scenarios_id_seq OWNER TO nulogy;

--
-- Name: scenarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE scenarios_id_seq OWNED BY scenarios.id;


--
-- Name: scheduled_tasks; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE scheduled_tasks (
    id integer NOT NULL,
    name text,
    user_id integer,
    account_id integer,
    schedule text,
    action_class_name text,
    action_args text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    company_id integer,
    site_id integer,
    task_type text
);


ALTER TABLE public.scheduled_tasks OWNER TO nulogy;

--
-- Name: scheduled_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE scheduled_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scheduled_tasks_id_seq OWNER TO nulogy;

--
-- Name: scheduled_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE scheduled_tasks_id_seq OWNED BY scheduled_tasks.id;


--
-- Name: scheduling_blocks; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE scheduling_blocks (
    id integer NOT NULL,
    site_id integer,
    scheduling_line_id integer,
    scheduling_project_demand_id integer,
    scheduling_shift_id integer,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.scheduling_blocks OWNER TO nulogy;

--
-- Name: scheduling_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE scheduling_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scheduling_blocks_id_seq OWNER TO nulogy;

--
-- Name: scheduling_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE scheduling_blocks_id_seq OWNED BY scheduling_blocks.id;


--
-- Name: scheduling_default_shift_capacities; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE scheduling_default_shift_capacities (
    id integer NOT NULL,
    site_id integer,
    scheduling_shift_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    number_of_active_lines_for_sunday integer,
    number_of_active_lines_for_monday integer,
    number_of_active_lines_for_tuesday integer,
    number_of_active_lines_for_wednesday integer,
    number_of_active_lines_for_thursday integer,
    number_of_active_lines_for_friday integer,
    number_of_active_lines_for_saturday integer
);


ALTER TABLE public.scheduling_default_shift_capacities OWNER TO nulogy;

--
-- Name: scheduling_default_shift_capacities_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE scheduling_default_shift_capacities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scheduling_default_shift_capacities_id_seq OWNER TO nulogy;

--
-- Name: scheduling_default_shift_capacities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE scheduling_default_shift_capacities_id_seq OWNED BY scheduling_default_shift_capacities.id;


--
-- Name: scheduling_line_assignments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE scheduling_line_assignments (
    id integer NOT NULL,
    site_id integer,
    scheduling_line_id integer,
    scheduling_project_demand_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.scheduling_line_assignments OWNER TO nulogy;

--
-- Name: scheduling_line_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE scheduling_line_assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scheduling_line_assignments_id_seq OWNER TO nulogy;

--
-- Name: scheduling_line_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE scheduling_line_assignments_id_seq OWNED BY scheduling_line_assignments.id;


--
-- Name: scheduling_lines; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE scheduling_lines (
    id integer NOT NULL,
    site_id integer,
    name text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    external_id text,
    description text
);


ALTER TABLE public.scheduling_lines OWNER TO nulogy;

--
-- Name: scheduling_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE scheduling_lines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scheduling_lines_id_seq OWNER TO nulogy;

--
-- Name: scheduling_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE scheduling_lines_id_seq OWNED BY scheduling_lines.id;


--
-- Name: scheduling_project_demands; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE scheduling_project_demands (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    external_id text,
    site_id integer,
    unit_quantity_remaining numeric(16,5),
    units_per_hour numeric(16,5),
    performance numeric(16,5),
    project_code text,
    item_external_id text,
    item_code text,
    due_date_at timestamp without time zone,
    priority integer,
    minutes_remaining integer,
    item_description text
);


ALTER TABLE public.scheduling_project_demands OWNER TO nulogy;

--
-- Name: scheduling_project_demands_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE scheduling_project_demands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scheduling_project_demands_id_seq OWNER TO nulogy;

--
-- Name: scheduling_project_demands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE scheduling_project_demands_id_seq OWNED BY scheduling_project_demands.id;


--
-- Name: scheduling_shifts; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE scheduling_shifts (
    id integer NOT NULL,
    site_id integer,
    external_id text,
    name text,
    start_at time without time zone,
    end_at time without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.scheduling_shifts OWNER TO nulogy;

--
-- Name: scheduling_shifts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE scheduling_shifts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scheduling_shifts_id_seq OWNER TO nulogy;

--
-- Name: scheduling_shifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE scheduling_shifts_id_seq OWNED BY scheduling_shifts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE schema_migrations (
    version text NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO nulogy;

--
-- Name: selected_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE selected_items (
    id integer NOT NULL,
    location_id integer,
    pallet_id integer,
    sku_id integer,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    lot_code text,
    expiry_date text,
    item_cart_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL,
    base_quantity numeric(16,5) DEFAULT 0.0,
    inventory_status_id integer
);


ALTER TABLE public.selected_items OWNER TO nulogy;

--
-- Name: selected_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE selected_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.selected_items_id_seq OWNER TO nulogy;

--
-- Name: selected_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE selected_items_id_seq OWNED BY selected_items.id;


--
-- Name: selected_pallets; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE selected_pallets (
    id integer NOT NULL,
    pallet_id integer,
    item_cart_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL
);


ALTER TABLE public.selected_pallets OWNER TO nulogy;

--
-- Name: selected_pallets_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE selected_pallets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.selected_pallets_id_seq OWNER TO nulogy;

--
-- Name: selected_pallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE selected_pallets_id_seq OWNED BY selected_pallets.id;


--
-- Name: sequence_generators; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE sequence_generators (
    id integer NOT NULL,
    account_id integer,
    site_id integer,
    seq_type text,
    source_id integer,
    current_value integer,
    lock_version integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    additional_info extensions.hstore
);


ALTER TABLE public.sequence_generators OWNER TO nulogy;

--
-- Name: sequence_generators_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE sequence_generators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sequence_generators_id_seq OWNER TO nulogy;

--
-- Name: sequence_generators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE sequence_generators_id_seq OWNED BY sequence_generators.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id text,
    data text,
    updated_at timestamp without time zone
);


ALTER TABLE public.sessions OWNER TO nulogy;

--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sessions_id_seq OWNER TO nulogy;

--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: shifts; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE shifts (
    id integer NOT NULL,
    name text,
    start_at time without time zone,
    end_at time without time zone,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.shifts OWNER TO nulogy;

--
-- Name: shifts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE shifts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shifts_id_seq OWNER TO nulogy;

--
-- Name: shifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE shifts_id_seq OWNED BY shifts.id;


--
-- Name: ship_order_attachments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE ship_order_attachments (
    id integer NOT NULL,
    size integer,
    content_type text,
    document text,
    ship_order_id integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL,
    uuid text
);


ALTER TABLE public.ship_order_attachments OWNER TO nulogy;

--
-- Name: ship_order_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE ship_order_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ship_order_attachments_id_seq OWNER TO nulogy;

--
-- Name: ship_order_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE ship_order_attachments_id_seq OWNED BY ship_order_attachments.id;


--
-- Name: ship_order_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE ship_order_items (
    id integer NOT NULL,
    ship_order_id integer,
    sku_id integer,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    purchase_order_number text,
    project_id integer,
    price_per_unit numeric(16,5) DEFAULT 0,
    qb_txn_id text,
    qb_last_sync_at timestamp without time zone,
    site_id integer NOT NULL,
    customer_reference text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    external_identifier text,
    unit_uom_id integer,
    consignee_sku text
);


ALTER TABLE public.ship_order_items OWNER TO nulogy;

--
-- Name: ship_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE ship_order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ship_order_items_id_seq OWNER TO nulogy;

--
-- Name: ship_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE ship_order_items_id_seq OWNED BY ship_order_items.id;


--
-- Name: ship_orders; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE ship_orders (
    id integer NOT NULL,
    expected_ship_at timestamp without time zone,
    reference_number text,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    shipped boolean DEFAULT false,
    consignee_id integer,
    customer_id integer,
    synchronized_status text,
    qb_last_sync_at timestamp without time zone,
    qb_txn_id text,
    so_date_at timestamp without time zone,
    netsuite_id text,
    netsuite_last_sync_at timestamp without time zone,
    carrier_id integer,
    freight_charge_terms text,
    external_identifier text,
    custom_ship_order_field_1 text,
    custom_ship_order_field_2 text,
    custom_ship_order_field_3 text,
    custom_ship_order_field_4 text,
    custom_ship_order_field_5 text,
    custom_ship_order_field_6 text,
    custom_ship_order_field_7 text,
    code text
);


ALTER TABLE public.ship_orders OWNER TO nulogy;

--
-- Name: ship_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE ship_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ship_orders_id_seq OWNER TO nulogy;

--
-- Name: ship_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE ship_orders_id_seq OWNED BY ship_orders.id;


--
-- Name: shipment_attachments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE shipment_attachments (
    id integer NOT NULL,
    size integer,
    content_type text,
    document text,
    shipment_id integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL,
    uuid text
);


ALTER TABLE public.shipment_attachments OWNER TO nulogy;

--
-- Name: shipment_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE shipment_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shipment_attachments_id_seq OWNER TO nulogy;

--
-- Name: shipment_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE shipment_attachments_id_seq OWNED BY shipment_attachments.id;


--
-- Name: shipments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE shipments (
    id integer NOT NULL,
    ship_order_id integer,
    ship_to_old_address text,
    actual_ship_at timestamp without time zone,
    shipment_notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ship_to text,
    ship_to_id integer,
    site_id integer,
    shipped boolean DEFAULT false,
    bill_of_lading_number bigint,
    invoice_id integer,
    ship_to_phone text,
    synchronized_status text,
    qb_txn_id text,
    qb_last_sync_at timestamp without time zone,
    ship_to_attention text,
    ship_to_address_1 text,
    ship_to_address_2 text,
    ship_to_city text,
    ship_to_province text,
    ship_to_postal_code text,
    ship_to_country text,
    custom_1 text,
    custom_2 text,
    estimated_delivery_at timestamp without time zone,
    quickbooks_reference_number text,
    actual_delivery_at timestamp without time zone,
    quickbooks_po_number text,
    external_identifier text,
    planned_shipment_id integer,
    ship_to_code text,
    outbound_trailer_id integer NOT NULL,
    ship_to_facility_number text
);


ALTER TABLE public.shipments OWNER TO nulogy;

--
-- Name: shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE shipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shipments_id_seq OWNER TO nulogy;

--
-- Name: shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE shipments_id_seq OWNED BY shipments.id;


--
-- Name: site_100_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_100_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_100_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_101_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_101_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_101_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_102_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_102_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_102_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_103_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_103_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_103_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_104_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_104_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_104_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_105_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_105_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_105_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_106_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_106_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_106_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_107_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_107_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_107_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_108_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_108_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_108_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_109_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_109_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_109_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_10_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_10_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_10_bol_number_seq OWNER TO nulogy;

--
-- Name: site_10_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_10_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_10_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_110_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_110_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_110_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_111_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_111_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_111_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_112_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_112_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_112_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_113_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_113_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_113_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_114_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_114_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_114_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_115_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_115_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_115_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_116_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_116_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_116_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_117_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_117_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_117_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_118_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_118_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_118_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_119_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_119_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_119_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_11_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_11_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_11_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_120_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_120_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_120_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_121_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_121_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_121_bol_number_seq OWNER TO nulogy;

--
-- Name: site_121_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_121_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_121_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_122_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_122_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_122_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_123_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_123_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_123_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_124_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_124_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_124_bol_number_seq OWNER TO nulogy;

--
-- Name: site_124_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_124_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_124_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_125_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_125_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_125_bol_number_seq OWNER TO nulogy;

--
-- Name: site_125_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_125_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_125_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_126_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_126_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_126_bol_number_seq OWNER TO nulogy;

--
-- Name: site_126_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_126_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_126_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_127_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_127_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_127_bol_number_seq OWNER TO nulogy;

--
-- Name: site_127_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_127_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_127_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_128_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_128_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_128_bol_number_seq OWNER TO nulogy;

--
-- Name: site_128_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_128_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_128_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_129_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_129_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_129_bol_number_seq OWNER TO nulogy;

--
-- Name: site_129_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_129_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_129_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_12_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_12_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_12_bol_number_seq OWNER TO nulogy;

--
-- Name: site_12_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_12_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_12_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_130_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_130_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_130_bol_number_seq OWNER TO nulogy;

--
-- Name: site_130_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_130_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_130_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_131_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_131_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_131_bol_number_seq OWNER TO nulogy;

--
-- Name: site_131_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_131_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_131_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_132_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_132_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_132_bol_number_seq OWNER TO nulogy;

--
-- Name: site_132_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_132_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_132_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_133_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_133_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_133_bol_number_seq OWNER TO nulogy;

--
-- Name: site_133_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_133_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_133_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_134_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_134_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_134_bol_number_seq OWNER TO nulogy;

--
-- Name: site_134_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_134_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_134_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_135_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_135_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_135_bol_number_seq OWNER TO nulogy;

--
-- Name: site_135_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_135_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_135_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_136_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_136_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_136_bol_number_seq OWNER TO nulogy;

--
-- Name: site_136_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_136_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_136_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_137_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_137_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_137_bol_number_seq OWNER TO nulogy;

--
-- Name: site_137_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_137_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_137_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_138_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_138_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_138_bol_number_seq OWNER TO nulogy;

--
-- Name: site_138_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_138_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_138_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_139_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_139_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_139_bol_number_seq OWNER TO nulogy;

--
-- Name: site_139_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_139_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_139_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_13_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_13_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_13_bol_number_seq OWNER TO nulogy;

--
-- Name: site_13_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_13_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_13_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_140_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_140_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_140_bol_number_seq OWNER TO nulogy;

--
-- Name: site_140_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_140_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_140_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_141_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_141_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_141_bol_number_seq OWNER TO nulogy;

--
-- Name: site_141_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_141_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_141_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_142_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_142_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_142_bol_number_seq OWNER TO nulogy;

--
-- Name: site_142_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_142_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_142_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_143_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_143_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_143_bol_number_seq OWNER TO nulogy;

--
-- Name: site_143_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_143_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_143_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_144_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_144_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_144_bol_number_seq OWNER TO nulogy;

--
-- Name: site_144_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_144_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_144_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_145_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_145_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_145_bol_number_seq OWNER TO nulogy;

--
-- Name: site_145_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_145_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_145_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_146_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_146_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_146_bol_number_seq OWNER TO nulogy;

--
-- Name: site_146_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_146_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_146_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_147_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_147_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_147_bol_number_seq OWNER TO nulogy;

--
-- Name: site_147_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_147_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_147_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_148_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_148_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_148_bol_number_seq OWNER TO nulogy;

--
-- Name: site_148_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_148_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_148_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_149_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_149_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_149_bol_number_seq OWNER TO nulogy;

--
-- Name: site_149_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_149_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_149_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_14_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_14_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_14_bol_number_seq OWNER TO nulogy;

--
-- Name: site_14_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_14_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_14_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_150_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_150_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_150_bol_number_seq OWNER TO nulogy;

--
-- Name: site_150_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_150_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_150_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_151_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_151_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_151_bol_number_seq OWNER TO nulogy;

--
-- Name: site_151_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_151_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_151_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_152_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_152_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_152_bol_number_seq OWNER TO nulogy;

--
-- Name: site_152_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_152_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_152_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_153_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_153_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_153_bol_number_seq OWNER TO nulogy;

--
-- Name: site_153_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_153_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_153_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_154_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_154_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_154_bol_number_seq OWNER TO nulogy;

--
-- Name: site_154_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_154_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_154_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_155_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_155_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_155_bol_number_seq OWNER TO nulogy;

--
-- Name: site_155_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_155_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_155_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_156_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_156_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_156_bol_number_seq OWNER TO nulogy;

--
-- Name: site_156_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_156_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_156_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_157_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_157_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_157_bol_number_seq OWNER TO nulogy;

--
-- Name: site_157_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_157_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_157_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_158_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_158_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_158_bol_number_seq OWNER TO nulogy;

--
-- Name: site_158_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_158_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_158_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_159_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_159_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_159_bol_number_seq OWNER TO nulogy;

--
-- Name: site_159_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_159_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_159_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_15_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_15_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_15_bol_number_seq OWNER TO nulogy;

--
-- Name: site_15_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_15_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_15_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_160_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_160_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_160_bol_number_seq OWNER TO nulogy;

--
-- Name: site_160_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_160_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_160_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_161_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_161_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_161_bol_number_seq OWNER TO nulogy;

--
-- Name: site_161_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_161_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_161_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_162_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_162_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_162_bol_number_seq OWNER TO nulogy;

--
-- Name: site_162_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_162_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_162_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_163_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_163_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_163_bol_number_seq OWNER TO nulogy;

--
-- Name: site_163_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_163_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_163_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_164_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_164_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_164_bol_number_seq OWNER TO nulogy;

--
-- Name: site_164_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_164_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_164_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_165_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_165_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_165_bol_number_seq OWNER TO nulogy;

--
-- Name: site_165_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_165_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_165_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_166_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_166_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_166_bol_number_seq OWNER TO nulogy;

--
-- Name: site_166_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_166_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_166_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_167_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_167_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_167_bol_number_seq OWNER TO nulogy;

--
-- Name: site_167_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_167_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_167_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_168_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_168_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_168_bol_number_seq OWNER TO nulogy;

--
-- Name: site_168_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_168_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_168_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_169_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_169_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_169_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_16_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_16_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_16_bol_number_seq OWNER TO nulogy;

--
-- Name: site_16_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_16_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_16_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_170_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_170_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_170_bol_number_seq OWNER TO nulogy;

--
-- Name: site_170_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_170_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_170_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_171_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_171_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_171_bol_number_seq OWNER TO nulogy;

--
-- Name: site_171_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_171_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_171_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_172_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_172_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_172_bol_number_seq OWNER TO nulogy;

--
-- Name: site_172_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_172_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_172_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_173_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_173_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_173_bol_number_seq OWNER TO nulogy;

--
-- Name: site_173_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_173_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_173_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_174_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_174_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_174_bol_number_seq OWNER TO nulogy;

--
-- Name: site_174_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_174_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_174_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_175_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_175_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_175_bol_number_seq OWNER TO nulogy;

--
-- Name: site_175_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_175_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_175_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_176_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_176_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_176_bol_number_seq OWNER TO nulogy;

--
-- Name: site_176_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_176_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_176_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_177_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_177_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_177_bol_number_seq OWNER TO nulogy;

--
-- Name: site_177_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_177_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_177_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_17_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_17_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_17_bol_number_seq OWNER TO nulogy;

--
-- Name: site_17_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_17_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_17_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_18_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_18_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_18_bol_number_seq OWNER TO nulogy;

--
-- Name: site_18_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_18_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_18_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_19_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_19_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_19_bol_number_seq OWNER TO nulogy;

--
-- Name: site_19_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_19_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_19_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_1_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_1_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_1_bol_number_seq OWNER TO nulogy;

--
-- Name: site_1_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_1_pallet_number_seq
    START WITH 3083
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_1_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_20_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_20_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_20_bol_number_seq OWNER TO nulogy;

--
-- Name: site_20_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_20_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_20_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_210_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_210_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_210_bol_number_seq OWNER TO nulogy;

--
-- Name: site_210_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_210_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_210_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_21_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_21_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_21_bol_number_seq OWNER TO nulogy;

--
-- Name: site_21_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_21_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_21_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_22_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_22_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_22_bol_number_seq OWNER TO nulogy;

--
-- Name: site_22_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_22_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_22_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_23_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_23_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_23_bol_number_seq OWNER TO nulogy;

--
-- Name: site_23_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_23_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_23_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_243_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_243_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_243_bol_number_seq OWNER TO nulogy;

--
-- Name: site_243_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_243_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_243_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_244_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_244_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_244_bol_number_seq OWNER TO nulogy;

--
-- Name: site_244_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_244_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_244_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_245_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_245_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_245_bol_number_seq OWNER TO nulogy;

--
-- Name: site_245_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_245_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_245_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_246_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_246_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_246_bol_number_seq OWNER TO nulogy;

--
-- Name: site_246_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_246_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_246_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_247_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_247_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_247_bol_number_seq OWNER TO nulogy;

--
-- Name: site_247_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_247_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_247_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_248_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_248_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_248_bol_number_seq OWNER TO nulogy;

--
-- Name: site_248_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_248_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_248_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_249_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_249_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_249_bol_number_seq OWNER TO nulogy;

--
-- Name: site_249_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_249_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_249_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_24_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_24_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_24_bol_number_seq OWNER TO nulogy;

--
-- Name: site_24_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_24_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_24_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_250_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_250_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_250_bol_number_seq OWNER TO nulogy;

--
-- Name: site_250_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_250_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_250_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_251_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_251_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_251_bol_number_seq OWNER TO nulogy;

--
-- Name: site_251_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_251_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_251_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_252_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_252_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_252_bol_number_seq OWNER TO nulogy;

--
-- Name: site_252_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_252_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_252_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_253_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_253_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_253_bol_number_seq OWNER TO nulogy;

--
-- Name: site_253_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_253_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_253_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_254_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_254_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_254_bol_number_seq OWNER TO nulogy;

--
-- Name: site_254_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_254_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_254_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_255_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_255_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_255_bol_number_seq OWNER TO nulogy;

--
-- Name: site_255_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_255_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_255_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_256_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_256_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_256_bol_number_seq OWNER TO nulogy;

--
-- Name: site_256_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_256_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_256_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_257_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_257_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_257_bol_number_seq OWNER TO nulogy;

--
-- Name: site_257_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_257_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_257_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_258_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_258_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_258_bol_number_seq OWNER TO nulogy;

--
-- Name: site_258_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_258_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_258_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_259_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_259_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_259_bol_number_seq OWNER TO nulogy;

--
-- Name: site_259_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_259_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_259_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_25_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_25_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_25_bol_number_seq OWNER TO nulogy;

--
-- Name: site_25_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_25_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_25_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_260_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_260_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_260_bol_number_seq OWNER TO nulogy;

--
-- Name: site_260_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_260_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_260_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_261_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_261_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_261_bol_number_seq OWNER TO nulogy;

--
-- Name: site_261_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_261_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_261_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_262_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_262_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_262_bol_number_seq OWNER TO nulogy;

--
-- Name: site_262_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_262_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_262_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_263_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_263_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_263_bol_number_seq OWNER TO nulogy;

--
-- Name: site_263_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_263_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_263_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_264_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_264_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_264_bol_number_seq OWNER TO nulogy;

--
-- Name: site_264_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_264_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_264_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_265_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_265_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_265_bol_number_seq OWNER TO nulogy;

--
-- Name: site_265_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_265_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_265_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_266_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_266_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_266_bol_number_seq OWNER TO nulogy;

--
-- Name: site_266_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_266_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_266_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_267_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_267_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_267_bol_number_seq OWNER TO nulogy;

--
-- Name: site_267_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_267_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_267_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_268_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_268_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_268_bol_number_seq OWNER TO nulogy;

--
-- Name: site_268_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_268_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_268_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_269_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_269_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_269_bol_number_seq OWNER TO nulogy;

--
-- Name: site_269_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_269_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_269_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_26_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_26_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_26_bol_number_seq OWNER TO nulogy;

--
-- Name: site_26_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_26_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_26_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_270_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_270_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_270_bol_number_seq OWNER TO nulogy;

--
-- Name: site_270_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_270_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_270_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_271_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_271_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_271_bol_number_seq OWNER TO nulogy;

--
-- Name: site_271_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_271_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_271_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_272_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_272_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_272_bol_number_seq OWNER TO nulogy;

--
-- Name: site_272_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_272_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_272_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_273_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_273_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_273_bol_number_seq OWNER TO nulogy;

--
-- Name: site_273_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_273_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_273_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_274_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_274_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_274_bol_number_seq OWNER TO nulogy;

--
-- Name: site_274_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_274_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_274_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_275_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_275_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_275_bol_number_seq OWNER TO nulogy;

--
-- Name: site_275_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_275_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_275_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_276_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_276_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_276_bol_number_seq OWNER TO nulogy;

--
-- Name: site_276_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_276_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_276_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_277_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_277_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_277_bol_number_seq OWNER TO nulogy;

--
-- Name: site_277_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_277_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_277_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_278_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_278_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_278_bol_number_seq OWNER TO nulogy;

--
-- Name: site_278_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_278_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_278_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_279_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_279_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_279_bol_number_seq OWNER TO nulogy;

--
-- Name: site_279_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_279_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_279_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_27_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_27_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_27_bol_number_seq OWNER TO nulogy;

--
-- Name: site_27_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_27_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_27_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_280_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_280_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_280_bol_number_seq OWNER TO nulogy;

--
-- Name: site_280_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_280_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_280_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_281_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_281_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_281_bol_number_seq OWNER TO nulogy;

--
-- Name: site_281_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_281_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_281_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_282_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_282_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_282_bol_number_seq OWNER TO nulogy;

--
-- Name: site_282_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_282_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_282_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_283_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_283_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_283_bol_number_seq OWNER TO nulogy;

--
-- Name: site_283_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_283_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_283_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_284_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_284_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_284_bol_number_seq OWNER TO nulogy;

--
-- Name: site_284_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_284_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_284_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_285_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_285_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_285_bol_number_seq OWNER TO nulogy;

--
-- Name: site_285_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_285_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_285_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_286_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_286_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_286_bol_number_seq OWNER TO nulogy;

--
-- Name: site_286_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_286_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_286_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_287_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_287_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_287_bol_number_seq OWNER TO nulogy;

--
-- Name: site_287_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_287_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_287_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_28_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_28_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_28_bol_number_seq OWNER TO nulogy;

--
-- Name: site_28_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_28_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_28_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_29_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_29_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_29_bol_number_seq OWNER TO nulogy;

--
-- Name: site_29_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_29_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_29_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_2_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_2_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_2_bol_number_seq OWNER TO nulogy;

--
-- Name: site_2_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_2_pallet_number_seq
    START WITH 13
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_2_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30327_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30327_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30327_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30327_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30327_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30327_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30329_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30329_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30329_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30329_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30329_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30329_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30330_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30330_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30330_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30330_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30330_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30330_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30332_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30332_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30332_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30332_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30332_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30332_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30335_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30335_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30335_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30335_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30335_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30335_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30336_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30336_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30336_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30336_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30336_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30336_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30337_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30337_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30337_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30337_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30337_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30337_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30338_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30338_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30338_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30338_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30338_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30338_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30341_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30341_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30341_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30341_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30341_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30341_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30342_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30342_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30342_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30342_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30342_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30342_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30344_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30344_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30344_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30344_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30344_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30344_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30346_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30346_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30346_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30346_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30346_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30346_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30347_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30347_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30347_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30347_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30347_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30347_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30352_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30352_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30352_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30352_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30352_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30352_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30385_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30385_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30385_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30385_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30385_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30385_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30386_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30386_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30386_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30386_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30386_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30386_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30387_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30387_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30387_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30387_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30387_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30387_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30388_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30388_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30388_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30388_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30388_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30388_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30389_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30389_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30389_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30389_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30389_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30389_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30390_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30390_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30390_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30390_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30390_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30390_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30391_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30391_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30391_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30391_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30391_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30391_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_30_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30_bol_number_seq OWNER TO nulogy;

--
-- Name: site_30_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_30_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_30_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_319_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_319_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_319_bol_number_seq OWNER TO nulogy;

--
-- Name: site_319_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_319_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_319_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_31_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_31_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_31_bol_number_seq OWNER TO nulogy;

--
-- Name: site_31_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_31_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_31_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_320_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_320_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_320_bol_number_seq OWNER TO nulogy;

--
-- Name: site_320_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_320_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_320_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_322_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_322_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_322_bol_number_seq OWNER TO nulogy;

--
-- Name: site_322_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_322_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_322_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_323_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_323_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_323_bol_number_seq OWNER TO nulogy;

--
-- Name: site_323_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_323_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_323_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_324_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_324_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_324_bol_number_seq OWNER TO nulogy;

--
-- Name: site_324_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_324_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_324_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_325_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_325_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_325_bol_number_seq OWNER TO nulogy;

--
-- Name: site_325_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_325_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_325_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_326_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_326_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_326_bol_number_seq OWNER TO nulogy;

--
-- Name: site_326_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_326_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_326_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_32_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_32_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_32_bol_number_seq OWNER TO nulogy;

--
-- Name: site_32_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_32_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_32_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_33_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_33_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_33_bol_number_seq OWNER TO nulogy;

--
-- Name: site_33_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_33_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_33_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_34_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_34_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_34_bol_number_seq OWNER TO nulogy;

--
-- Name: site_34_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_34_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_34_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_35_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_35_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_35_bol_number_seq OWNER TO nulogy;

--
-- Name: site_35_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_35_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_35_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_36_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_36_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_36_bol_number_seq OWNER TO nulogy;

--
-- Name: site_36_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_36_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_36_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_37_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_37_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_37_bol_number_seq OWNER TO nulogy;

--
-- Name: site_37_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_37_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_37_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_38_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_38_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_38_bol_number_seq OWNER TO nulogy;

--
-- Name: site_38_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_38_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_38_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_39_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_39_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_39_bol_number_seq OWNER TO nulogy;

--
-- Name: site_39_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_39_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_39_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_3_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_3_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_3_bol_number_seq OWNER TO nulogy;

--
-- Name: site_3_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_3_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_3_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_40_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_40_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_40_bol_number_seq OWNER TO nulogy;

--
-- Name: site_40_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_40_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_40_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_41_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_41_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_41_bol_number_seq OWNER TO nulogy;

--
-- Name: site_41_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_41_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_41_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_42_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_42_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_42_bol_number_seq OWNER TO nulogy;

--
-- Name: site_42_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_42_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_42_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_43_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_43_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_43_bol_number_seq OWNER TO nulogy;

--
-- Name: site_43_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_43_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_43_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_44_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_44_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_44_bol_number_seq OWNER TO nulogy;

--
-- Name: site_44_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_44_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_44_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_45_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_45_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_45_bol_number_seq OWNER TO nulogy;

--
-- Name: site_45_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_45_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_45_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_46_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_46_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_46_bol_number_seq OWNER TO nulogy;

--
-- Name: site_46_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_46_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_46_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_47_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_47_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_47_bol_number_seq OWNER TO nulogy;

--
-- Name: site_47_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_47_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_47_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_48_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_48_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_48_bol_number_seq OWNER TO nulogy;

--
-- Name: site_48_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_48_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_48_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_49_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_49_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_49_bol_number_seq OWNER TO nulogy;

--
-- Name: site_49_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_49_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_49_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_4_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_4_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_4_bol_number_seq OWNER TO nulogy;

--
-- Name: site_4_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_4_pallet_number_seq
    START WITH 4
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_4_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_50_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_50_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_50_bol_number_seq OWNER TO nulogy;

--
-- Name: site_50_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_50_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_50_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_51_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_51_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_51_bol_number_seq OWNER TO nulogy;

--
-- Name: site_51_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_51_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_51_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_52_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_52_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_52_bol_number_seq OWNER TO nulogy;

--
-- Name: site_52_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_52_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_52_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_53_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_53_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_53_bol_number_seq OWNER TO nulogy;

--
-- Name: site_53_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_53_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_53_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_54_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_54_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_54_bol_number_seq OWNER TO nulogy;

--
-- Name: site_54_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_54_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_54_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_55_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_55_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_55_bol_number_seq OWNER TO nulogy;

--
-- Name: site_55_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_55_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_55_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_56_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_56_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_56_bol_number_seq OWNER TO nulogy;

--
-- Name: site_56_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_56_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_56_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_57_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_57_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_57_bol_number_seq OWNER TO nulogy;

--
-- Name: site_57_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_57_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_57_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_58_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_58_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_58_bol_number_seq OWNER TO nulogy;

--
-- Name: site_58_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_58_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_58_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_59_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_59_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_59_bol_number_seq OWNER TO nulogy;

--
-- Name: site_59_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_59_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_59_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_5_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_5_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_5_bol_number_seq OWNER TO nulogy;

--
-- Name: site_5_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_5_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_5_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_60_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_60_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_60_bol_number_seq OWNER TO nulogy;

--
-- Name: site_60_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_60_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_60_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_61_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_61_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_61_bol_number_seq OWNER TO nulogy;

--
-- Name: site_61_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_61_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_61_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_62_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_62_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_62_bol_number_seq OWNER TO nulogy;

--
-- Name: site_62_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_62_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_62_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_63_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_63_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_63_bol_number_seq OWNER TO nulogy;

--
-- Name: site_63_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_63_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_63_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_66_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_66_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_66_bol_number_seq OWNER TO nulogy;

--
-- Name: site_66_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_66_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_66_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_67_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_67_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_67_bol_number_seq OWNER TO nulogy;

--
-- Name: site_67_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_67_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_67_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_68_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_68_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_68_bol_number_seq OWNER TO nulogy;

--
-- Name: site_68_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_68_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_68_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_69_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_69_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_69_bol_number_seq OWNER TO nulogy;

--
-- Name: site_69_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_69_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_69_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_6_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_6_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_6_bol_number_seq OWNER TO nulogy;

--
-- Name: site_6_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_6_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_6_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_70_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_70_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_70_bol_number_seq OWNER TO nulogy;

--
-- Name: site_70_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_70_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_70_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_71_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_71_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_71_bol_number_seq OWNER TO nulogy;

--
-- Name: site_71_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_71_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_71_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_73_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_73_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_73_bol_number_seq OWNER TO nulogy;

--
-- Name: site_73_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_73_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_73_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_74_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_74_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_74_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_75_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_75_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_75_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_76_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_76_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_76_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_77_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_77_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_77_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_78_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_78_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_78_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_79_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_79_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_79_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_7_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_7_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_7_bol_number_seq OWNER TO nulogy;

--
-- Name: site_7_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_7_pallet_number_seq
    START WITH 19832
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_7_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_80_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_80_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_80_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_81_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_81_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_81_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_82_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_82_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_82_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_83_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_83_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_83_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_84_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_84_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_84_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_85_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_85_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_85_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_86_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_86_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_86_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_87_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_87_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_87_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_88_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_88_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_88_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_89_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_89_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_89_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_8_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_8_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_8_bol_number_seq OWNER TO nulogy;

--
-- Name: site_8_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_8_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_8_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_90_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_90_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_90_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_91_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_91_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_91_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_92_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_92_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_92_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_93_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_93_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_93_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_94_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_94_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_94_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_95_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_95_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_95_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_96_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_96_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_96_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_97_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_97_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_97_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_98_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_98_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_98_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_99_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_99_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_99_pallet_number_seq OWNER TO nulogy;

--
-- Name: site_9_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_9_bol_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_9_bol_number_seq OWNER TO nulogy;

--
-- Name: site_9_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE site_9_pallet_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_9_pallet_number_seq OWNER TO nulogy;

--
-- Name: sites; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE sites (
    id integer NOT NULL,
    name text,
    description text,
    account_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    inventory boolean DEFAULT false,
    tna boolean DEFAULT false,
    timezone text DEFAULT 'America/New_York'::character varying,
    address text,
    drp boolean DEFAULT false,
    production_metric_tracking text DEFAULT 'units_per_hour'::character varying,
    phone_number text,
    display_alt_code_1_on_pallet_tag boolean DEFAULT false,
    display_alt_code_2_on_pallet_tag boolean DEFAULT false,
    default_shipment_quickbooks_status text DEFAULT 'entered'::character varying,
    default_production_graph text DEFAULT 'line_efficiency'::text,
    display_creation_date_on_pallet_tag boolean DEFAULT false,
    validate_quick_consume boolean DEFAULT false,
    default_shift_id integer,
    use_shipment_custom_1 boolean DEFAULT false,
    use_shipment_custom_2 boolean DEFAULT false,
    shipment_custom_1_label text DEFAULT 'Reference 1'::character varying,
    shipment_custom_2_label text DEFAULT 'Reference 2'::character varying,
    add_receipt_items_automatically boolean DEFAULT true,
    workflow text DEFAULT 'none'::character varying,
    display_job_on_pallet_tag boolean DEFAULT false,
    setting_create_projects_from_ship_orders boolean DEFAULT false,
    show_availability_report boolean DEFAULT false,
    show_current_inventory_report boolean DEFAULT true,
    missing_inventory_on_production text DEFAULT 'warning'::character varying,
    show_subcomponent_availability_report boolean DEFAULT false,
    show_freight_charge_terms_on_ship_order boolean DEFAULT false,
    require_trailer_number_on_shipments boolean DEFAULT false,
    require_seal_number_on_shipments boolean DEFAULT false,
    edi boolean DEFAULT false,
    global_access boolean DEFAULT true,
    allow_top_up_from_previous_jobs boolean DEFAULT true,
    no_labor_on_production_or_manual_consumption text DEFAULT 'error'::text,
    planning boolean DEFAULT false,
    lock_shipments_for text DEFAULT 'lead'::text,
    minimum_dequarantine_role text,
    dequarantine_signoff_required boolean DEFAULT false,
    minimum_inventory_adjustment_role text DEFAULT 'lead'::text,
    default_reconciliation_uom text DEFAULT 'eaches'::character varying,
    number_of_weeks_to_show_on_esa integer DEFAULT 2,
    number_of_weeks_to_show_on_efga integer DEFAULT 2,
    use_customer_reference_on_shipping_details boolean DEFAULT false,
    bar_code_size integer DEFAULT 70,
    setting_auto_close_ship_orders boolean,
    mobile_use_location_codes_for_lookup boolean DEFAULT false,
    setting_show_purchase_price_on_receive_order boolean DEFAULT false,
    display_location_on_pallet_tags_for_receipts boolean,
    display_location_on_pallet_tags_for_item_locator boolean,
    display_location_on_pallet_tags_for_cycle_count boolean,
    setting_auto_close_receive_orders boolean DEFAULT false,
    setting_shipment_warning integer DEFAULT 3,
    minimum_recall_shipment_role text DEFAULT 'site_admin'::character varying,
    setting_enforce_complex_passwords boolean DEFAULT false,
    minimum_password_length integer DEFAULT 4,
    setting_allow_case_label_printing boolean DEFAULT false,
    setting_password_expiry integer DEFAULT 0,
    setting_password_reuse integer DEFAULT 0,
    setting_allow_custom_outputs boolean DEFAULT false,
    setting_autoset_project_booked_status boolean DEFAULT true,
    allow_can_run boolean DEFAULT false,
    minimum_locked_ship_order_modification_role text DEFAULT 'site_admin'::character varying,
    setting_default_pallet_tag_printing_on_add_production boolean DEFAULT false,
    display_location_on_pallet_tags_for_jobs boolean DEFAULT false,
    setting_minimum_pallet_number_digits integer DEFAULT 0,
    include_track_by_job_subs_in_missing_inventory boolean DEFAULT true,
    setting_show_print_duplicate_pallet_tag_warning_for_job boolean DEFAULT true,
    setting_require_lot_expiry_for_track_by_job_rejects boolean DEFAULT false,
    setting_allow_multiple_bols boolean DEFAULT true NOT NULL,
    allow_top_up_from_current_job boolean DEFAULT true NOT NULL,
    minimum_reconcile_role text DEFAULT 'lead'::text,
    return_subcomponents_to_matching_pallet boolean DEFAULT true,
    setting_require_quality_to_change_lot_expiries_on_production boolean DEFAULT false,
    copy_project_reference_2_to_shipment_po boolean DEFAULT false,
    external_pallet_numbers integer DEFAULT 0,
    mobile_auto_show_pallet_details_on_move boolean DEFAULT false NOT NULL,
    round_inbound_sto_to text DEFAULT 'item_uom'::character varying NOT NULL,
    allow_blind_counts boolean DEFAULT false NOT NULL,
    job_required_on_inbound_sto boolean DEFAULT false,
    allow_custom_inventory_adjustment_reasons boolean DEFAULT false,
    setting_allow_item_label_printing boolean DEFAULT false NOT NULL,
    allow_overproduction_of_project boolean DEFAULT true,
    require_confirmation_on_outbound_sto boolean DEFAULT false,
    allow_leads_to_change_status_during_blind_counts boolean DEFAULT false,
    allow_multiple_pallets_on_outbound_stock_transfer boolean DEFAULT false NOT NULL,
    use_custom_project_field boolean DEFAULT false,
    setting_maximum_pallet_number_length integer DEFAULT 0 NOT NULL,
    ist_creation_setting_code text DEFAULT 'edi_created_as_complete'::character varying,
    new_job_creator_page boolean DEFAULT false NOT NULL,
    tenant_uid text,
    send_events boolean DEFAULT false NOT NULL,
    enable_planned_receipts boolean DEFAULT false NOT NULL,
    collect_user_feedback boolean DEFAULT false,
    lockdown_reconciled_jobs boolean DEFAULT false NOT NULL,
    maximum_number_of_case_labels integer DEFAULT 30,
    min_reorder_on_job_role text DEFAULT 'disallow'::text,
    enable_gs1_128_barcodes_on_mobile boolean DEFAULT false,
    setting_production_pallet_sequencing character varying(255),
    background_reports text DEFAULT ''::character varying,
    background_exports boolean DEFAULT false NOT NULL,
    enable_notifications boolean DEFAULT false NOT NULL,
    production_picking boolean DEFAULT false,
    pick_locations character varying(255) DEFAULT 'oldest_pallet'::character varying,
    require_project_on_ost character varying(255) DEFAULT 'do not show'::character varying,
    enable_production_focus_view boolean DEFAULT false,
    enable_trailers boolean DEFAULT false,
    allow_gs1_sscc_generation boolean,
    ship_order_picking boolean DEFAULT false,
    enable_tracking_number boolean DEFAULT false,
    allow_gs1_gsin_generation boolean DEFAULT false NOT NULL,
    use_custom_ship_order_fields boolean DEFAULT false,
    include_consignee_sku_on_ship_order_items boolean DEFAULT false NOT NULL,
    enable_item_locator_export boolean DEFAULT false,
    target_availability numeric(16,5) DEFAULT 0.8,
    enable_assemblers_integration boolean DEFAULT false,
    enable_shipment_xml_export boolean DEFAULT false,
    production_overview_override_date timestamp without time zone,
    allow_bom_expansion_on_estimates boolean DEFAULT false,
    enable_cycle_count_background_task boolean DEFAULT false NOT NULL,
    billable boolean DEFAULT true,
    enable_new_styling boolean DEFAULT false,
    scheduling boolean DEFAULT false,
    enable_project_xml_export boolean DEFAULT false,
    enable_estimate_xml_export boolean DEFAULT false,
    show_inventory_adjustment_report boolean DEFAULT false NOT NULL,
    mobile_license_limit integer DEFAULT 0 NOT NULL,
    management_license_limit integer DEFAULT 0 NOT NULL,
    show_job_selection_tab_during_reconciliation boolean DEFAULT false NOT NULL
);


ALTER TABLE public.sites OWNER TO nulogy;

--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sites_id_seq OWNER TO nulogy;

--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE sites_id_seq OWNED BY sites.id;


--
-- Name: sku_attachments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE sku_attachments (
    id integer NOT NULL,
    size integer,
    content_type text,
    document text,
    sku_id integer,
    description text,
    account_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uuid text
);


ALTER TABLE public.sku_attachments OWNER TO nulogy;

--
-- Name: sku_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE sku_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sku_attachments_id_seq OWNER TO nulogy;

--
-- Name: sku_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE sku_attachments_id_seq OWNED BY sku_attachments.id;


--
-- Name: skus; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE skus (
    id integer NOT NULL,
    code text,
    description text,
    customer_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer,
    cost_per_unit numeric(16,5) DEFAULT 0,
    item_type_id integer,
    item_category_id integer,
    alternate_code_1 text,
    alternate_code_2 text,
    weight_per_pallet numeric(16,5) DEFAULT 0,
    inactive boolean DEFAULT false,
    track_lot_code_by text DEFAULT 'pallet'::character varying,
    quick_consume boolean DEFAULT false,
    track_pallets boolean DEFAULT true,
    vendor_id integer,
    qb_list_id text,
    qb_last_sync_at timestamp without time zone,
    export_to_accounting boolean DEFAULT false,
    reorder_strategy integer DEFAULT 0,
    netsuite_id text,
    netsuite_last_sync_at timestamp without time zone,
    auto_backflush boolean DEFAULT true,
    country_of_origin text,
    nmfc_code text,
    freight_class text,
    weight_per_case numeric(16,5) DEFAULT 0.0,
    custom_item_field_1 text,
    custom_item_field_2 text,
    custom_item_field_3 text,
    custom_item_field_4 text,
    custom_item_field_5 text,
    custom_item_field_6 text,
    custom_item_field_7 text,
    custom_item_field_8 text,
    custom_item_field_9 text,
    custom_item_field_10 text,
    custom_item_field_11 text,
    custom_item_field_12 text,
    custom_item_field_13 text,
    custom_item_field_14 text,
    custom_item_field_15 text,
    custom_item_field_16 text,
    custom_item_field_17 text,
    custom_item_field_18 text,
    custom_item_field_19 text,
    custom_item_field_20 text,
    custom_item_field_21 text,
    custom_item_field_22 text,
    custom_item_field_23 text,
    custom_item_field_24 text,
    custom_item_field_25 text,
    item_family_id integer,
    is_subcomponent boolean DEFAULT false,
    is_finished_good boolean DEFAULT false,
    auto_quarantine_on_receipt boolean DEFAULT false,
    auto_quarantine_on_production boolean DEFAULT false,
    safety_stock numeric(16,5) DEFAULT 0.0,
    safety_stock_unit_of_measure text DEFAULT 'eaches'::character varying,
    expiry_date_format_id integer,
    lead_time_type integer DEFAULT 0,
    lead_time_days integer DEFAULT 0,
    reject_rate numeric(16,5) DEFAULT 0,
    item_shelf_life_id integer,
    lot_code_policy text DEFAULT 'do not track'::character varying NOT NULL,
    expiry_date_policy text DEFAULT 'do not track'::character varying NOT NULL,
    lot_code_rule_id integer,
    expiry_date_rule_id integer,
    external_identifier text,
    pick_strategy text DEFAULT 'none'::character varying NOT NULL,
    pick_strategy_source text DEFAULT 'none'::character varying NOT NULL,
    stop_ship_limit integer,
    item_class_id integer,
    safety_stock_uom_id integer,
    record_consumption character varying(255) DEFAULT 'automatically'::character varying NOT NULL,
    require_physical_count_during_reconciliation boolean DEFAULT true NOT NULL,
    reconciliation_threshold_percentage numeric(16,5) DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.skus OWNER TO nulogy;

--
-- Name: skus_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE skus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.skus_id_seq OWNER TO nulogy;

--
-- Name: skus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE skus_id_seq OWNED BY skus.id;


--
-- Name: staging_locations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE staging_locations (
    id integer NOT NULL,
    location_id integer,
    site_id integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.staging_locations OWNER TO nulogy;

--
-- Name: subcomponent_consumption_archives; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE subcomponent_consumption_archives (
    id integer NOT NULL,
    archived_record_id integer,
    archived_record_created_at timestamp without time zone,
    archived_record_updated_at timestamp without time zone,
    lot_code text,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    production_id integer,
    sku_id integer,
    inventory_adjustment_id integer,
    job_id integer,
    expiry_date text,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    site_id integer NOT NULL,
    track_by_job boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unit_uom_id integer
);


ALTER TABLE public.subcomponent_consumption_archives OWNER TO nulogy;

--
-- Name: subcomponent_consumption_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE subcomponent_consumption_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subcomponent_consumption_archives_id_seq OWNER TO nulogy;

--
-- Name: subcomponent_consumption_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE subcomponent_consumption_archives_id_seq OWNED BY subcomponent_consumption_archives.id;


--
-- Name: subcomponent_consumptions; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE subcomponent_consumptions (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    lot_code text,
    unit_quantity numeric(16,5) DEFAULT 0,
    production_id integer,
    sku_id integer,
    inventory_adjustment_id integer,
    job_id integer,
    expiry_date text,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    site_id integer NOT NULL,
    track_by_job boolean DEFAULT false NOT NULL,
    unit_uom_id integer
);


ALTER TABLE public.subcomponent_consumptions OWNER TO nulogy;

--
-- Name: subcomponent_consumptions_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE subcomponent_consumptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subcomponent_consumptions_id_seq OWNER TO nulogy;

--
-- Name: subcomponent_consumptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE subcomponent_consumptions_id_seq OWNED BY subcomponent_consumptions.id;


--
-- Name: time_cards; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE time_cards (
    id integer NOT NULL,
    badge_code text,
    time_in_at timestamp without time zone,
    comments text,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.time_cards OWNER TO nulogy;

--
-- Name: time_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE time_cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.time_cards_id_seq OWNER TO nulogy;

--
-- Name: time_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE time_cards_id_seq OWNED BY time_cards.id;


--
-- Name: time_reports; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE time_reports (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    started_at timestamp without time zone,
    ended_at timestamp without time zone,
    job_id integer,
    badge_code text NOT NULL,
    badge_type_id integer,
    site_id integer,
    cost_per_hour numeric(16,5) DEFAULT 0 NOT NULL
);


ALTER TABLE public.time_reports OWNER TO nulogy;

--
-- Name: time_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE time_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.time_reports_id_seq OWNER TO nulogy;

--
-- Name: time_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE time_reports_id_seq OWNED BY time_reports.id;


--
-- Name: trailer_background_shipments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE trailer_background_shipments (
    id integer NOT NULL,
    outbound_trailer_id integer,
    background_task_id integer,
    site_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.trailer_background_shipments OWNER TO nulogy;

--
-- Name: trailer_background_shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE trailer_background_shipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trailer_background_shipments_id_seq OWNER TO nulogy;

--
-- Name: trailer_background_shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE trailer_background_shipments_id_seq OWNED BY trailer_background_shipments.id;


--
-- Name: unit_moves; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE unit_moves (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    move_id integer,
    pallet_move_id integer,
    site_id integer NOT NULL,
    from_inventory_adjustment_id integer,
    to_inventory_adjustment_id integer,
    sku_id integer,
    unit_quantity numeric(16,5) DEFAULT 0,
    old_each_quantity numeric(16,5) DEFAULT 0,
    expiry_date text,
    lot_code text,
    from_pallet_id integer,
    from_location_id integer,
    to_pallet_id integer,
    to_location_id integer,
    job_reconciliation_id integer,
    inventory_status_id integer,
    unit_uom_id integer
);


ALTER TABLE public.unit_moves OWNER TO nulogy;

--
-- Name: unit_moves_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE unit_moves_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.unit_moves_id_seq OWNER TO nulogy;

--
-- Name: unit_moves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE unit_moves_id_seq OWNED BY unit_moves.id;


--
-- Name: unit_of_measures; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE unit_of_measures (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    label text,
    code text,
    short_label text,
    account_id integer,
    active boolean DEFAULT true NOT NULL,
    integration_key text NOT NULL
);


ALTER TABLE public.unit_of_measures OWNER TO nulogy;

--
-- Name: unit_of_measures_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE unit_of_measures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.unit_of_measures_id_seq OWNER TO nulogy;

--
-- Name: unit_of_measures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE unit_of_measures_id_seq OWNED BY unit_of_measures.id;


--
-- Name: unit_shipments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE unit_shipments (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pallet_id integer,
    unit_quantity numeric(16,5) DEFAULT 0,
    lot_code text,
    expiry_date text,
    sku_id integer,
    shipment_id integer,
    inventory_adjustment_id integer,
    purchase_order_number text,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    location_id integer,
    confirmed boolean,
    site_id integer NOT NULL,
    pallet_shipment_id integer,
    customer_reference text,
    unit_uom_id integer,
    inventory_status_id integer,
    tracking_number text,
    sscc text
);


ALTER TABLE public.unit_shipments OWNER TO nulogy;

--
-- Name: unit_shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE unit_shipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.unit_shipments_id_seq OWNER TO nulogy;

--
-- Name: unit_shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE unit_shipments_id_seq OWNED BY unit_shipments.id;


--
-- Name: uom_contexts; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE uom_contexts (
    id integer NOT NULL,
    sku_id integer,
    default_uom_id integer,
    cases_uom_id integer,
    pallets_uom_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    base_uom_id integer,
    account_id integer NOT NULL,
    reconciliation_uom_id integer
);


ALTER TABLE public.uom_contexts OWNER TO nulogy;

--
-- Name: uom_contexts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE uom_contexts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.uom_contexts_id_seq OWNER TO nulogy;

--
-- Name: uom_contexts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE uom_contexts_id_seq OWNED BY uom_contexts.id;


--
-- Name: uom_ratios; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE uom_ratios (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    code text,
    dimension_id integer NOT NULL,
    account_id integer,
    ratio_to_base numeric(32,10) DEFAULT 0.0,
    base_uom boolean DEFAULT false,
    unit_of_measure_id integer,
    conversion_ratio numeric(32,10),
    conversion_unit_of_measure_id integer,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.uom_ratios OWNER TO nulogy;

--
-- Name: uom_ratios_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE uom_ratios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.uom_ratios_id_seq OWNER TO nulogy;

--
-- Name: uom_ratios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE uom_ratios_id_seq OWNED BY uom_ratios.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    login text,
    email text,
    crypted_password text DEFAULT ''::character varying NOT NULL,
    password_salt text DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer,
    site_id integer,
    role text,
    financial_access text DEFAULT 'none'::text,
    customer_id integer,
    tooltip_delay boolean DEFAULT false,
    last_login_at timestamp without time zone,
    persistence_token text NOT NULL,
    single_access_token text NOT NULL,
    perishable_token text NOT NULL,
    login_count integer DEFAULT 0 NOT NULL,
    failed_login_count integer DEFAULT 0 NOT NULL,
    last_request_at timestamp without time zone,
    current_login_at timestamp without time zone,
    current_login_ip text,
    last_login_ip text,
    announcement_id integer,
    show_announcement boolean DEFAULT true,
    password_updated_at timestamp without time zone,
    expired boolean DEFAULT false,
    previous_passwords text DEFAULT '--- []

'::text,
    mobile_access boolean DEFAULT false,
    desktop_access boolean DEFAULT true,
    allow_quality boolean DEFAULT false,
    nulogy_employee boolean DEFAULT false NOT NULL,
    company_id integer,
    active boolean DEFAULT true NOT NULL,
    locale text DEFAULT 'en_US'::character varying NOT NULL,
    billing_site_id integer NOT NULL,
    uservoice_allow_forums character varying(255)
);


ALTER TABLE public.users OWNER TO nulogy;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO nulogy;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: vendors; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE vendors (
    id integer NOT NULL,
    name text,
    contact text,
    phone text,
    email text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer,
    address text,
    code text,
    qb_list_id text,
    qb_last_sync_at timestamp without time zone,
    order_lead_time integer DEFAULT 0,
    netsuite_id text,
    netsuite_last_sync_at timestamp without time zone,
    default_receipt_status integer DEFAULT 1,
    fax text,
    external_identifier character varying(255)
);


ALTER TABLE public.vendors OWNER TO nulogy;

--
-- Name: vendors_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE vendors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vendors_id_seq OWNER TO nulogy;

--
-- Name: vendors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE vendors_id_seq OWNED BY vendors.id;


--
-- Name: wage_details; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE wage_details (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    badge_type_id integer,
    quantity numeric(16,5) DEFAULT 0.0,
    scenario_id integer,
    account_id integer NOT NULL
);


ALTER TABLE public.wage_details OWNER TO nulogy;

--
-- Name: wage_details_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE wage_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.wage_details_id_seq OWNER TO nulogy;

--
-- Name: wage_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE wage_details_id_seq OWNED BY wage_details.id;


--
-- Name: zoning_rules; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE zoning_rules (
    id integer NOT NULL,
    site_id integer NOT NULL,
    warehouse_zone_id integer NOT NULL,
    item_class_id integer NOT NULL
);


ALTER TABLE public.zoning_rules OWNER TO nulogy;

--
-- Name: warehouse_zone_item_classes_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE warehouse_zone_item_classes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.warehouse_zone_item_classes_id_seq OWNER TO nulogy;

--
-- Name: warehouse_zone_item_classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE warehouse_zone_item_classes_id_seq OWNED BY zoning_rules.id;


--
-- Name: warehouse_zones; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE warehouse_zones (
    id integer NOT NULL,
    name character varying(255),
    site_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    allow_all_items boolean DEFAULT false
);


ALTER TABLE public.warehouse_zones OWNER TO nulogy;

--
-- Name: warehouse_zones_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE warehouse_zones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.warehouse_zones_id_seq OWNER TO nulogy;

--
-- Name: warehouse_zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE warehouse_zones_id_seq OWNED BY warehouse_zones.id;


--
-- Name: wms_allocated_inventory_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE wms_allocated_inventory_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.wms_allocated_inventory_levels_id_seq OWNER TO nulogy;

--
-- Name: wms_allocated_inventory_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE wms_allocated_inventory_levels_id_seq OWNED BY reserved_inventory_levels.id;


--
-- Name: wms_job_staging_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE wms_job_staging_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.wms_job_staging_locations_id_seq OWNER TO nulogy;

--
-- Name: wms_job_staging_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE wms_job_staging_locations_id_seq OWNED BY staging_locations.id;


--
-- Name: wms_pick_constraints_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE wms_pick_constraints_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.wms_pick_constraints_id_seq OWNER TO nulogy;

--
-- Name: wms_pick_constraints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE wms_pick_constraints_id_seq OWNED BY picked_inventory.id;


--
-- Name: wms_pick_constraints_id_seq1; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE wms_pick_constraints_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.wms_pick_constraints_id_seq1 OWNER TO nulogy;

--
-- Name: wms_pick_constraints_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE wms_pick_constraints_id_seq1 OWNED BY pick_constraints.id;


--
-- Name: wms_pick_plan_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE wms_pick_plan_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.wms_pick_plan_items_id_seq OWNER TO nulogy;

--
-- Name: wms_pick_plan_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE wms_pick_plan_items_id_seq OWNED BY pick_plan_items.id;


--
-- Name: wms_planned_shipment_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE wms_planned_shipment_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.wms_planned_shipment_items_id_seq OWNER TO nulogy;

--
-- Name: wms_planned_shipment_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE wms_planned_shipment_items_id_seq OWNED BY planned_shipment_items.id;


--
-- Name: wms_planned_shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE wms_planned_shipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.wms_planned_shipments_id_seq OWNER TO nulogy;

--
-- Name: wms_planned_shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE wms_planned_shipments_id_seq OWNED BY planned_shipments.id;


--
-- Name: workdays; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE TABLE workdays (
    id integer NOT NULL,
    day_of_week integer,
    site_id integer,
    workday boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.workdays OWNER TO nulogy;

--
-- Name: workdays_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy
--

CREATE SEQUENCE workdays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.workdays_id_seq OWNER TO nulogy;

--
-- Name: workdays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy
--

ALTER SEQUENCE workdays_id_seq OWNED BY workdays.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY allowed_accounts ALTER COLUMN id SET DEFAULT nextval('allowed_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY allowed_sites ALTER COLUMN id SET DEFAULT nextval('allowed_sites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY announcements ALTER COLUMN id SET DEFAULT nextval('announcements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY application_configurations ALTER COLUMN id SET DEFAULT nextval('application_configurations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY assembly_item_templates ALTER COLUMN id SET DEFAULT nextval('assembly_item_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY assembly_procedures ALTER COLUMN id SET DEFAULT nextval('assembly_procedures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY assembly_steps ALTER COLUMN id SET DEFAULT nextval('assembly_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY background_report_results ALTER COLUMN id SET DEFAULT nextval('background_query_results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY background_tasks ALTER COLUMN id SET DEFAULT nextval('background_tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY badge_types ALTER COLUMN id SET DEFAULT nextval('badge_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY barcode_configurations ALTER COLUMN id SET DEFAULT nextval('barcode_configurations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY barcode_segments ALTER COLUMN id SET DEFAULT nextval('barcode_segments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY bc_snapshot_items ALTER COLUMN id SET DEFAULT nextval('bc_snapshot_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY blind_count_items ALTER COLUMN id SET DEFAULT nextval('blind_count_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY blind_count_rows ALTER COLUMN id SET DEFAULT nextval('blind_count_rows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY blind_counts ALTER COLUMN id SET DEFAULT nextval('blind_counts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY bom_items ALTER COLUMN id SET DEFAULT nextval('bom_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY bookmark_users ALTER COLUMN id SET DEFAULT nextval('bookmark_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY bookmarks ALTER COLUMN id SET DEFAULT nextval('bookmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY breaks ALTER COLUMN id SET DEFAULT nextval('breaks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY cancel_pick_up_picks ALTER COLUMN id SET DEFAULT nextval('cancel_pick_up_picks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY carriers ALTER COLUMN id SET DEFAULT nextval('carriers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY cc_historical_items ALTER COLUMN id SET DEFAULT nextval('cc_historical_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY companies ALTER COLUMN id SET DEFAULT nextval('companies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY company_locales ALTER COLUMN id SET DEFAULT nextval('company_locales_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY consignee_custom_outputs ALTER COLUMN id SET DEFAULT nextval('consignee_custom_outputs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY consignees ALTER COLUMN id SET DEFAULT nextval('consignees_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY consumption_entries ALTER COLUMN id SET DEFAULT nextval('consumption_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY consumption_plans ALTER COLUMN id SET DEFAULT nextval('consumption_plans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY current_inventory_levels ALTER COLUMN id SET DEFAULT nextval('current_inventory_levels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY custom_charge_settings ALTER COLUMN id SET DEFAULT nextval('custom_charge_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY custom_fields ALTER COLUMN id SET DEFAULT nextval('custom_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY custom_output_attachments ALTER COLUMN id SET DEFAULT nextval('custom_output_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY custom_output_mappings ALTER COLUMN id SET DEFAULT nextval('custom_output_mappings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY custom_outputs ALTER COLUMN id SET DEFAULT nextval('custom_outputs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY custom_per_unit_charges ALTER COLUMN id SET DEFAULT nextval('custom_per_unit_charges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY custom_project_field_values ALTER COLUMN id SET DEFAULT nextval('custom_project_field_values_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY custom_project_fields ALTER COLUMN id SET DEFAULT nextval('custom_project_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY customer_access_configurations ALTER COLUMN id SET DEFAULT nextval('customer_access_configurations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY customers ALTER COLUMN id SET DEFAULT nextval('customers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY cycle_count_items ALTER COLUMN id SET DEFAULT nextval('cycle_count_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY cycle_counts ALTER COLUMN id SET DEFAULT nextval('cycle_counts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY deleted_entities ALTER COLUMN id SET DEFAULT nextval('deleted_entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY discrepancy_reasons ALTER COLUMN id SET DEFAULT nextval('discrepancy_reasons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY dock_appointments ALTER COLUMN id SET DEFAULT nextval('dock_appointments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY downtime_reasons ALTER COLUMN id SET DEFAULT nextval('downtime_reasons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY drop_off_picks ALTER COLUMN id SET DEFAULT nextval('drop_off_picks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY edi_configurations ALTER COLUMN id SET DEFAULT nextval('edi_configurations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY edi_customer_triggers ALTER COLUMN id SET DEFAULT nextval('edi_customer_triggers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY edi_inbounds ALTER COLUMN id SET DEFAULT nextval('edi_inbounds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY edi_logs ALTER COLUMN id SET DEFAULT nextval('edi_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY edi_mapping_items ALTER COLUMN id SET DEFAULT nextval('edi_mapping_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY edi_mappings ALTER COLUMN id SET DEFAULT nextval('edi_mappings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY edi_outbounds ALTER COLUMN id SET DEFAULT nextval('edi_outbounds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY edi_skip_locations ALTER COLUMN id SET DEFAULT nextval('edi_skip_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY edi_status_locations ALTER COLUMN id SET DEFAULT nextval('edi_status_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY email_domains ALTER COLUMN id SET DEFAULT nextval('email_domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY expected_order_on_dock_appointments ALTER COLUMN id SET DEFAULT nextval('expected_order_on_dock_appointments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY expected_pallet_moves ALTER COLUMN id SET DEFAULT nextval('expected_pallet_moves_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY expected_unit_moves ALTER COLUMN id SET DEFAULT nextval('expected_unit_moves_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY expiry_date_formats ALTER COLUMN id SET DEFAULT nextval('expiry_date_formats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY external_inventory_levels ALTER COLUMN id SET DEFAULT nextval('external_inventory_levels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY external_inventory_locations ALTER COLUMN id SET DEFAULT nextval('external_inventory_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY floor_locations ALTER COLUMN id SET DEFAULT nextval('floor_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY gl_accounts ALTER COLUMN id SET DEFAULT nextval('gl_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY gs1_gsin_sequences ALTER COLUMN id SET DEFAULT nextval('gs1_gsin_sequences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY gs1_sscc_sequences ALTER COLUMN id SET DEFAULT nextval('gs1_sscc_sequences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY icg_reference_data_fields ALTER COLUMN id SET DEFAULT nextval('icg_reference_data_field_infos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY icg_reference_data_rows ALTER COLUMN id SET DEFAULT nextval('icg_reference_datum_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY icg_reference_data_tables ALTER COLUMN id SET DEFAULT nextval('icg_reference_data_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY icg_rule_fragments ALTER COLUMN id SET DEFAULT nextval('icg_rule_fragments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY icg_rules ALTER COLUMN id SET DEFAULT nextval('icg_rules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY imported_inventories ALTER COLUMN id SET DEFAULT nextval('imported_inventories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY inbound_stock_transfer_items ALTER COLUMN id SET DEFAULT nextval('inbound_stock_transfer_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY inbound_stock_transfer_order_items ALTER COLUMN id SET DEFAULT nextval('inbound_stock_transfer_order_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY inbound_stock_transfer_orders ALTER COLUMN id SET DEFAULT nextval('inbound_stock_transfer_orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY inbound_stock_transfer_pallets ALTER COLUMN id SET DEFAULT nextval('inbound_stock_transfer_pallets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY inbound_stock_transfers ALTER COLUMN id SET DEFAULT nextval('inbound_stock_transfers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY inventory_adjustments ALTER COLUMN id SET DEFAULT nextval('inventory_adjustments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY inventory_discrepancies ALTER COLUMN id SET DEFAULT nextval('inventory_discrepancies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY inventory_snapshot_schedules ALTER COLUMN id SET DEFAULT nextval('inventory_snapshot_schedules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY inventory_snapshots ALTER COLUMN id SET DEFAULT nextval('inventory_snapshots_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY inventory_status_configurations ALTER COLUMN id SET DEFAULT nextval('inventory_status_configurations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY inventory_statuses ALTER COLUMN id SET DEFAULT nextval('inventory_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY invoice_items ALTER COLUMN id SET DEFAULT nextval('invoice_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY invoices ALTER COLUMN id SET DEFAULT nextval('invoices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY ip_white_list_entries ALTER COLUMN id SET DEFAULT nextval('ip_white_list_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY item_carts ALTER COLUMN id SET DEFAULT nextval('item_carts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY item_categories ALTER COLUMN id SET DEFAULT nextval('item_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY item_classes ALTER COLUMN id SET DEFAULT nextval('item_classes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY item_families ALTER COLUMN id SET DEFAULT nextval('item_families_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY item_shelf_lives ALTER COLUMN id SET DEFAULT nextval('icg_item_shelf_lives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY item_types ALTER COLUMN id SET DEFAULT nextval('item_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY job_lot_expiries ALTER COLUMN id SET DEFAULT nextval('job_lot_expiries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY job_reconciliation_counts ALTER COLUMN id SET DEFAULT nextval('job_reconciliation_counts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY job_reconciliation_records ALTER COLUMN id SET DEFAULT nextval('job_reconciliation_records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY job_reconciliations ALTER COLUMN id SET DEFAULT nextval('job_reconciliations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY jobs ALTER COLUMN id SET DEFAULT nextval('jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY licensing_events ALTER COLUMN id SET DEFAULT nextval('licensing_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY lines ALTER COLUMN id SET DEFAULT nextval('lines_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY locations ALTER COLUMN id SET DEFAULT nextval('locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY master_reference_documents ALTER COLUMN id SET DEFAULT nextval('master_reference_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY modification_restrictions ALTER COLUMN id SET DEFAULT nextval('modification_restrictions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY moves ALTER COLUMN id SET DEFAULT nextval('moves_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY outbound_stock_transfer_pallets ALTER COLUMN id SET DEFAULT nextval('outbound_stock_transfer_pallets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY outbound_stock_transfer_units ALTER COLUMN id SET DEFAULT nextval('outbound_stock_transfer_units_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY outbound_stock_transfers ALTER COLUMN id SET DEFAULT nextval('outbound_stock_transfers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY outbound_trailer_routes ALTER COLUMN id SET DEFAULT nextval('outbound_trailer_routes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY outbound_trailer_stops ALTER COLUMN id SET DEFAULT nextval('outbound_trailer_stops_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY outbound_trailers ALTER COLUMN id SET DEFAULT nextval('outbound_trailers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY overhead_worksheets ALTER COLUMN id SET DEFAULT nextval('overhead_worksheets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY pallet_assignments ALTER COLUMN id SET DEFAULT nextval('pallet_assignments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY pallet_charge_settings ALTER COLUMN id SET DEFAULT nextval('pallet_charge_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY pallet_charges ALTER COLUMN id SET DEFAULT nextval('pallet_charges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY pallet_moves ALTER COLUMN id SET DEFAULT nextval('pallet_moves_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY pallet_shipments ALTER COLUMN id SET DEFAULT nextval('pallet_shipments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY pallets ALTER COLUMN id SET DEFAULT nextval('pallets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY pick_constraints ALTER COLUMN id SET DEFAULT nextval('wms_pick_constraints_id_seq1'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY pick_list_line_items ALTER COLUMN id SET DEFAULT nextval('pick_list_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY pick_list_picks ALTER COLUMN id SET DEFAULT nextval('pick_list_picks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY pick_lists ALTER COLUMN id SET DEFAULT nextval('pick_lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY pick_plan_items ALTER COLUMN id SET DEFAULT nextval('wms_pick_plan_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY pick_plans ALTER COLUMN id SET DEFAULT nextval('move_orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY pick_up_picks ALTER COLUMN id SET DEFAULT nextval('pick_up_picks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY picked_inventory ALTER COLUMN id SET DEFAULT nextval('wms_pick_constraints_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY planned_receipt_items ALTER COLUMN id SET DEFAULT nextval('planned_receipt_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY planned_receipts ALTER COLUMN id SET DEFAULT nextval('planned_receipts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY planned_shipment_items ALTER COLUMN id SET DEFAULT nextval('wms_planned_shipment_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY planned_shipments ALTER COLUMN id SET DEFAULT nextval('wms_planned_shipments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY priority_configurations ALTER COLUMN id SET DEFAULT nextval('pick_constraint_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY production_archives ALTER COLUMN id SET DEFAULT nextval('production_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY productions ALTER COLUMN id SET DEFAULT nextval('productions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY project_attachments ALTER COLUMN id SET DEFAULT nextval('project_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY project_charge_settings ALTER COLUMN id SET DEFAULT nextval('project_charge_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY project_charges ALTER COLUMN id SET DEFAULT nextval('project_charges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY qb_logs ALTER COLUMN id SET DEFAULT nextval('qb_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY qc_sheet_items ALTER COLUMN id SET DEFAULT nextval('qc_sheet_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY qc_sheets ALTER COLUMN id SET DEFAULT nextval('qc_sheets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY qc_template_items ALTER COLUMN id SET DEFAULT nextval('qc_template_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY qc_templates ALTER COLUMN id SET DEFAULT nextval('qc_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY quote_attachments ALTER COLUMN id SET DEFAULT nextval('quote_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY quote_reference_documents ALTER COLUMN id SET DEFAULT nextval('quote_reference_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY quoted_bom_items ALTER COLUMN id SET DEFAULT nextval('quoted_bom_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY quotes ALTER COLUMN id SET DEFAULT nextval('quotes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY rack_locations ALTER COLUMN id SET DEFAULT nextval('rack_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY receipt_attachments ALTER COLUMN id SET DEFAULT nextval('receipt_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY receipt_item_logs ALTER COLUMN id SET DEFAULT nextval('receipt_item_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY receipt_items ALTER COLUMN id SET DEFAULT nextval('receipt_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY receipts ALTER COLUMN id SET DEFAULT nextval('receipts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY receive_order_archives ALTER COLUMN id SET DEFAULT nextval('receive_order_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY receive_order_attachments ALTER COLUMN id SET DEFAULT nextval('receive_order_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY receive_order_item_archives ALTER COLUMN id SET DEFAULT nextval('receive_order_item_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY receive_order_items ALTER COLUMN id SET DEFAULT nextval('receive_order_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY receive_orders ALTER COLUMN id SET DEFAULT nextval('receive_orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY reconciliation_reasons ALTER COLUMN id SET DEFAULT nextval('reconciliation_reasons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY reject_reasons ALTER COLUMN id SET DEFAULT nextval('reject_reasons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY rejected_item_archives ALTER COLUMN id SET DEFAULT nextval('rejected_item_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY rejected_items ALTER COLUMN id SET DEFAULT nextval('rejected_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY required_items ALTER COLUMN id SET DEFAULT nextval('required_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY reserved_inventory_levels ALTER COLUMN id SET DEFAULT nextval('wms_allocated_inventory_levels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY scenario_attachments ALTER COLUMN id SET DEFAULT nextval('scenario_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY scenario_charges ALTER COLUMN id SET DEFAULT nextval('scenario_charges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY scenario_loss_reasons ALTER COLUMN id SET DEFAULT nextval('scenario_loss_reasons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY scenario_to_scenario_attachments ALTER COLUMN id SET DEFAULT nextval('scenario_to_scenario_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY scenarios ALTER COLUMN id SET DEFAULT nextval('scenarios_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY scheduled_tasks ALTER COLUMN id SET DEFAULT nextval('scheduled_tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY scheduling_blocks ALTER COLUMN id SET DEFAULT nextval('scheduling_blocks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY scheduling_default_shift_capacities ALTER COLUMN id SET DEFAULT nextval('scheduling_default_shift_capacities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY scheduling_line_assignments ALTER COLUMN id SET DEFAULT nextval('scheduling_line_assignments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY scheduling_lines ALTER COLUMN id SET DEFAULT nextval('scheduling_lines_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY scheduling_project_demands ALTER COLUMN id SET DEFAULT nextval('scheduling_project_demands_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY scheduling_shifts ALTER COLUMN id SET DEFAULT nextval('scheduling_shifts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY selected_items ALTER COLUMN id SET DEFAULT nextval('selected_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY selected_pallets ALTER COLUMN id SET DEFAULT nextval('selected_pallets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY sequence_generators ALTER COLUMN id SET DEFAULT nextval('sequence_generators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY shifts ALTER COLUMN id SET DEFAULT nextval('shifts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY ship_order_attachments ALTER COLUMN id SET DEFAULT nextval('ship_order_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY ship_order_items ALTER COLUMN id SET DEFAULT nextval('ship_order_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY ship_orders ALTER COLUMN id SET DEFAULT nextval('ship_orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY shipment_attachments ALTER COLUMN id SET DEFAULT nextval('shipment_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY shipments ALTER COLUMN id SET DEFAULT nextval('shipments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY sites ALTER COLUMN id SET DEFAULT nextval('sites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY sku_attachments ALTER COLUMN id SET DEFAULT nextval('sku_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY skus ALTER COLUMN id SET DEFAULT nextval('skus_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY staging_locations ALTER COLUMN id SET DEFAULT nextval('wms_job_staging_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY subcomponent_consumption_archives ALTER COLUMN id SET DEFAULT nextval('subcomponent_consumption_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY subcomponent_consumptions ALTER COLUMN id SET DEFAULT nextval('subcomponent_consumptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY time_cards ALTER COLUMN id SET DEFAULT nextval('time_cards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY time_reports ALTER COLUMN id SET DEFAULT nextval('time_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY trailer_background_shipments ALTER COLUMN id SET DEFAULT nextval('trailer_background_shipments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY unit_moves ALTER COLUMN id SET DEFAULT nextval('unit_moves_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY unit_of_measures ALTER COLUMN id SET DEFAULT nextval('unit_of_measures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY unit_shipments ALTER COLUMN id SET DEFAULT nextval('unit_shipments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY uom_contexts ALTER COLUMN id SET DEFAULT nextval('uom_contexts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY uom_ratios ALTER COLUMN id SET DEFAULT nextval('uom_ratios_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY vendors ALTER COLUMN id SET DEFAULT nextval('vendors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY wage_details ALTER COLUMN id SET DEFAULT nextval('wage_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY warehouse_zones ALTER COLUMN id SET DEFAULT nextval('warehouse_zones_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY workdays ALTER COLUMN id SET DEFAULT nextval('workdays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy
--

ALTER TABLE ONLY zoning_rules ALTER COLUMN id SET DEFAULT nextval('warehouse_zone_item_classes_id_seq'::regclass);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: allowed_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY allowed_accounts
    ADD CONSTRAINT allowed_accounts_pkey PRIMARY KEY (id);


--
-- Name: allowed_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY allowed_sites
    ADD CONSTRAINT allowed_sites_pkey PRIMARY KEY (id);


--
-- Name: announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: application_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY application_configurations
    ADD CONSTRAINT application_configurations_pkey PRIMARY KEY (id);


--
-- Name: assembly_item_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY assembly_item_templates
    ADD CONSTRAINT assembly_item_templates_pkey PRIMARY KEY (id);


--
-- Name: assembly_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY assembly_steps
    ADD CONSTRAINT assembly_items_pkey PRIMARY KEY (id);


--
-- Name: assembly_procedures_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY assembly_procedures
    ADD CONSTRAINT assembly_procedures_pkey PRIMARY KEY (id);


--
-- Name: background_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY background_tasks
    ADD CONSTRAINT background_jobs_pkey PRIMARY KEY (id);


--
-- Name: background_query_results_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY background_report_results
    ADD CONSTRAINT background_query_results_pkey PRIMARY KEY (id);


--
-- Name: badges_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY badge_types
    ADD CONSTRAINT badges_pkey PRIMARY KEY (id);


--
-- Name: barcode_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY barcode_configurations
    ADD CONSTRAINT barcode_configurations_pkey PRIMARY KEY (id);


--
-- Name: barcode_segments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY barcode_segments
    ADD CONSTRAINT barcode_segments_pkey PRIMARY KEY (id);


--
-- Name: bc_snapshot_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY bc_snapshot_items
    ADD CONSTRAINT bc_snapshot_items_pkey PRIMARY KEY (id);


--
-- Name: blind_count_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY blind_count_items
    ADD CONSTRAINT blind_count_items_pkey PRIMARY KEY (id);


--
-- Name: blind_count_pallet_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY blind_count_rows
    ADD CONSTRAINT blind_count_pallet_rows_pkey PRIMARY KEY (id);


--
-- Name: blind_counts_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY blind_counts
    ADD CONSTRAINT blind_counts_pkey PRIMARY KEY (id);


--
-- Name: bom_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY bom_items
    ADD CONSTRAINT bom_items_pkey PRIMARY KEY (id);


--
-- Name: bookmark_users_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY bookmark_users
    ADD CONSTRAINT bookmark_users_pkey PRIMARY KEY (id);


--
-- Name: bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: breaks_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY breaks
    ADD CONSTRAINT breaks_pkey PRIMARY KEY (id);


--
-- Name: cancel_pick_up_picks_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY cancel_pick_up_picks
    ADD CONSTRAINT cancel_pick_up_picks_pkey PRIMARY KEY (id);


--
-- Name: carriers_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY carriers
    ADD CONSTRAINT carriers_pkey PRIMARY KEY (id);


--
-- Name: cc_adjustment_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY cycle_count_items
    ADD CONSTRAINT cc_adjustment_items_pkey PRIMARY KEY (id);


--
-- Name: cc_historical_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY cc_historical_items
    ADD CONSTRAINT cc_historical_items_pkey PRIMARY KEY (id);


--
-- Name: companies_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: company_locales_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY company_locales
    ADD CONSTRAINT company_locales_pkey PRIMARY KEY (id);


--
-- Name: consignee_custom_outputs_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY consignee_custom_outputs
    ADD CONSTRAINT consignee_custom_outputs_pkey PRIMARY KEY (id);


--
-- Name: consignees_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY consignees
    ADD CONSTRAINT consignees_pkey PRIMARY KEY (id);


--
-- Name: consumption_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY consumption_entries
    ADD CONSTRAINT consumption_entries_pkey PRIMARY KEY (id);


--
-- Name: consumption_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY consumption_plans
    ADD CONSTRAINT consumption_plans_pkey PRIMARY KEY (id);


--
-- Name: current_inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY current_inventory_levels
    ADD CONSTRAINT current_inventories_pkey PRIMARY KEY (id);


--
-- Name: custom_charge_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY custom_charge_settings
    ADD CONSTRAINT custom_charge_settings_pkey PRIMARY KEY (id);


--
-- Name: custom_item_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY custom_fields
    ADD CONSTRAINT custom_item_fields_pkey PRIMARY KEY (id);


--
-- Name: custom_output_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY custom_output_attachments
    ADD CONSTRAINT custom_output_attachments_pkey PRIMARY KEY (id);


--
-- Name: custom_output_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY custom_output_mappings
    ADD CONSTRAINT custom_output_mappings_pkey PRIMARY KEY (id);


--
-- Name: custom_outputs_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY custom_outputs
    ADD CONSTRAINT custom_outputs_pkey PRIMARY KEY (id);


--
-- Name: custom_per_unit_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY custom_per_unit_charges
    ADD CONSTRAINT custom_per_unit_charges_pkey PRIMARY KEY (id);


--
-- Name: custom_project_field_values_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY custom_project_field_values
    ADD CONSTRAINT custom_project_field_values_pkey PRIMARY KEY (id);


--
-- Name: custom_project_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY custom_project_fields
    ADD CONSTRAINT custom_project_fields_pkey PRIMARY KEY (id);


--
-- Name: customer_access_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY customer_access_configurations
    ADD CONSTRAINT customer_access_configurations_pkey PRIMARY KEY (id);


--
-- Name: customers_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: cycle_counts_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY cycle_counts
    ADD CONSTRAINT cycle_counts_pkey PRIMARY KEY (id);


--
-- Name: default_inventory_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY inventory_status_configurations
    ADD CONSTRAINT default_inventory_statuses_pkey PRIMARY KEY (id);


--
-- Name: deleted_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY deleted_entities
    ADD CONSTRAINT deleted_entities_pkey PRIMARY KEY (id);


--
-- Name: discrepancy_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY discrepancy_reasons
    ADD CONSTRAINT discrepancy_reasons_pkey PRIMARY KEY (id);


--
-- Name: dock_appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY dock_appointments
    ADD CONSTRAINT dock_appointments_pkey PRIMARY KEY (id);


--
-- Name: downtime_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY downtime_reasons
    ADD CONSTRAINT downtime_reasons_pkey PRIMARY KEY (id);


--
-- Name: edi_customer_triggers_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY edi_customer_triggers
    ADD CONSTRAINT edi_customer_triggers_pkey PRIMARY KEY (id);


--
-- Name: edi_location_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY edi_status_locations
    ADD CONSTRAINT edi_location_properties_pkey PRIMARY KEY (id);


--
-- Name: edi_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY edi_logs
    ADD CONSTRAINT edi_logs_pkey PRIMARY KEY (id);


--
-- Name: edi_mapping_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY edi_mapping_items
    ADD CONSTRAINT edi_mapping_items_pkey PRIMARY KEY (id);


--
-- Name: edi_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY edi_mappings
    ADD CONSTRAINT edi_mappings_pkey PRIMARY KEY (id);


--
-- Name: edi_outbounds_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY edi_outbounds
    ADD CONSTRAINT edi_outbounds_pkey PRIMARY KEY (id);


--
-- Name: edi_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY edi_configurations
    ADD CONSTRAINT edi_settings_pkey PRIMARY KEY (id);


--
-- Name: edi_skip_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY edi_skip_locations
    ADD CONSTRAINT edi_skip_locations_pkey PRIMARY KEY (id);


--
-- Name: email_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY email_domains
    ADD CONSTRAINT email_domains_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: expected_move_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY expected_pallet_moves
    ADD CONSTRAINT expected_move_items_pkey PRIMARY KEY (id);


--
-- Name: expected_unit_moves_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY expected_unit_moves
    ADD CONSTRAINT expected_unit_moves_pkey PRIMARY KEY (id);


--
-- Name: expiry_date_formats_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY expiry_date_formats
    ADD CONSTRAINT expiry_date_formats_pkey PRIMARY KEY (id);


--
-- Name: external_inventory_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY external_inventory_levels
    ADD CONSTRAINT external_inventory_levels_pkey PRIMARY KEY (id);


--
-- Name: external_inventory_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY external_inventory_locations
    ADD CONSTRAINT external_inventory_locations_pkey PRIMARY KEY (id);


--
-- Name: floor_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY floor_locations
    ADD CONSTRAINT floor_locations_pkey PRIMARY KEY (id);


--
-- Name: gl_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY gl_accounts
    ADD CONSTRAINT gl_accounts_pkey PRIMARY KEY (id);


--
-- Name: gsin_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY gs1_gsin_sequences
    ADD CONSTRAINT gsin_sequences_pkey PRIMARY KEY (id);


--
-- Name: icg_item_shelf_lives_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY item_shelf_lives
    ADD CONSTRAINT icg_item_shelf_lives_pkey PRIMARY KEY (id);


--
-- Name: icg_reference_data_field_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY icg_reference_data_fields
    ADD CONSTRAINT icg_reference_data_field_infos_pkey PRIMARY KEY (id);


--
-- Name: icg_reference_data_types_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY icg_reference_data_tables
    ADD CONSTRAINT icg_reference_data_types_pkey PRIMARY KEY (id);


--
-- Name: icg_reference_datum_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY icg_reference_data_rows
    ADD CONSTRAINT icg_reference_datum_pkey PRIMARY KEY (id);


--
-- Name: icg_rule_fragments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY icg_rule_fragments
    ADD CONSTRAINT icg_rule_fragments_pkey PRIMARY KEY (id);


--
-- Name: icg_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY icg_rules
    ADD CONSTRAINT icg_rules_pkey PRIMARY KEY (id);


--
-- Name: imported_inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY imported_inventories
    ADD CONSTRAINT imported_inventories_pkey PRIMARY KEY (id);


--
-- Name: inbound_edis_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY edi_inbounds
    ADD CONSTRAINT inbound_edis_pkey PRIMARY KEY (id);


--
-- Name: inbound_stock_transfer_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY inbound_stock_transfer_items
    ADD CONSTRAINT inbound_stock_transfer_items_pkey PRIMARY KEY (id);


--
-- Name: inbound_stock_transfer_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY inbound_stock_transfer_order_items
    ADD CONSTRAINT inbound_stock_transfer_order_items_pkey PRIMARY KEY (id);


--
-- Name: inbound_stock_transfer_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY inbound_stock_transfer_orders
    ADD CONSTRAINT inbound_stock_transfer_orders_pkey PRIMARY KEY (id);


--
-- Name: inbound_stock_transfer_pallets_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY inbound_stock_transfer_pallets
    ADD CONSTRAINT inbound_stock_transfer_pallets_pkey PRIMARY KEY (id);


--
-- Name: inbound_stock_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY inbound_stock_transfers
    ADD CONSTRAINT inbound_stock_transfers_pkey PRIMARY KEY (id);


--
-- Name: inventory_adjustments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY inventory_adjustments
    ADD CONSTRAINT inventory_adjustments_pkey PRIMARY KEY (id);


--
-- Name: inventory_discrepancies_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY inventory_discrepancies
    ADD CONSTRAINT inventory_discrepancies_pkey PRIMARY KEY (id);


--
-- Name: inventory_snapshot_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY inventory_snapshot_schedules
    ADD CONSTRAINT inventory_snapshot_schedules_pkey PRIMARY KEY (id);


--
-- Name: inventory_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY inventory_snapshots
    ADD CONSTRAINT inventory_snapshots_pkey PRIMARY KEY (id);


--
-- Name: inventory_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY inventory_statuses
    ADD CONSTRAINT inventory_statuses_pkey PRIMARY KEY (id);


--
-- Name: invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: ip_white_list_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY ip_white_list_entries
    ADD CONSTRAINT ip_white_list_entries_pkey PRIMARY KEY (id);


--
-- Name: item_carts_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY item_carts
    ADD CONSTRAINT item_carts_pkey PRIMARY KEY (id);


--
-- Name: item_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY item_categories
    ADD CONSTRAINT item_categories_pkey PRIMARY KEY (id);


--
-- Name: item_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY item_classes
    ADD CONSTRAINT item_classes_pkey PRIMARY KEY (id);


--
-- Name: item_families_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY item_families
    ADD CONSTRAINT item_families_pkey PRIMARY KEY (id);


--
-- Name: item_types_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY item_types
    ADD CONSTRAINT item_types_pkey PRIMARY KEY (id);


--
-- Name: job_lot_expiries_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY job_lot_expiries
    ADD CONSTRAINT job_lot_expiries_pkey PRIMARY KEY (id);


--
-- Name: job_reconciliation_counts_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY job_reconciliation_counts
    ADD CONSTRAINT job_reconciliation_counts_pkey PRIMARY KEY (id);


--
-- Name: job_reconciliation_records_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY job_reconciliation_records
    ADD CONSTRAINT job_reconciliation_records_pkey PRIMARY KEY (id);


--
-- Name: job_reconciliations_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY job_reconciliations
    ADD CONSTRAINT job_reconciliations_pkey PRIMARY KEY (id);


--
-- Name: jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: licensing_events_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY licensing_events
    ADD CONSTRAINT licensing_events_pkey PRIMARY KEY (id);


--
-- Name: lines_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY lines
    ADD CONSTRAINT lines_pkey PRIMARY KEY (id);


--
-- Name: locations_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: master_reference_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY master_reference_documents
    ADD CONSTRAINT master_reference_documents_pkey PRIMARY KEY (id);


--
-- Name: modification_restrictions_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY modification_restrictions
    ADD CONSTRAINT modification_restrictions_pkey PRIMARY KEY (id);


--
-- Name: move_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY pallet_moves
    ADD CONSTRAINT move_items_pkey PRIMARY KEY (id);


--
-- Name: move_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY pick_plans
    ADD CONSTRAINT move_orders_pkey PRIMARY KEY (id);


--
-- Name: moves_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY moves
    ADD CONSTRAINT moves_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: outbound_pallet_stock_transfer_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY outbound_stock_transfer_pallets
    ADD CONSTRAINT outbound_pallet_stock_transfer_items_pkey PRIMARY KEY (id);


--
-- Name: outbound_stock_transfer_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY outbound_stock_transfer_units
    ADD CONSTRAINT outbound_stock_transfer_items_pkey PRIMARY KEY (id);


--
-- Name: outbound_stock_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY outbound_stock_transfers
    ADD CONSTRAINT outbound_stock_transfers_pkey PRIMARY KEY (id);


--
-- Name: outbound_trailer_plan_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY expected_order_on_dock_appointments
    ADD CONSTRAINT outbound_trailer_plan_items_pkey PRIMARY KEY (id);


--
-- Name: outbound_trailer_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY outbound_trailer_routes
    ADD CONSTRAINT outbound_trailer_routes_pkey PRIMARY KEY (id);


--
-- Name: outbound_trailer_stops_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY outbound_trailer_stops
    ADD CONSTRAINT outbound_trailer_stops_pkey PRIMARY KEY (id);


--
-- Name: outbound_trailers_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY outbound_trailers
    ADD CONSTRAINT outbound_trailers_pkey PRIMARY KEY (id);


--
-- Name: overhead_worksheets_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY overhead_worksheets
    ADD CONSTRAINT overhead_worksheets_pkey PRIMARY KEY (id);


--
-- Name: pallet_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY pallet_assignments
    ADD CONSTRAINT pallet_assignments_pkey PRIMARY KEY (id);


--
-- Name: pallet_charge_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY pallet_charge_settings
    ADD CONSTRAINT pallet_charge_settings_pkey PRIMARY KEY (id);


--
-- Name: pallet_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY pallet_charges
    ADD CONSTRAINT pallet_charges_pkey PRIMARY KEY (id);


--
-- Name: pallets_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY pallets
    ADD CONSTRAINT pallets_pkey PRIMARY KEY (id);


--
-- Name: pick_constraint_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY priority_configurations
    ADD CONSTRAINT pick_constraint_templates_pkey PRIMARY KEY (id);


--
-- Name: pick_list_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY pick_list_line_items
    ADD CONSTRAINT pick_list_line_items_pkey PRIMARY KEY (id);


--
-- Name: pick_list_picks_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY pick_list_picks
    ADD CONSTRAINT pick_list_picks_pkey PRIMARY KEY (id);


--
-- Name: pick_list_unit_picks_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY drop_off_picks
    ADD CONSTRAINT pick_list_unit_picks_pkey PRIMARY KEY (id);


--
-- Name: pick_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY pick_lists
    ADD CONSTRAINT pick_lists_pkey PRIMARY KEY (id);


--
-- Name: pick_up_picks_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY pick_up_picks
    ADD CONSTRAINT pick_up_picks_pkey PRIMARY KEY (id);


--
-- Name: planned_receipt_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY planned_receipt_items
    ADD CONSTRAINT planned_receipt_items_pkey PRIMARY KEY (id);


--
-- Name: planned_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY planned_receipts
    ADD CONSTRAINT planned_receipts_pkey PRIMARY KEY (id);


--
-- Name: production_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY production_archives
    ADD CONSTRAINT production_archives_pkey PRIMARY KEY (id);


--
-- Name: productions_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY productions
    ADD CONSTRAINT productions_pkey PRIMARY KEY (id);


--
-- Name: project_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY project_attachments
    ADD CONSTRAINT project_attachments_pkey PRIMARY KEY (id);


--
-- Name: project_charge_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY project_charge_settings
    ADD CONSTRAINT project_charge_settings_pkey PRIMARY KEY (id);


--
-- Name: project_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY project_charges
    ADD CONSTRAINT project_charges_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: qb_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY qb_logs
    ADD CONSTRAINT qb_logs_pkey PRIMARY KEY (id);


--
-- Name: qc_template_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY qc_template_items
    ADD CONSTRAINT qc_template_items_pkey PRIMARY KEY (id);


--
-- Name: quality_control_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY qc_sheet_items
    ADD CONSTRAINT quality_control_checks_pkey PRIMARY KEY (id);


--
-- Name: quality_control_sheets_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY qc_sheets
    ADD CONSTRAINT quality_control_sheets_pkey PRIMARY KEY (id);


--
-- Name: quality_control_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY qc_templates
    ADD CONSTRAINT quality_control_templates_pkey PRIMARY KEY (id);


--
-- Name: quote_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY quote_attachments
    ADD CONSTRAINT quote_attachments_pkey PRIMARY KEY (id);


--
-- Name: quote_reference_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY quote_reference_documents
    ADD CONSTRAINT quote_reference_documents_pkey PRIMARY KEY (id);


--
-- Name: quoted_bom_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY quoted_bom_items
    ADD CONSTRAINT quoted_bom_items_pkey PRIMARY KEY (id);


--
-- Name: quotes_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY quotes
    ADD CONSTRAINT quotes_pkey PRIMARY KEY (id);


--
-- Name: rack_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY rack_locations
    ADD CONSTRAINT rack_locations_pkey PRIMARY KEY (id);


--
-- Name: receipt_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY receipt_attachments
    ADD CONSTRAINT receipt_attachments_pkey PRIMARY KEY (id);


--
-- Name: receipt_item_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY receipt_item_logs
    ADD CONSTRAINT receipt_item_logs_pkey PRIMARY KEY (id);


--
-- Name: receipt_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY receipt_items
    ADD CONSTRAINT receipt_items_pkey PRIMARY KEY (id);


--
-- Name: receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY receipts
    ADD CONSTRAINT receipts_pkey PRIMARY KEY (id);


--
-- Name: receive_order_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY receive_order_archives
    ADD CONSTRAINT receive_order_archives_pkey PRIMARY KEY (id);


--
-- Name: receive_order_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY receive_order_attachments
    ADD CONSTRAINT receive_order_attachments_pkey PRIMARY KEY (id);


--
-- Name: receive_order_item_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY receive_order_item_archives
    ADD CONSTRAINT receive_order_item_archives_pkey PRIMARY KEY (id);


--
-- Name: receive_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY receive_order_items
    ADD CONSTRAINT receive_order_items_pkey PRIMARY KEY (id);


--
-- Name: receive_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY receive_orders
    ADD CONSTRAINT receive_orders_pkey PRIMARY KEY (id);


--
-- Name: reconciliation_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY reconciliation_reasons
    ADD CONSTRAINT reconciliation_reasons_pkey PRIMARY KEY (id);


--
-- Name: reject_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY reject_reasons
    ADD CONSTRAINT reject_reasons_pkey PRIMARY KEY (id);


--
-- Name: rejected_item_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY rejected_item_archives
    ADD CONSTRAINT rejected_item_archives_pkey PRIMARY KEY (id);


--
-- Name: rejected_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY rejected_items
    ADD CONSTRAINT rejected_items_pkey PRIMARY KEY (id);


--
-- Name: required_move_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY required_items
    ADD CONSTRAINT required_move_items_pkey PRIMARY KEY (id);


--
-- Name: scenario_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY scenario_attachments
    ADD CONSTRAINT scenario_attachments_pkey PRIMARY KEY (id);


--
-- Name: scenario_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY scenario_charges
    ADD CONSTRAINT scenario_charges_pkey PRIMARY KEY (id);


--
-- Name: scenario_loss_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY scenario_loss_reasons
    ADD CONSTRAINT scenario_loss_reasons_pkey PRIMARY KEY (id);


--
-- Name: scenario_to_scenario_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY scenario_to_scenario_attachments
    ADD CONSTRAINT scenario_to_scenario_attachments_pkey PRIMARY KEY (id);


--
-- Name: scenarios_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY scenarios
    ADD CONSTRAINT scenarios_pkey PRIMARY KEY (id);


--
-- Name: scheduled_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY scheduled_tasks
    ADD CONSTRAINT scheduled_tasks_pkey PRIMARY KEY (id);


--
-- Name: scheduling_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY scheduling_blocks
    ADD CONSTRAINT scheduling_blocks_pkey PRIMARY KEY (id);


--
-- Name: scheduling_default_shift_capacities_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY scheduling_default_shift_capacities
    ADD CONSTRAINT scheduling_default_shift_capacities_pkey PRIMARY KEY (id);


--
-- Name: scheduling_line_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY scheduling_line_assignments
    ADD CONSTRAINT scheduling_line_assignments_pkey PRIMARY KEY (id);


--
-- Name: scheduling_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY scheduling_lines
    ADD CONSTRAINT scheduling_lines_pkey PRIMARY KEY (id);


--
-- Name: scheduling_project_demands_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY scheduling_project_demands
    ADD CONSTRAINT scheduling_project_demands_pkey PRIMARY KEY (id);


--
-- Name: scheduling_shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY scheduling_shifts
    ADD CONSTRAINT scheduling_shifts_pkey PRIMARY KEY (id);


--
-- Name: selected_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY selected_items
    ADD CONSTRAINT selected_items_pkey PRIMARY KEY (id);


--
-- Name: selected_pallets_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY selected_pallets
    ADD CONSTRAINT selected_pallets_pkey PRIMARY KEY (id);


--
-- Name: sequence_generators_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY sequence_generators
    ADD CONSTRAINT sequence_generators_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY shifts
    ADD CONSTRAINT shifts_pkey PRIMARY KEY (id);


--
-- Name: ship_order_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY ship_order_attachments
    ADD CONSTRAINT ship_order_attachments_pkey PRIMARY KEY (id);


--
-- Name: ship_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY ship_order_items
    ADD CONSTRAINT ship_order_items_pkey PRIMARY KEY (id);


--
-- Name: ship_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY ship_orders
    ADD CONSTRAINT ship_orders_pkey PRIMARY KEY (id);


--
-- Name: shipment_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY shipment_attachments
    ADD CONSTRAINT shipment_attachments_pkey PRIMARY KEY (id);


--
-- Name: shipment_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY pallet_shipments
    ADD CONSTRAINT shipment_items_pkey PRIMARY KEY (id);


--
-- Name: shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY shipments
    ADD CONSTRAINT shipments_pkey PRIMARY KEY (id);


--
-- Name: sites_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: sku_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY sku_attachments
    ADD CONSTRAINT sku_attachments_pkey PRIMARY KEY (id);


--
-- Name: skus_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY skus
    ADD CONSTRAINT skus_pkey PRIMARY KEY (id);


--
-- Name: sscc_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY gs1_sscc_sequences
    ADD CONSTRAINT sscc_sequences_pkey PRIMARY KEY (id);


--
-- Name: subcomponent_consumption_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY subcomponent_consumption_archives
    ADD CONSTRAINT subcomponent_consumption_archives_pkey PRIMARY KEY (id);


--
-- Name: subcomponent_consumptions_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY subcomponent_consumptions
    ADD CONSTRAINT subcomponent_consumptions_pkey PRIMARY KEY (id);


--
-- Name: time_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY time_cards
    ADD CONSTRAINT time_cards_pkey PRIMARY KEY (id);


--
-- Name: time_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY time_reports
    ADD CONSTRAINT time_reports_pkey PRIMARY KEY (id);


--
-- Name: trailer_background_shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY trailer_background_shipments
    ADD CONSTRAINT trailer_background_shipments_pkey PRIMARY KEY (id);


--
-- Name: unit_moves_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY unit_moves
    ADD CONSTRAINT unit_moves_pkey PRIMARY KEY (id);


--
-- Name: unit_of_measures_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY uom_ratios
    ADD CONSTRAINT unit_of_measures_pkey PRIMARY KEY (id);


--
-- Name: unit_of_measures_pkey1; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY unit_of_measures
    ADD CONSTRAINT unit_of_measures_pkey1 PRIMARY KEY (id);


--
-- Name: unit_shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY unit_shipments
    ADD CONSTRAINT unit_shipments_pkey PRIMARY KEY (id);


--
-- Name: uom_contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY uom_contexts
    ADD CONSTRAINT uom_contexts_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);


--
-- Name: wage_details_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY wage_details
    ADD CONSTRAINT wage_details_pkey PRIMARY KEY (id);


--
-- Name: warehouse_zone_item_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY zoning_rules
    ADD CONSTRAINT warehouse_zone_item_classes_pkey PRIMARY KEY (id);


--
-- Name: warehouse_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY warehouse_zones
    ADD CONSTRAINT warehouse_zones_pkey PRIMARY KEY (id);


--
-- Name: wms_allocated_inventory_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY reserved_inventory_levels
    ADD CONSTRAINT wms_allocated_inventory_levels_pkey PRIMARY KEY (id);


--
-- Name: wms_job_staging_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY staging_locations
    ADD CONSTRAINT wms_job_staging_locations_pkey PRIMARY KEY (id);


--
-- Name: wms_pick_constraints_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY picked_inventory
    ADD CONSTRAINT wms_pick_constraints_pkey PRIMARY KEY (id);


--
-- Name: wms_pick_constraints_pkey1; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY pick_constraints
    ADD CONSTRAINT wms_pick_constraints_pkey1 PRIMARY KEY (id);


--
-- Name: wms_pick_plan_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY pick_plan_items
    ADD CONSTRAINT wms_pick_plan_items_pkey PRIMARY KEY (id);


--
-- Name: wms_planned_shipment_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY planned_shipment_items
    ADD CONSTRAINT wms_planned_shipment_items_pkey PRIMARY KEY (id);


--
-- Name: wms_planned_shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY planned_shipments
    ADD CONSTRAINT wms_planned_shipments_pkey PRIMARY KEY (id);


--
-- Name: workdays_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
--

ALTER TABLE ONLY workdays
    ADD CONSTRAINT workdays_pkey PRIMARY KEY (id);


--
-- Name: edi_outbounds_site_id_type_status_idx; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX edi_outbounds_site_id_type_status_idx ON edi_outbounds USING btree (site_id, type varchar_pattern_ops, status);


--
-- Name: idx_ist_on_site_and_external_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX idx_ist_on_site_and_external_id ON inbound_stock_transfers USING btree (site_id, external_identifier);


--
-- Name: idx_isti_on_istp_and_external_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX idx_isti_on_istp_and_external_id ON inbound_stock_transfer_items USING btree (inbound_stock_transfer_pallet_id, external_identifier);


--
-- Name: idx_istp_on_ist_and_external_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX idx_istp_on_ist_and_external_id ON inbound_stock_transfer_pallets USING btree (inbound_stock_transfer_id, external_identifier);


--
-- Name: index_assembly_items_on_account_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_assembly_items_on_account_id ON assembly_steps USING btree (account_id);


--
-- Name: index_assembly_procedures_on_account_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_assembly_procedures_on_account_id ON assembly_procedures USING btree (account_id);


--
-- Name: index_assembly_procedures_on_sku_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_assembly_procedures_on_sku_id ON assembly_procedures USING btree (sku_id);


--
-- Name: index_background_tasks_on_task_type; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_background_tasks_on_task_type ON background_tasks USING btree (task_type);


--
-- Name: index_background_tasks_on_user_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_background_tasks_on_user_id ON background_tasks USING btree (user_id);


--
-- Name: index_blind_counts_on_location_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_blind_counts_on_location_id ON blind_counts USING btree (location_id);


--
-- Name: index_bom_items_on_account_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_bom_items_on_account_id ON bom_items USING btree (account_id);


--
-- Name: index_bom_items_on_sku_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_bom_items_on_sku_id ON bom_items USING btree (sku_id);


--
-- Name: index_bom_items_on_sku_id_and_external_identifier; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_bom_items_on_sku_id_and_external_identifier ON bom_items USING btree (sku_id, external_identifier);


--
-- Name: index_bom_items_on_sku_id_and_subcomponent_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_bom_items_on_sku_id_and_subcomponent_id ON bom_items USING btree (sku_id, subcomponent_id);


--
-- Name: index_bom_items_on_subcomponent_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_bom_items_on_subcomponent_id ON bom_items USING btree (subcomponent_id);


--
-- Name: index_breaks_on_job_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_breaks_on_job_id ON breaks USING btree (job_id);


--
-- Name: index_breaks_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_breaks_on_site_id ON breaks USING btree (site_id);


--
-- Name: index_cc_historical_items_on_cc_adjustment_item_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_cc_historical_items_on_cc_adjustment_item_id ON cc_historical_items USING btree (cycle_count_item_id);


--
-- Name: index_consumption_entries_on_subcomponents; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_consumption_entries_on_subcomponents ON consumption_entries USING btree (consumption_plan_id, subcomponent_id);


--
-- Name: index_current_inventory_levels_on_location_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_current_inventory_levels_on_location_id ON current_inventory_levels USING btree (location_id);


--
-- Name: index_current_inventory_levels_on_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_current_inventory_levels_on_pallet_id ON current_inventory_levels USING btree (pallet_id);


--
-- Name: index_current_inventory_levels_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_current_inventory_levels_on_site_id ON current_inventory_levels USING btree (site_id);


--
-- Name: index_current_inventory_levels_on_sku_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_current_inventory_levels_on_sku_id ON current_inventory_levels USING btree (sku_id);


--
-- Name: index_customers_on_account_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_customers_on_account_id ON customers USING btree (account_id);


--
-- Name: index_cycle_count_items_on_cycle_count_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_cycle_count_items_on_cycle_count_id ON cycle_count_items USING btree (cycle_count_id);


--
-- Name: index_cycle_counts_for_accounting_sync; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_cycle_counts_for_accounting_sync ON cycle_counts USING btree (site_id, status, closed_at, synchronized_status);


--
-- Name: index_edi_location_properties_on_location_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_edi_location_properties_on_location_id ON edi_status_locations USING btree (location_id);


--
-- Name: index_edi_mapping_items_on_sku_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_edi_mapping_items_on_sku_id ON edi_mapping_items USING btree (sku_id);


--
-- Name: index_edi_outbounds_on_source_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_edi_outbounds_on_source_id ON edi_outbounds USING btree (source_id);


--
-- Name: index_events_on_processed; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_events_on_processed ON events USING btree (processed);


--
-- Name: index_events_on_site_id_and_event_uid; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_events_on_site_id_and_event_uid ON events USING btree (site_id, event_uid);


--
-- Name: index_expected_pallet_moves_on_move_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_expected_pallet_moves_on_move_id ON expected_pallet_moves USING btree (move_id);


--
-- Name: index_expected_unit_moves_on_expected_pallet_move_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_expected_unit_moves_on_expected_pallet_move_id ON expected_unit_moves USING btree (expected_pallet_move_id);


--
-- Name: index_expected_unit_moves_on_from_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_expected_unit_moves_on_from_pallet_id ON expected_unit_moves USING btree (from_pallet_id);


--
-- Name: index_expected_unit_moves_on_move_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_expected_unit_moves_on_move_id ON expected_unit_moves USING btree (move_id);


--
-- Name: index_expected_unit_moves_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_expected_unit_moves_on_site_id ON expected_unit_moves USING btree (site_id);


--
-- Name: index_ext_inv_location_on_site_id_and_external_identifier; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_ext_inv_location_on_site_id_and_external_identifier ON external_inventory_locations USING btree (site_id, external_identifier);


--
-- Name: index_inbound_stock_transfer_items_on_inventory_adjustment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inbound_stock_transfer_items_on_inventory_adjustment_id ON inbound_stock_transfer_items USING btree (inventory_adjustment_id);


--
-- Name: index_inbound_stock_transfer_items_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inbound_stock_transfer_items_on_site_id ON inbound_stock_transfer_items USING btree (site_id);


--
-- Name: index_inbound_stock_transfer_orders_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inbound_stock_transfer_orders_on_site_id ON inbound_stock_transfer_orders USING btree (site_id);


--
-- Name: index_inbound_stock_transfers_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inbound_stock_transfers_on_site_id ON inbound_stock_transfers USING btree (site_id);


--
-- Name: index_inventory_adjustments_on_location_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inventory_adjustments_on_location_id ON inventory_adjustments USING btree (location_id);


--
-- Name: index_inventory_adjustments_on_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inventory_adjustments_on_pallet_id ON inventory_adjustments USING btree (pallet_id);


--
-- Name: index_inventory_adjustments_on_site_id_and_created_at; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inventory_adjustments_on_site_id_and_created_at ON inventory_adjustments USING btree (site_id, created_at);


--
-- Name: index_inventory_adjustments_on_sku_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inventory_adjustments_on_sku_id ON inventory_adjustments USING btree (sku_id);


--
-- Name: index_inventory_discrepancies_for_accounting_sync; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inventory_discrepancies_for_accounting_sync ON inventory_discrepancies USING btree (site_id, synchronized_status, created_at) WHERE (user_generated = true);


--
-- Name: index_inventory_discrepancies_on_add_adjustment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inventory_discrepancies_on_add_adjustment_id ON inventory_discrepancies USING btree (add_adjustment_id);


--
-- Name: index_inventory_discrepancies_on_created_at; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inventory_discrepancies_on_created_at ON inventory_discrepancies USING btree (created_at);


--
-- Name: index_inventory_discrepancies_on_cycle_count_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inventory_discrepancies_on_cycle_count_id ON inventory_discrepancies USING btree (cycle_count_id);


--
-- Name: index_inventory_discrepancies_on_remove_adjustment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inventory_discrepancies_on_remove_adjustment_id ON inventory_discrepancies USING btree (remove_adjustment_id);


--
-- Name: index_inventory_discrepancies_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inventory_discrepancies_on_site_id ON inventory_discrepancies USING btree (site_id);


--
-- Name: index_inventory_discrepancies_on_site_id_and_external_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_inventory_discrepancies_on_site_id_and_external_id ON inventory_discrepancies USING btree (site_id, external_identifier);


--
-- Name: index_inventory_discrepancies_on_subcomponent_consumption_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inventory_discrepancies_on_subcomponent_consumption_id ON inventory_discrepancies USING btree (subcomponent_consumption_id);


--
-- Name: index_inventory_discrepancies_on_synchronized_status; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_inventory_discrepancies_on_synchronized_status ON inventory_discrepancies USING btree (synchronized_status);


--
-- Name: index_inventory_statuses_on_site_id_and_integration_key; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_inventory_statuses_on_site_id_and_integration_key ON inventory_statuses USING btree (site_id, integration_key);


--
-- Name: index_inventory_statuses_on_site_id_and_name; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_inventory_statuses_on_site_id_and_name ON inventory_statuses USING btree (site_id, name);


--
-- Name: index_invoices_for_accounting_sync; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_invoices_for_accounting_sync ON invoices USING btree (site_id, invoiced_at, synchronized_status);


--
-- Name: index_ist_on_isto_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_ist_on_isto_id ON inbound_stock_transfers USING btree (inbound_stock_transfer_order_id);


--
-- Name: index_ist_on_site_and_isto_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_ist_on_site_and_isto_id ON inbound_stock_transfers USING btree (site_id, inbound_stock_transfer_order_id);


--
-- Name: index_isti_on_site_and_istp; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_isti_on_site_and_istp ON inbound_stock_transfer_items USING btree (site_id, inbound_stock_transfer_pallet_id);


--
-- Name: index_istoi_on_isto_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_istoi_on_isto_id ON inbound_stock_transfer_order_items USING btree (inbound_stock_transfer_order_id);


--
-- Name: index_istp_on_site_and_ist; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_istp_on_site_and_ist ON inbound_stock_transfer_pallets USING btree (site_id, inbound_stock_transfer_id);


--
-- Name: index_item_types_on_account_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_item_types_on_account_id ON item_types USING btree (account_id);


--
-- Name: index_job_lot_expiries_on_job_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_job_lot_expiries_on_job_id ON job_lot_expiries USING btree (job_id);


--
-- Name: index_job_reconciliation_counts_on_site_id_and_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_job_reconciliation_counts_on_site_id_and_pallet_id ON job_reconciliation_counts USING btree (site_id, pallet_id);


--
-- Name: index_job_reconciliation_records_on_job_reconciliation_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_job_reconciliation_records_on_job_reconciliation_id ON job_reconciliation_records USING btree (job_reconciliation_id);


--
-- Name: index_jobs_for_accounting_sync; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_jobs_for_accounting_sync ON jobs USING btree (site_id, ended_at, synchronized_status);


--
-- Name: index_jobs_on_accepted_by_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_jobs_on_accepted_by_id ON jobs USING btree (accepted_by_id);


--
-- Name: index_jobs_on_ended_at; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_jobs_on_ended_at ON jobs USING btree (ended_at);


--
-- Name: index_jobs_on_line_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_jobs_on_line_id ON jobs USING btree (line_id);


--
-- Name: index_jobs_on_project_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_jobs_on_project_id ON jobs USING btree (project_id);


--
-- Name: index_jobs_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_jobs_on_site_id ON jobs USING btree (site_id);


--
-- Name: index_jobs_on_site_id_and_external_identifier; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_jobs_on_site_id_and_external_identifier ON jobs USING btree (site_id, external_identifier);


--
-- Name: index_jobs_on_site_id_and_project_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_jobs_on_site_id_and_project_id ON jobs USING btree (site_id, project_id);


--
-- Name: index_jobs_on_started_at; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_jobs_on_started_at ON jobs USING btree (started_at);


--
-- Name: index_jobs_on_wip_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_jobs_on_wip_pallet_id ON jobs USING btree (wip_pallet_id);


--
-- Name: index_jrc_on_job_reconciliation_id_and_sku_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_jrc_on_job_reconciliation_id_and_sku_id ON job_reconciliation_counts USING btree (job_reconciliation_id, sku_id);


--
-- Name: index_lines_on_location_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_lines_on_location_id ON lines USING btree (location_id);


--
-- Name: index_lines_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_lines_on_site_id ON lines USING btree (site_id);


--
-- Name: index_lines_on_wip_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_lines_on_wip_pallet_id ON lines USING btree (wip_pallet_id);


--
-- Name: index_locations_on_active; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_locations_on_active ON locations USING btree (active);


--
-- Name: index_locations_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_locations_on_site_id ON locations USING btree (site_id);


--
-- Name: index_moves_on_job_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_moves_on_job_id ON moves USING btree (job_id);


--
-- Name: index_outbound_stock_transfer_pallets_on_site_id_and_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_outbound_stock_transfer_pallets_on_site_id_and_pallet_id ON outbound_stock_transfer_pallets USING btree (site_id, pallet_id);


--
-- Name: index_outbound_stock_transfer_units_on_inventory_adjustment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_outbound_stock_transfer_units_on_inventory_adjustment_id ON outbound_stock_transfer_units USING btree (inventory_adjustment_id);


--
-- Name: index_outbound_trailers_on_site_id_and_bill_of_lading_number; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_outbound_trailers_on_site_id_and_bill_of_lading_number ON outbound_trailers USING btree (site_id, bill_of_lading_number);


--
-- Name: index_pallet_assignments_on_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_pallet_assignments_on_pallet_id ON pallet_assignments USING btree (pallet_id);


--
-- Name: index_pallet_moves_on_move_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_pallet_moves_on_move_id ON pallet_moves USING btree (move_id);


--
-- Name: index_pallet_shipments_on_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_pallet_shipments_on_pallet_id ON pallet_shipments USING btree (pallet_id);


--
-- Name: index_pallet_shipments_on_shipment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_pallet_shipments_on_shipment_id ON pallet_shipments USING btree (shipment_id);


--
-- Name: index_pallets_on_job_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_pallets_on_job_id ON pallets USING btree (job_id);


--
-- Name: index_pallets_on_site_id_and_number; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_pallets_on_site_id_and_number ON pallets USING btree (site_id, number);


--
-- Name: index_pick_list_line_items_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_pick_list_line_items_on_site_id ON pick_list_line_items USING btree (site_id);


--
-- Name: index_pick_list_picks_on_pick_list_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_pick_list_picks_on_pick_list_id ON pick_list_picks USING btree (pick_list_id);


--
-- Name: index_pick_list_unit_picks_on_pick_list_pick_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_pick_list_unit_picks_on_pick_list_pick_id ON drop_off_picks USING btree (pick_list_pick_id);


--
-- Name: index_pick_lists_on_reservable_type; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_pick_lists_on_reservable_type ON pick_lists USING btree (reservable_type);


--
-- Name: index_planned_receipt_items_on_parent_id_and_external_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_planned_receipt_items_on_parent_id_and_external_id ON planned_receipt_items USING btree (planned_receipt_id, external_identifier);


--
-- Name: index_planned_receipts_on_site_id_and_external_identifier; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_planned_receipts_on_site_id_and_external_identifier ON planned_receipts USING btree (site_id, external_identifier);


--
-- Name: index_production_archives_on_archived_record_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_production_archives_on_archived_record_id ON production_archives USING btree (archived_record_id);


--
-- Name: index_productions_on_inventory_adjustment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_productions_on_inventory_adjustment_id ON productions USING btree (inventory_adjustment_id);


--
-- Name: index_productions_on_job_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_productions_on_job_id ON productions USING btree (job_id);


--
-- Name: index_productions_on_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_productions_on_pallet_id ON productions USING btree (pallet_id);


--
-- Name: index_productions_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_productions_on_site_id ON productions USING btree (site_id);


--
-- Name: index_productions_on_site_id_and_job_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_productions_on_site_id_and_job_id ON productions USING btree (site_id, job_id);


--
-- Name: index_productions_on_site_id_and_produced_at; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_productions_on_site_id_and_produced_at ON productions USING btree (site_id, produced_at);


--
-- Name: index_projects_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_projects_on_site_id ON projects USING btree (site_id);


--
-- Name: index_projects_on_site_id_and_external_identifier; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_projects_on_site_id_and_external_identifier ON projects USING btree (site_id, external_identifier);


--
-- Name: index_qb_logs_on_account_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_qb_logs_on_account_id ON qb_logs USING btree (account_id);


--
-- Name: index_quoted_bom_items_on_account_id_and_external_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_quoted_bom_items_on_account_id_and_external_id ON quoted_bom_items USING btree (account_id, external_identifier);


--
-- Name: index_quotes_on_account_id_and_external_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_quotes_on_account_id_and_external_id ON quotes USING btree (account_id, external_identifier);


--
-- Name: index_rack_locations_on_label1; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_rack_locations_on_label1 ON rack_locations USING btree (label1);


--
-- Name: index_rack_locations_on_label2; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_rack_locations_on_label2 ON rack_locations USING btree (label2);


--
-- Name: index_rack_locations_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_rack_locations_on_site_id ON rack_locations USING btree (site_id);


--
-- Name: index_receipt_items_on_inventory_adjustment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_receipt_items_on_inventory_adjustment_id ON receipt_items USING btree (inventory_adjustment_id);


--
-- Name: index_receipt_items_on_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_receipt_items_on_pallet_id ON receipt_items USING btree (pallet_id);


--
-- Name: index_receipt_items_on_parent_id_and_external_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_receipt_items_on_parent_id_and_external_id ON receipt_items USING btree (receipt_id, external_identifier);


--
-- Name: index_receipt_items_on_receipt_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_receipt_items_on_receipt_id ON receipt_items USING btree (receipt_id);


--
-- Name: index_receipt_items_on_receive_order_item_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_receipt_items_on_receive_order_item_id ON receipt_items USING btree (receive_order_item_id);


--
-- Name: index_receipt_items_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_receipt_items_on_site_id ON receipt_items USING btree (site_id);


--
-- Name: index_receipt_items_on_sku_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_receipt_items_on_sku_id ON receipt_items USING btree (sku_id);


--
-- Name: index_receipts_for_accounting_sync; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_receipts_for_accounting_sync ON receipts USING btree (site_id, received_at, synchronized_status);


--
-- Name: index_receipts_on_site_id_and_external_identifier; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_receipts_on_site_id_and_external_identifier ON receipts USING btree (site_id, external_identifier);


--
-- Name: index_receipts_on_site_id_and_planned_receipt_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_receipts_on_site_id_and_planned_receipt_id ON receipts USING btree (site_id, planned_receipt_id);


--
-- Name: index_receive_order_items_on_parent_id_and_external_identifier; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_receive_order_items_on_parent_id_and_external_identifier ON receive_order_items USING btree (receive_order_id, external_identifier);


--
-- Name: index_receive_order_items_on_receive_order_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_receive_order_items_on_receive_order_id ON receive_order_items USING btree (receive_order_id);


--
-- Name: index_receive_order_items_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_receive_order_items_on_site_id ON receive_order_items USING btree (site_id);


--
-- Name: index_receive_orders_on_project_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_receive_orders_on_project_id ON receive_orders USING btree (project_id);


--
-- Name: index_receive_orders_on_received_and_project_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_receive_orders_on_received_and_project_id ON receive_orders USING btree (received, project_id);


--
-- Name: index_receive_orders_on_site_id_and_code; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_receive_orders_on_site_id_and_code ON receive_orders USING btree (site_id, code);


--
-- Name: index_receive_orders_on_site_id_and_external_identifier; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_receive_orders_on_site_id_and_external_identifier ON receive_orders USING btree (site_id, external_identifier);


--
-- Name: index_rejected_item_archives_on_archived_record_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_rejected_item_archives_on_archived_record_id ON rejected_item_archives USING btree (archived_record_id);


--
-- Name: index_rejected_items_on_add_adjustment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_rejected_items_on_add_adjustment_id ON rejected_items USING btree (add_adjustment_id);


--
-- Name: index_rejected_items_on_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_rejected_items_on_pallet_id ON rejected_items USING btree (pallet_id);


--
-- Name: index_rejected_items_on_remove_adjustment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_rejected_items_on_remove_adjustment_id ON rejected_items USING btree (remove_adjustment_id);


--
-- Name: index_rejected_items_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_rejected_items_on_site_id ON rejected_items USING btree (site_id);


--
-- Name: index_rejected_items_on_site_id_and_job_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_rejected_items_on_site_id_and_job_id ON rejected_items USING btree (site_id, job_id);


--
-- Name: index_scenario_charges_on_account_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_scenario_charges_on_account_id ON scenario_charges USING btree (account_id);


--
-- Name: index_scenario_charges_on_account_id_and_external_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_scenario_charges_on_account_id_and_external_id ON scenario_charges USING btree (account_id, external_identifier);


--
-- Name: index_scenarios_on_quote_id_and_external_identifier; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_scenarios_on_quote_id_and_external_identifier ON scenarios USING btree (quote_id, external_identifier);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: index_ship_order_items_on_ship_order_id_and_external_identifier; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_ship_order_items_on_ship_order_id_and_external_identifier ON ship_order_items USING btree (ship_order_id, external_identifier);


--
-- Name: index_ship_order_items_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_ship_order_items_on_site_id ON ship_order_items USING btree (site_id);


--
-- Name: index_ship_orders_on_site_id_and_code; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_ship_orders_on_site_id_and_code ON ship_orders USING btree (site_id, code);


--
-- Name: index_ship_orders_on_site_id_and_external_identifier; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_ship_orders_on_site_id_and_external_identifier ON ship_orders USING btree (site_id, external_identifier);


--
-- Name: index_ship_orders_on_site_id_and_reference_number; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_ship_orders_on_site_id_and_reference_number ON ship_orders USING btree (site_id, reference_number);


--
-- Name: index_shipments_for_accounting_sync; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_shipments_for_accounting_sync ON shipments USING btree (site_id, actual_ship_at, synchronized_status);


--
-- Name: index_shipments_on_site_id_and_bill_of_lading_number; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_shipments_on_site_id_and_bill_of_lading_number ON shipments USING btree (site_id, bill_of_lading_number);


--
-- Name: index_shipments_on_site_id_and_external_identifier; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_shipments_on_site_id_and_external_identifier ON shipments USING btree (site_id, external_identifier);


--
-- Name: index_skus_on_account_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_skus_on_account_id ON skus USING btree (account_id);


--
-- Name: index_skus_on_account_id_and_external_identifier; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX index_skus_on_account_id_and_external_identifier ON skus USING btree (account_id, external_identifier);


--
-- Name: index_subcomponent_consumption_archives_on_archived_record_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_subcomponent_consumption_archives_on_archived_record_id ON subcomponent_consumption_archives USING btree (archived_record_id);


--
-- Name: index_subcomponent_consumptions_on_created_at; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_subcomponent_consumptions_on_created_at ON subcomponent_consumptions USING btree (created_at);


--
-- Name: index_subcomponent_consumptions_on_inventory_adjustment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_subcomponent_consumptions_on_inventory_adjustment_id ON subcomponent_consumptions USING btree (inventory_adjustment_id);


--
-- Name: index_subcomponent_consumptions_on_job_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_subcomponent_consumptions_on_job_id ON subcomponent_consumptions USING btree (job_id);


--
-- Name: index_subcomponent_consumptions_on_production_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_subcomponent_consumptions_on_production_id ON subcomponent_consumptions USING btree (production_id);


--
-- Name: index_subcomponent_consumptions_on_sku_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_subcomponent_consumptions_on_sku_id ON subcomponent_consumptions USING btree (sku_id);


--
-- Name: index_time_reports_on_badge_type_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_time_reports_on_badge_type_id ON time_reports USING btree (badge_type_id);


--
-- Name: index_time_reports_on_job_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_time_reports_on_job_id ON time_reports USING btree (job_id);


--
-- Name: index_time_reports_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_time_reports_on_site_id ON time_reports USING btree (site_id);


--
-- Name: index_time_reports_on_started_at; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_time_reports_on_started_at ON time_reports USING btree (started_at);


--
-- Name: index_unit_moves_on_created_at; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_moves_on_created_at ON unit_moves USING btree (created_at);


--
-- Name: index_unit_moves_on_from_inventory_adjustment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_moves_on_from_inventory_adjustment_id ON unit_moves USING btree (from_inventory_adjustment_id);


--
-- Name: index_unit_moves_on_from_location_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_moves_on_from_location_id ON unit_moves USING btree (from_location_id);


--
-- Name: index_unit_moves_on_from_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_moves_on_from_pallet_id ON unit_moves USING btree (from_pallet_id);


--
-- Name: index_unit_moves_on_lot_code; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_moves_on_lot_code ON unit_moves USING btree (lot_code);


--
-- Name: index_unit_moves_on_move_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_moves_on_move_id ON unit_moves USING btree (move_id);


--
-- Name: index_unit_moves_on_pallet_move_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_moves_on_pallet_move_id ON unit_moves USING btree (pallet_move_id);


--
-- Name: index_unit_moves_on_site_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_moves_on_site_id ON unit_moves USING btree (site_id);


--
-- Name: index_unit_moves_on_sku_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_moves_on_sku_id ON unit_moves USING btree (sku_id);


--
-- Name: index_unit_moves_on_to_inventory_adjustment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_moves_on_to_inventory_adjustment_id ON unit_moves USING btree (to_inventory_adjustment_id);


--
-- Name: index_unit_moves_on_to_location_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_moves_on_to_location_id ON unit_moves USING btree (to_location_id);


--
-- Name: index_unit_moves_on_to_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_moves_on_to_pallet_id ON unit_moves USING btree (to_pallet_id);


--
-- Name: index_unit_of_measures_on_label; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_of_measures_on_label ON unit_of_measures USING btree (label);


--
-- Name: index_unit_of_measures_on_sku_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_of_measures_on_sku_id ON uom_ratios USING btree (dimension_id);


--
-- Name: index_unit_shipments_on_inventory_adjustment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_shipments_on_inventory_adjustment_id ON unit_shipments USING btree (inventory_adjustment_id);


--
-- Name: index_unit_shipments_on_pallet_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_shipments_on_pallet_id ON unit_shipments USING btree (pallet_id);


--
-- Name: index_unit_shipments_on_pallet_shipment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_shipments_on_pallet_shipment_id ON unit_shipments USING btree (pallet_shipment_id);


--
-- Name: index_unit_shipments_on_shipment_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_shipments_on_shipment_id ON unit_shipments USING btree (shipment_id);


--
-- Name: index_unit_shipments_on_site_id_and_sku_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_unit_shipments_on_site_id_and_sku_id ON unit_shipments USING btree (site_id, sku_id);


--
-- Name: index_uom_contexts_on_sku_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_uom_contexts_on_sku_id ON uom_contexts USING btree (sku_id);


--
-- Name: index_users_on_account_id; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX index_users_on_account_id ON users USING btree (account_id);


--
-- Name: scenario_description_search_index; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX scenario_description_search_index ON scenarios USING gin (to_tsvector('simple'::regconfig, description));


--
-- Name: scenario_id_search_index; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX scenario_id_search_index ON scenarios USING gin (to_tsvector('simple'::regconfig, (id)::text));


--
-- Name: scenario_item_description_search_index; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX scenario_item_description_search_index ON scenarios USING gin (to_tsvector('simple'::regconfig, item_description));


--
-- Name: scenario_name_search_index; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE INDEX scenario_name_search_index ON scenarios USING gin (to_tsvector('simple'::regconfig, name));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: nulogy; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: cancel_pick_up_picks_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE cancel_pick_up_picks_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cancel_pick_up_picks_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE cancel_pick_up_picks_id_seq TO nulogy;
GRANT ALL ON SEQUENCE cancel_pick_up_picks_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE cancel_pick_up_picks_id_seq TO readonly;


--
-- Name: consignee_custom_outputs_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE consignee_custom_outputs_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE consignee_custom_outputs_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE consignee_custom_outputs_id_seq TO nulogy;
GRANT ALL ON SEQUENCE consignee_custom_outputs_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE consignee_custom_outputs_id_seq TO readonly;


--
-- Name: deleted_entities_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE deleted_entities_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE deleted_entities_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE deleted_entities_id_seq TO nulogy;
GRANT ALL ON SEQUENCE deleted_entities_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE deleted_entities_id_seq TO readonly;


--
-- Name: gs1_gsin_sequences_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE gs1_gsin_sequences_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE gs1_gsin_sequences_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE gs1_gsin_sequences_id_seq TO nulogy;
GRANT ALL ON SEQUENCE gs1_gsin_sequences_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE gs1_gsin_sequences_id_seq TO readonly;


--
-- Name: imported_inventories_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE imported_inventories_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE imported_inventories_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE imported_inventories_id_seq TO nulogy;
GRANT ALL ON SEQUENCE imported_inventories_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE imported_inventories_id_seq TO readonly;


--
-- Name: inventory_status_configurations_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE inventory_status_configurations_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE inventory_status_configurations_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE inventory_status_configurations_id_seq TO nulogy;
GRANT ALL ON SEQUENCE inventory_status_configurations_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE inventory_status_configurations_id_seq TO readonly;


--
-- Name: inventory_statuses_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE inventory_statuses_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE inventory_statuses_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE inventory_statuses_id_seq TO nulogy;
GRANT ALL ON SEQUENCE inventory_statuses_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE inventory_statuses_id_seq TO readonly;


--
-- Name: licensing_events_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE licensing_events_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE licensing_events_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE licensing_events_id_seq TO nulogy;
GRANT ALL ON SEQUENCE licensing_events_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE licensing_events_id_seq TO readonly;


--
-- Name: pick_up_picks_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE pick_up_picks_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE pick_up_picks_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE pick_up_picks_id_seq TO nulogy;
GRANT ALL ON SEQUENCE pick_up_picks_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE pick_up_picks_id_seq TO readonly;


--
-- Name: reconciliation_reasons_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE reconciliation_reasons_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE reconciliation_reasons_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE reconciliation_reasons_id_seq TO nulogy;
GRANT ALL ON SEQUENCE reconciliation_reasons_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE reconciliation_reasons_id_seq TO readonly;


--
-- Name: scheduling_blocks_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE scheduling_blocks_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE scheduling_blocks_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE scheduling_blocks_id_seq TO nulogy;
GRANT ALL ON SEQUENCE scheduling_blocks_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE scheduling_blocks_id_seq TO readonly;


--
-- Name: scheduling_default_shift_capacities_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE scheduling_default_shift_capacities_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE scheduling_default_shift_capacities_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE scheduling_default_shift_capacities_id_seq TO nulogy;
GRANT ALL ON SEQUENCE scheduling_default_shift_capacities_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE scheduling_default_shift_capacities_id_seq TO readonly;


--
-- Name: scheduling_line_assignments_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE scheduling_line_assignments_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE scheduling_line_assignments_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE scheduling_line_assignments_id_seq TO nulogy;
GRANT ALL ON SEQUENCE scheduling_line_assignments_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE scheduling_line_assignments_id_seq TO readonly;


--
-- Name: scheduling_lines_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE scheduling_lines_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE scheduling_lines_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE scheduling_lines_id_seq TO nulogy;
GRANT ALL ON SEQUENCE scheduling_lines_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE scheduling_lines_id_seq TO readonly;


--
-- Name: scheduling_project_demands_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE scheduling_project_demands_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE scheduling_project_demands_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE scheduling_project_demands_id_seq TO nulogy;
GRANT ALL ON SEQUENCE scheduling_project_demands_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE scheduling_project_demands_id_seq TO readonly;


--
-- Name: scheduling_shifts_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE scheduling_shifts_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE scheduling_shifts_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE scheduling_shifts_id_seq TO nulogy;
GRANT ALL ON SEQUENCE scheduling_shifts_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE scheduling_shifts_id_seq TO readonly;


--
-- Name: site_10_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_10_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_10_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_10_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_10_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_10_bol_number_seq TO readonly;


--
-- Name: site_121_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_121_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_121_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_121_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_121_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_121_bol_number_seq TO readonly;


--
-- Name: site_124_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_124_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_124_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_124_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_124_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_124_bol_number_seq TO readonly;


--
-- Name: site_125_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_125_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_125_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_125_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_125_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_125_bol_number_seq TO readonly;


--
-- Name: site_126_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_126_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_126_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_126_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_126_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_126_bol_number_seq TO readonly;


--
-- Name: site_127_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_127_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_127_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_127_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_127_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_127_bol_number_seq TO readonly;


--
-- Name: site_128_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_128_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_128_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_128_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_128_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_128_bol_number_seq TO readonly;


--
-- Name: site_129_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_129_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_129_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_129_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_129_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_129_bol_number_seq TO readonly;


--
-- Name: site_12_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_12_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_12_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_12_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_12_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_12_bol_number_seq TO readonly;


--
-- Name: site_130_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_130_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_130_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_130_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_130_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_130_bol_number_seq TO readonly;


--
-- Name: site_131_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_131_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_131_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_131_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_131_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_131_bol_number_seq TO readonly;


--
-- Name: site_132_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_132_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_132_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_132_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_132_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_132_bol_number_seq TO readonly;


--
-- Name: site_133_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_133_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_133_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_133_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_133_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_133_bol_number_seq TO readonly;


--
-- Name: site_134_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_134_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_134_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_134_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_134_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_134_bol_number_seq TO readonly;


--
-- Name: site_135_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_135_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_135_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_135_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_135_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_135_bol_number_seq TO readonly;


--
-- Name: site_136_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_136_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_136_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_136_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_136_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_136_bol_number_seq TO readonly;


--
-- Name: site_137_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_137_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_137_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_137_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_137_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_137_bol_number_seq TO readonly;


--
-- Name: site_138_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_138_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_138_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_138_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_138_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_138_bol_number_seq TO readonly;


--
-- Name: site_139_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_139_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_139_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_139_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_139_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_139_bol_number_seq TO readonly;


--
-- Name: site_13_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_13_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_13_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_13_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_13_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_13_bol_number_seq TO readonly;


--
-- Name: site_140_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_140_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_140_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_140_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_140_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_140_bol_number_seq TO readonly;


--
-- Name: site_141_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_141_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_141_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_141_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_141_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_141_bol_number_seq TO readonly;


--
-- Name: site_142_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_142_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_142_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_142_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_142_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_142_bol_number_seq TO readonly;


--
-- Name: site_143_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_143_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_143_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_143_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_143_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_143_bol_number_seq TO readonly;


--
-- Name: site_144_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_144_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_144_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_144_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_144_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_144_bol_number_seq TO readonly;


--
-- Name: site_145_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_145_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_145_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_145_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_145_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_145_bol_number_seq TO readonly;


--
-- Name: site_146_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_146_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_146_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_146_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_146_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_146_bol_number_seq TO readonly;


--
-- Name: site_147_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_147_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_147_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_147_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_147_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_147_bol_number_seq TO readonly;


--
-- Name: site_148_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_148_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_148_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_148_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_148_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_148_bol_number_seq TO readonly;


--
-- Name: site_149_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_149_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_149_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_149_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_149_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_149_bol_number_seq TO readonly;


--
-- Name: site_14_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_14_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_14_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_14_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_14_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_14_bol_number_seq TO readonly;


--
-- Name: site_150_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_150_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_150_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_150_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_150_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_150_bol_number_seq TO readonly;


--
-- Name: site_151_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_151_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_151_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_151_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_151_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_151_bol_number_seq TO readonly;


--
-- Name: site_152_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_152_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_152_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_152_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_152_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_152_bol_number_seq TO readonly;


--
-- Name: site_153_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_153_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_153_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_153_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_153_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_153_bol_number_seq TO readonly;


--
-- Name: site_154_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_154_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_154_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_154_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_154_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_154_bol_number_seq TO readonly;


--
-- Name: site_155_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_155_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_155_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_155_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_155_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_155_bol_number_seq TO readonly;


--
-- Name: site_156_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_156_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_156_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_156_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_156_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_156_bol_number_seq TO readonly;


--
-- Name: site_157_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_157_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_157_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_157_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_157_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_157_bol_number_seq TO readonly;


--
-- Name: site_158_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_158_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_158_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_158_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_158_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_158_bol_number_seq TO readonly;


--
-- Name: site_159_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_159_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_159_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_159_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_159_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_159_bol_number_seq TO readonly;


--
-- Name: site_15_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_15_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_15_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_15_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_15_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_15_bol_number_seq TO readonly;


--
-- Name: site_160_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_160_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_160_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_160_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_160_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_160_bol_number_seq TO readonly;


--
-- Name: site_161_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_161_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_161_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_161_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_161_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_161_bol_number_seq TO readonly;


--
-- Name: site_162_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_162_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_162_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_162_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_162_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_162_bol_number_seq TO readonly;


--
-- Name: site_163_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_163_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_163_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_163_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_163_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_163_bol_number_seq TO readonly;


--
-- Name: site_164_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_164_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_164_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_164_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_164_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_164_bol_number_seq TO readonly;


--
-- Name: site_165_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_165_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_165_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_165_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_165_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_165_bol_number_seq TO readonly;


--
-- Name: site_166_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_166_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_166_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_166_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_166_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_166_bol_number_seq TO readonly;


--
-- Name: site_167_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_167_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_167_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_167_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_167_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_167_bol_number_seq TO readonly;


--
-- Name: site_168_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_168_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_168_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_168_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_168_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_168_bol_number_seq TO readonly;


--
-- Name: site_16_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_16_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_16_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_16_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_16_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_16_bol_number_seq TO readonly;


--
-- Name: site_170_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_170_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_170_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_170_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_170_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_170_bol_number_seq TO readonly;


--
-- Name: site_171_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_171_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_171_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_171_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_171_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_171_bol_number_seq TO readonly;


--
-- Name: site_172_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_172_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_172_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_172_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_172_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_172_bol_number_seq TO readonly;


--
-- Name: site_173_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_173_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_173_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_173_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_173_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_173_bol_number_seq TO readonly;


--
-- Name: site_174_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_174_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_174_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_174_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_174_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_174_bol_number_seq TO readonly;


--
-- Name: site_175_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_175_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_175_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_175_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_175_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_175_bol_number_seq TO readonly;


--
-- Name: site_176_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_176_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_176_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_176_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_176_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_176_bol_number_seq TO readonly;


--
-- Name: site_177_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_177_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_177_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_177_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_177_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_177_bol_number_seq TO readonly;


--
-- Name: site_17_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_17_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_17_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_17_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_17_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_17_bol_number_seq TO readonly;


--
-- Name: site_18_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_18_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_18_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_18_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_18_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_18_bol_number_seq TO readonly;


--
-- Name: site_19_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_19_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_19_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_19_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_19_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_19_bol_number_seq TO readonly;


--
-- Name: site_1_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_1_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_1_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_1_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_1_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_1_bol_number_seq TO readonly;


--
-- Name: site_20_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_20_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_20_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_20_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_20_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_20_bol_number_seq TO readonly;


--
-- Name: site_210_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_210_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_210_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_210_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_210_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_210_bol_number_seq TO readonly;


--
-- Name: site_21_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_21_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_21_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_21_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_21_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_21_bol_number_seq TO readonly;


--
-- Name: site_22_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_22_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_22_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_22_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_22_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_22_bol_number_seq TO readonly;


--
-- Name: site_23_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_23_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_23_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_23_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_23_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_23_bol_number_seq TO readonly;


--
-- Name: site_243_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_243_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_243_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_243_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_243_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_243_bol_number_seq TO readonly;


--
-- Name: site_244_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_244_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_244_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_244_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_244_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_244_bol_number_seq TO readonly;


--
-- Name: site_245_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_245_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_245_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_245_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_245_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_245_bol_number_seq TO readonly;


--
-- Name: site_246_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_246_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_246_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_246_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_246_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_246_bol_number_seq TO readonly;


--
-- Name: site_247_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_247_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_247_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_247_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_247_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_247_bol_number_seq TO readonly;


--
-- Name: site_248_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_248_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_248_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_248_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_248_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_248_bol_number_seq TO readonly;


--
-- Name: site_249_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_249_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_249_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_249_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_249_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_249_bol_number_seq TO readonly;


--
-- Name: site_24_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_24_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_24_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_24_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_24_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_24_bol_number_seq TO readonly;


--
-- Name: site_250_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_250_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_250_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_250_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_250_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_250_bol_number_seq TO readonly;


--
-- Name: site_251_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_251_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_251_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_251_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_251_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_251_bol_number_seq TO readonly;


--
-- Name: site_252_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_252_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_252_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_252_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_252_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_252_bol_number_seq TO readonly;


--
-- Name: site_253_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_253_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_253_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_253_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_253_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_253_bol_number_seq TO readonly;


--
-- Name: site_254_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_254_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_254_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_254_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_254_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_254_bol_number_seq TO readonly;


--
-- Name: site_255_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_255_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_255_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_255_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_255_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_255_bol_number_seq TO readonly;


--
-- Name: site_256_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_256_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_256_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_256_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_256_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_256_bol_number_seq TO readonly;


--
-- Name: site_257_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_257_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_257_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_257_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_257_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_257_bol_number_seq TO readonly;


--
-- Name: site_257_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_257_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_257_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_257_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_257_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_257_pallet_number_seq TO readonly;


--
-- Name: site_258_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_258_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_258_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_258_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_258_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_258_bol_number_seq TO readonly;


--
-- Name: site_258_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_258_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_258_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_258_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_258_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_258_pallet_number_seq TO readonly;


--
-- Name: site_259_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_259_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_259_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_259_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_259_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_259_bol_number_seq TO readonly;


--
-- Name: site_259_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_259_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_259_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_259_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_259_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_259_pallet_number_seq TO readonly;


--
-- Name: site_25_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_25_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_25_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_25_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_25_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_25_bol_number_seq TO readonly;


--
-- Name: site_260_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_260_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_260_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_260_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_260_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_260_bol_number_seq TO readonly;


--
-- Name: site_260_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_260_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_260_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_260_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_260_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_260_pallet_number_seq TO readonly;


--
-- Name: site_261_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_261_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_261_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_261_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_261_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_261_bol_number_seq TO readonly;


--
-- Name: site_261_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_261_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_261_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_261_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_261_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_261_pallet_number_seq TO readonly;


--
-- Name: site_262_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_262_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_262_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_262_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_262_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_262_bol_number_seq TO readonly;


--
-- Name: site_262_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_262_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_262_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_262_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_262_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_262_pallet_number_seq TO readonly;


--
-- Name: site_263_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_263_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_263_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_263_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_263_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_263_bol_number_seq TO readonly;


--
-- Name: site_263_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_263_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_263_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_263_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_263_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_263_pallet_number_seq TO readonly;


--
-- Name: site_264_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_264_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_264_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_264_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_264_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_264_bol_number_seq TO readonly;


--
-- Name: site_264_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_264_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_264_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_264_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_264_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_264_pallet_number_seq TO readonly;


--
-- Name: site_265_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_265_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_265_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_265_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_265_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_265_bol_number_seq TO readonly;


--
-- Name: site_265_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_265_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_265_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_265_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_265_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_265_pallet_number_seq TO readonly;


--
-- Name: site_266_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_266_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_266_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_266_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_266_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_266_bol_number_seq TO readonly;


--
-- Name: site_266_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_266_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_266_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_266_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_266_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_266_pallet_number_seq TO readonly;


--
-- Name: site_267_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_267_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_267_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_267_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_267_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_267_bol_number_seq TO readonly;


--
-- Name: site_267_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_267_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_267_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_267_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_267_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_267_pallet_number_seq TO readonly;


--
-- Name: site_268_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_268_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_268_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_268_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_268_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_268_bol_number_seq TO readonly;


--
-- Name: site_268_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_268_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_268_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_268_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_268_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_268_pallet_number_seq TO readonly;


--
-- Name: site_269_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_269_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_269_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_269_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_269_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_269_bol_number_seq TO readonly;


--
-- Name: site_269_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_269_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_269_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_269_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_269_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_269_pallet_number_seq TO readonly;


--
-- Name: site_26_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_26_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_26_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_26_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_26_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_26_bol_number_seq TO readonly;


--
-- Name: site_270_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_270_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_270_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_270_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_270_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_270_bol_number_seq TO readonly;


--
-- Name: site_270_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_270_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_270_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_270_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_270_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_270_pallet_number_seq TO readonly;


--
-- Name: site_271_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_271_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_271_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_271_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_271_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_271_bol_number_seq TO readonly;


--
-- Name: site_271_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_271_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_271_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_271_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_271_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_271_pallet_number_seq TO readonly;


--
-- Name: site_272_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_272_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_272_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_272_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_272_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_272_bol_number_seq TO readonly;


--
-- Name: site_272_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_272_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_272_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_272_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_272_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_272_pallet_number_seq TO readonly;


--
-- Name: site_273_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_273_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_273_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_273_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_273_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_273_bol_number_seq TO readonly;


--
-- Name: site_273_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_273_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_273_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_273_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_273_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_273_pallet_number_seq TO readonly;


--
-- Name: site_274_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_274_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_274_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_274_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_274_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_274_bol_number_seq TO readonly;


--
-- Name: site_274_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_274_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_274_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_274_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_274_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_274_pallet_number_seq TO readonly;


--
-- Name: site_275_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_275_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_275_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_275_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_275_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_275_bol_number_seq TO readonly;


--
-- Name: site_275_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_275_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_275_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_275_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_275_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_275_pallet_number_seq TO readonly;


--
-- Name: site_276_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_276_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_276_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_276_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_276_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_276_bol_number_seq TO readonly;


--
-- Name: site_276_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_276_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_276_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_276_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_276_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_276_pallet_number_seq TO readonly;


--
-- Name: site_277_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_277_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_277_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_277_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_277_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_277_bol_number_seq TO readonly;


--
-- Name: site_277_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_277_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_277_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_277_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_277_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_277_pallet_number_seq TO readonly;


--
-- Name: site_278_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_278_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_278_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_278_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_278_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_278_bol_number_seq TO readonly;


--
-- Name: site_278_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_278_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_278_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_278_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_278_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_278_pallet_number_seq TO readonly;


--
-- Name: site_279_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_279_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_279_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_279_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_279_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_279_bol_number_seq TO readonly;


--
-- Name: site_279_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_279_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_279_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_279_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_279_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_279_pallet_number_seq TO readonly;


--
-- Name: site_27_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_27_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_27_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_27_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_27_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_27_bol_number_seq TO readonly;


--
-- Name: site_280_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_280_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_280_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_280_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_280_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_280_bol_number_seq TO readonly;


--
-- Name: site_280_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_280_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_280_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_280_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_280_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_280_pallet_number_seq TO readonly;


--
-- Name: site_281_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_281_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_281_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_281_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_281_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_281_bol_number_seq TO readonly;


--
-- Name: site_281_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_281_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_281_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_281_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_281_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_281_pallet_number_seq TO readonly;


--
-- Name: site_282_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_282_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_282_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_282_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_282_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_282_bol_number_seq TO readonly;


--
-- Name: site_282_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_282_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_282_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_282_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_282_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_282_pallet_number_seq TO readonly;


--
-- Name: site_283_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_283_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_283_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_283_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_283_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_283_bol_number_seq TO readonly;


--
-- Name: site_283_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_283_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_283_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_283_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_283_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_283_pallet_number_seq TO readonly;


--
-- Name: site_284_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_284_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_284_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_284_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_284_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_284_bol_number_seq TO readonly;


--
-- Name: site_284_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_284_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_284_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_284_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_284_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_284_pallet_number_seq TO readonly;


--
-- Name: site_285_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_285_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_285_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_285_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_285_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_285_bol_number_seq TO readonly;


--
-- Name: site_285_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_285_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_285_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_285_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_285_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_285_pallet_number_seq TO readonly;


--
-- Name: site_286_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_286_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_286_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_286_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_286_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_286_bol_number_seq TO readonly;


--
-- Name: site_286_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_286_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_286_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_286_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_286_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_286_pallet_number_seq TO readonly;


--
-- Name: site_287_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_287_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_287_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_287_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_287_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_287_bol_number_seq TO readonly;


--
-- Name: site_287_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_287_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_287_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_287_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_287_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_287_pallet_number_seq TO readonly;


--
-- Name: site_28_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_28_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_28_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_28_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_28_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_28_bol_number_seq TO readonly;


--
-- Name: site_29_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_29_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_29_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_29_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_29_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_29_bol_number_seq TO readonly;


--
-- Name: site_2_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_2_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_2_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_2_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_2_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_2_bol_number_seq TO readonly;


--
-- Name: site_30327_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30327_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30327_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30327_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30327_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30327_bol_number_seq TO readonly;


--
-- Name: site_30327_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30327_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30327_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30327_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30327_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30327_pallet_number_seq TO readonly;


--
-- Name: site_30329_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30329_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30329_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30329_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30329_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30329_bol_number_seq TO readonly;


--
-- Name: site_30329_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30329_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30329_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30329_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30329_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30329_pallet_number_seq TO readonly;


--
-- Name: site_30330_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30330_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30330_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30330_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30330_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30330_bol_number_seq TO readonly;


--
-- Name: site_30330_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30330_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30330_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30330_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30330_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30330_pallet_number_seq TO readonly;


--
-- Name: site_30332_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30332_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30332_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30332_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30332_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30332_bol_number_seq TO readonly;


--
-- Name: site_30332_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30332_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30332_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30332_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30332_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30332_pallet_number_seq TO readonly;


--
-- Name: site_30335_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30335_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30335_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30335_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30335_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30335_bol_number_seq TO readonly;


--
-- Name: site_30335_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30335_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30335_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30335_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30335_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30335_pallet_number_seq TO readonly;


--
-- Name: site_30336_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30336_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30336_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30336_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30336_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30336_bol_number_seq TO readonly;


--
-- Name: site_30336_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30336_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30336_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30336_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30336_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30336_pallet_number_seq TO readonly;


--
-- Name: site_30337_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30337_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30337_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30337_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30337_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30337_bol_number_seq TO readonly;


--
-- Name: site_30337_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30337_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30337_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30337_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30337_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30337_pallet_number_seq TO readonly;


--
-- Name: site_30338_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30338_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30338_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30338_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30338_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30338_bol_number_seq TO readonly;


--
-- Name: site_30338_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30338_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30338_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30338_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30338_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30338_pallet_number_seq TO readonly;


--
-- Name: site_30341_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30341_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30341_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30341_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30341_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30341_bol_number_seq TO readonly;


--
-- Name: site_30341_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30341_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30341_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30341_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30341_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30341_pallet_number_seq TO readonly;


--
-- Name: site_30342_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30342_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30342_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30342_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30342_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30342_bol_number_seq TO readonly;


--
-- Name: site_30342_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30342_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30342_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30342_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30342_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30342_pallet_number_seq TO readonly;


--
-- Name: site_30344_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30344_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30344_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30344_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30344_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30344_bol_number_seq TO readonly;


--
-- Name: site_30344_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30344_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30344_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30344_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30344_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30344_pallet_number_seq TO readonly;


--
-- Name: site_30346_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30346_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30346_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30346_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30346_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30346_bol_number_seq TO readonly;


--
-- Name: site_30346_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30346_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30346_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30346_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30346_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30346_pallet_number_seq TO readonly;


--
-- Name: site_30347_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30347_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30347_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30347_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30347_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30347_bol_number_seq TO readonly;


--
-- Name: site_30347_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30347_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30347_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30347_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30347_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30347_pallet_number_seq TO readonly;


--
-- Name: site_30352_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30352_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30352_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30352_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30352_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30352_bol_number_seq TO readonly;


--
-- Name: site_30352_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30352_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30352_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30352_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30352_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30352_pallet_number_seq TO readonly;


--
-- Name: site_30385_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30385_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30385_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30385_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30385_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30385_bol_number_seq TO readonly;


--
-- Name: site_30385_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30385_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30385_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30385_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30385_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30385_pallet_number_seq TO readonly;


--
-- Name: site_30386_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30386_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30386_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30386_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30386_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30386_bol_number_seq TO readonly;


--
-- Name: site_30386_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30386_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30386_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30386_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30386_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30386_pallet_number_seq TO readonly;


--
-- Name: site_30387_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30387_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30387_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30387_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30387_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30387_bol_number_seq TO readonly;


--
-- Name: site_30387_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30387_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30387_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30387_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30387_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30387_pallet_number_seq TO readonly;


--
-- Name: site_30388_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30388_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30388_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30388_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30388_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30388_bol_number_seq TO readonly;


--
-- Name: site_30388_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30388_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30388_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30388_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30388_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30388_pallet_number_seq TO readonly;


--
-- Name: site_30389_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30389_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30389_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30389_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30389_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30389_bol_number_seq TO readonly;


--
-- Name: site_30389_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30389_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30389_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30389_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30389_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30389_pallet_number_seq TO readonly;


--
-- Name: site_30390_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30390_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30390_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30390_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30390_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30390_bol_number_seq TO readonly;


--
-- Name: site_30390_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30390_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30390_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30390_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30390_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30390_pallet_number_seq TO readonly;


--
-- Name: site_30391_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30391_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30391_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30391_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30391_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30391_bol_number_seq TO readonly;


--
-- Name: site_30391_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30391_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30391_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30391_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30391_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30391_pallet_number_seq TO readonly;


--
-- Name: site_30_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_30_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_30_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_30_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_30_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_30_bol_number_seq TO readonly;


--
-- Name: site_319_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_319_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_319_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_319_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_319_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_319_bol_number_seq TO readonly;


--
-- Name: site_319_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_319_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_319_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_319_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_319_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_319_pallet_number_seq TO readonly;


--
-- Name: site_31_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_31_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_31_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_31_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_31_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_31_bol_number_seq TO readonly;


--
-- Name: site_320_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_320_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_320_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_320_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_320_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_320_bol_number_seq TO readonly;


--
-- Name: site_320_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_320_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_320_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_320_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_320_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_320_pallet_number_seq TO readonly;


--
-- Name: site_322_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_322_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_322_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_322_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_322_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_322_bol_number_seq TO readonly;


--
-- Name: site_322_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_322_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_322_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_322_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_322_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_322_pallet_number_seq TO readonly;


--
-- Name: site_323_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_323_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_323_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_323_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_323_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_323_bol_number_seq TO readonly;


--
-- Name: site_323_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_323_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_323_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_323_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_323_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_323_pallet_number_seq TO readonly;


--
-- Name: site_324_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_324_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_324_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_324_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_324_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_324_bol_number_seq TO readonly;


--
-- Name: site_324_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_324_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_324_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_324_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_324_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_324_pallet_number_seq TO readonly;


--
-- Name: site_325_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_325_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_325_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_325_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_325_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_325_bol_number_seq TO readonly;


--
-- Name: site_325_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_325_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_325_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_325_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_325_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_325_pallet_number_seq TO readonly;


--
-- Name: site_326_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_326_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_326_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_326_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_326_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_326_bol_number_seq TO readonly;


--
-- Name: site_326_pallet_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_326_pallet_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_326_pallet_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_326_pallet_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_326_pallet_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_326_pallet_number_seq TO readonly;


--
-- Name: site_32_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_32_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_32_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_32_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_32_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_32_bol_number_seq TO readonly;


--
-- Name: site_33_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_33_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_33_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_33_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_33_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_33_bol_number_seq TO readonly;


--
-- Name: site_34_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_34_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_34_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_34_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_34_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_34_bol_number_seq TO readonly;


--
-- Name: site_35_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_35_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_35_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_35_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_35_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_35_bol_number_seq TO readonly;


--
-- Name: site_36_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_36_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_36_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_36_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_36_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_36_bol_number_seq TO readonly;


--
-- Name: site_37_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_37_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_37_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_37_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_37_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_37_bol_number_seq TO readonly;


--
-- Name: site_38_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_38_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_38_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_38_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_38_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_38_bol_number_seq TO readonly;


--
-- Name: site_39_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_39_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_39_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_39_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_39_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_39_bol_number_seq TO readonly;


--
-- Name: site_3_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_3_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_3_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_3_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_3_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_3_bol_number_seq TO readonly;


--
-- Name: site_40_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_40_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_40_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_40_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_40_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_40_bol_number_seq TO readonly;


--
-- Name: site_41_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_41_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_41_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_41_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_41_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_41_bol_number_seq TO readonly;


--
-- Name: site_42_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_42_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_42_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_42_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_42_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_42_bol_number_seq TO readonly;


--
-- Name: site_43_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_43_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_43_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_43_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_43_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_43_bol_number_seq TO readonly;


--
-- Name: site_44_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_44_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_44_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_44_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_44_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_44_bol_number_seq TO readonly;


--
-- Name: site_45_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_45_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_45_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_45_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_45_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_45_bol_number_seq TO readonly;


--
-- Name: site_46_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_46_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_46_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_46_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_46_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_46_bol_number_seq TO readonly;


--
-- Name: site_47_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_47_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_47_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_47_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_47_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_47_bol_number_seq TO readonly;


--
-- Name: site_48_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_48_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_48_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_48_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_48_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_48_bol_number_seq TO readonly;


--
-- Name: site_49_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_49_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_49_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_49_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_49_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_49_bol_number_seq TO readonly;


--
-- Name: site_4_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_4_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_4_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_4_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_4_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_4_bol_number_seq TO readonly;


--
-- Name: site_50_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_50_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_50_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_50_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_50_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_50_bol_number_seq TO readonly;


--
-- Name: site_51_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_51_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_51_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_51_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_51_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_51_bol_number_seq TO readonly;


--
-- Name: site_52_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_52_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_52_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_52_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_52_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_52_bol_number_seq TO readonly;


--
-- Name: site_53_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_53_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_53_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_53_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_53_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_53_bol_number_seq TO readonly;


--
-- Name: site_54_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_54_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_54_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_54_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_54_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_54_bol_number_seq TO readonly;


--
-- Name: site_55_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_55_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_55_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_55_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_55_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_55_bol_number_seq TO readonly;


--
-- Name: site_56_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_56_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_56_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_56_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_56_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_56_bol_number_seq TO readonly;


--
-- Name: site_57_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_57_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_57_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_57_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_57_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_57_bol_number_seq TO readonly;


--
-- Name: site_58_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_58_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_58_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_58_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_58_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_58_bol_number_seq TO readonly;


--
-- Name: site_59_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_59_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_59_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_59_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_59_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_59_bol_number_seq TO readonly;


--
-- Name: site_5_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_5_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_5_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_5_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_5_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_5_bol_number_seq TO readonly;


--
-- Name: site_60_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_60_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_60_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_60_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_60_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_60_bol_number_seq TO readonly;


--
-- Name: site_61_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_61_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_61_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_61_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_61_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_61_bol_number_seq TO readonly;


--
-- Name: site_62_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_62_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_62_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_62_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_62_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_62_bol_number_seq TO readonly;


--
-- Name: site_63_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_63_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_63_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_63_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_63_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_63_bol_number_seq TO readonly;


--
-- Name: site_66_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_66_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_66_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_66_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_66_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_66_bol_number_seq TO readonly;


--
-- Name: site_67_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_67_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_67_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_67_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_67_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_67_bol_number_seq TO readonly;


--
-- Name: site_68_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_68_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_68_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_68_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_68_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_68_bol_number_seq TO readonly;


--
-- Name: site_69_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_69_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_69_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_69_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_69_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_69_bol_number_seq TO readonly;


--
-- Name: site_6_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_6_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_6_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_6_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_6_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_6_bol_number_seq TO readonly;


--
-- Name: site_70_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_70_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_70_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_70_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_70_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_70_bol_number_seq TO readonly;


--
-- Name: site_71_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_71_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_71_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_71_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_71_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_71_bol_number_seq TO readonly;


--
-- Name: site_73_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_73_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_73_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_73_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_73_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_73_bol_number_seq TO readonly;


--
-- Name: site_7_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_7_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_7_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_7_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_7_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_7_bol_number_seq TO readonly;


--
-- Name: site_8_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_8_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_8_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_8_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_8_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_8_bol_number_seq TO readonly;


--
-- Name: site_9_bol_number_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE site_9_bol_number_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE site_9_bol_number_seq FROM nulogy;
GRANT ALL ON SEQUENCE site_9_bol_number_seq TO nulogy;
GRANT ALL ON SEQUENCE site_9_bol_number_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE site_9_bol_number_seq TO readonly;


--
-- Name: trailer_background_shipments_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE trailer_background_shipments_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE trailer_background_shipments_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE trailer_background_shipments_id_seq TO nulogy;
GRANT ALL ON SEQUENCE trailer_background_shipments_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE trailer_background_shipments_id_seq TO readonly;


--
-- Name: unit_of_measures_id_seq; Type: ACL; Schema: public; Owner: nulogy
--

REVOKE ALL ON SEQUENCE unit_of_measures_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE unit_of_measures_id_seq FROM nulogy;
GRANT ALL ON SEQUENCE unit_of_measures_id_seq TO nulogy;
GRANT ALL ON SEQUENCE unit_of_measures_id_seq TO nulogy_db;
GRANT SELECT ON SEQUENCE unit_of_measures_id_seq TO readonly;


--
-- PostgreSQL database dump complete
--

