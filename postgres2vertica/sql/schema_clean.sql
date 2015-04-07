CREATE TABLE accounts (
    id integer NOT NULL,
    name varchar(4096),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unit_of_weight varchar(4096) DEFAULT 'lb'::varchar,
    estimating_library boolean DEFAULT false,
    use_reject_reasons varchar(4096) DEFAULT 'not_enabled'::character varying,
    quickbooks boolean DEFAULT false NOT NULL,
    income_gl_account_id integer,
    cogs_gl_account_id integer,
    applied_labour_gl_account_id integer,
    inventory_adjustment_expense_gl_account_id integer,
    finished_good_asset_gl_account_id integer,
    raw_materials_asset_gl_account_id integer,
    non_production_labour_gl_account_id integer,
    netsuite boolean DEFAULT false NOT NULL,
    netsuite_email varchar(4096),
    netsuite_account varchar(4096),
    netsuite_password varchar(4096),
    project_code_unique boolean DEFAULT true,
    default_performance_level numeric(16,5) DEFAULT 1,
    use_project_charges boolean DEFAULT false,
    labour_default_markup_value numeric(16,5) DEFAULT 0.0,
    labour_default_markup_type varchar(4096) DEFAULT 'per unit'::character varying,
    materials_default_markup_value numeric(16,5) DEFAULT 0.0,
    materials_default_markup_type varchar(4096) DEFAULT 'per unit'::character varying,
    overhead_default_markup_value numeric(16,5) DEFAULT 0.0,
    overhead_default_markup_type varchar(4096) DEFAULT 'per unit'::character varying,
    subcomponent_estimate_default_update varchar(4096) DEFAULT 'all values'::character varying,
    mobile_menu_key varchar(4096) DEFAULT '42'::character varying,
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
    locale varchar(4096) DEFAULT 'en_US'::character varying NOT NULL,
    partitioned boolean DEFAULT false NOT NULL,
    file_export_delimiter varchar(4096) DEFAULT ','::varchar NOT NULL,
    file_export_encoding varchar(4096) DEFAULT 'UTF-8'::varchar NOT NULL,
    mobile_packmanager character varying(255) DEFAULT 'off'::character varying,
    default_customer_product_code_to_item_code boolean DEFAULT true NOT NULL,
    restrict_item_modification_when_producing boolean DEFAULT true,
    background_task_rate_limit integer DEFAULT 1,
    group_shipment_by_po boolean DEFAULT false,
    enable_custom_uoms boolean DEFAULT false,
    allow_manual_recording_of_consumption boolean DEFAULT false NOT NULL,
    estimate_and_scenario_name_unique boolean DEFAULT true NOT NULL
);
CREATE TABLE allowed_accounts (
    id integer NOT NULL,
    account_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE allowed_sites (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    user_id integer
);
CREATE TABLE announcements (
    id integer NOT NULL,
    title varchar(4096),
    message varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    posted_at timestamp without time zone,
    sticky boolean DEFAULT false,
    expiry_date_at timestamp without time zone
);
CREATE TABLE application_configurations (
    id integer NOT NULL,
    log_activity boolean DEFAULT true,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    statement_timeout varchar(4096) DEFAULT '1min'::character varying NOT NULL,
    identity_map_enabled boolean DEFAULT true,
    enforce_per_page boolean DEFAULT false,
    notification_polling_interval integer DEFAULT 0,
    event_handling_option varchar(4096) DEFAULT 'transmit'::varchar,
    background_shipping_limit integer,
    use_new_production_focus_page boolean DEFAULT true,
    xml_api_identity_map_enabled boolean DEFAULT true NOT NULL
);
CREATE TABLE assembly_item_templates (
    id integer NOT NULL,
    name varchar(4096),
    description varchar(4096),
    people numeric(16,5) DEFAULT 1.0,
    seconds numeric(16,5) DEFAULT 0.0,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tid varchar(4096)
);
CREATE TABLE assembly_steps (
    id integer NOT NULL,
    name varchar(4096),
    description varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    assembly_procedure_id integer,
    "position" integer,
    people numeric(16,5) DEFAULT 1,
    seconds numeric(16,5) DEFAULT 0,
    repetitions_per_unit_value numeric(16,5) DEFAULT 1.0,
    suggested_people numeric(16,5) DEFAULT 0,
    assembly_item_template_id integer,
    item_code varchar(4096),
    account_id integer NOT NULL,
    "group" integer,
    repetitions_per_unit varchar(4096)
);
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
CREATE TABLE background_report_results (
    id integer NOT NULL,
    background_task_id integer,
    user_id integer,
    data varchar(4096),
    urls varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    metadata varchar(4096)
);
CREATE TABLE background_tasks (
    id integer NOT NULL,
    name varchar(4096),
    result varchar(4096),
    user_id integer,
    run_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    status integer DEFAULT 5 NOT NULL,
    account_id integer,
    scheduled_at timestamp without time zone,
    action_class_name varchar(4096),
    action_args varchar(4096),
    action_errors varchar(4096),
    site_id integer,
    company_id integer,
    task_type varchar(4096),
    completed_at timestamp without time zone,
    queued_at timestamp without time zone,
    lock_version integer DEFAULT 0
);
CREATE TABLE badge_types (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    prefix varchar(4096),
    name varchar(4096),
    machine boolean DEFAULT false,
    site_id integer,
    rate numeric(16,5) DEFAULT 0.0,
    inactive boolean DEFAULT false
);
CREATE TABLE barcode_configurations (
    id integer NOT NULL,
    account_id integer,
    customer_id integer,
    segment_delimiter varchar(4096),
    barcode_terminator varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE barcode_segments (
    id integer NOT NULL,
    account_id integer,
    barcode_configuration_id integer,
    application_identifier varchar(4096),
    length integer,
    packmanager_field varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    fixed boolean DEFAULT false,
    editable boolean DEFAULT true NOT NULL,
    field_type character varying(255) DEFAULT 'string'::character varying
);
CREATE TABLE bc_snapshot_items (
    id integer NOT NULL,
    site_id integer,
    location_id integer,
    pallet_id integer,
    sku_id integer,
    blind_count_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    base_quantity numeric(16,5) DEFAULT 0.0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    blind_count_row_id integer,
    inventory_status_id integer
);
CREATE TABLE blind_count_items (
    id integer NOT NULL,
    blind_count_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
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
CREATE TABLE blind_counts (
    id integer NOT NULL,
    location_id integer,
    notes varchar(4096),
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
    external_identifier varchar(4096),
    subcomponent_unit_quantity numeric(16,5) NOT NULL,
    subcomponent_uom_id integer NOT NULL,
    finished_good_unit_quantity numeric(16,5) NOT NULL,
    finished_good_uom_id integer NOT NULL
);
CREATE TABLE bookmark_users (
    id integer NOT NULL,
    site_id integer NOT NULL,
    user_id integer,
    bookmark_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE bookmarks (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    name varchar(4096),
    role_access varchar(4096),
    financial_access varchar(4096) DEFAULT 'none'::varchar,
    url varchar(4096),
    account_id integer
);
CREATE TABLE breaks (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    started_at timestamp without time zone,
    ended_at timestamp without time zone,
    job_id integer,
    site_id integer NOT NULL,
    notes varchar(4096),
    downtime_reason_id integer
);
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
    lot_code varchar(4096),
    expiry_date varchar(4096),
    source_pallet_id integer,
    destination_pallet_id integer,
    source_location_id integer,
    destination_location_id integer,
    inventory_status_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
CREATE TABLE carriers (
    id integer NOT NULL,
    code varchar(4096),
    name varchar(4096),
    contact varchar(4096),
    phone varchar(4096),
    email varchar(4096),
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    qb_list_id varchar(4096),
    qb_last_sync_at timestamp without time zone,
    carrier_type varchar(4096)
);
CREATE TABLE cc_historical_items (
    id integer NOT NULL,
    cycle_count_item_id integer,
    location_id integer,
    pallet_id integer,
    sku_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    unit_quantity numeric(16,5) DEFAULT 0,
    old_each_quantity numeric(16,5) DEFAULT 0,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    inventory_status_id integer,
    unit_uom_id integer,
    inventory_base_quantity_snapshot numeric(16,5)
);
CREATE TABLE companies (
    id integer NOT NULL,
    name varchar(4096),
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    partitioned boolean DEFAULT false NOT NULL
);
CREATE TABLE company_locales (
    id integer NOT NULL,
    company_id integer,
    locale varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE consignee_custom_outputs (
    id integer NOT NULL,
    consignee_id integer,
    custom_output_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    site_id integer
);
CREATE TABLE consignees (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name varchar(4096),
    address varchar(4096),
    city varchar(4096),
    province varchar(4096),
    postal_code varchar(4096),
    code varchar(4096),
    phone varchar(4096),
    attention varchar(4096),
    country varchar(4096),
    address_2 varchar(4096),
    site_id integer,
    facility_number varchar(4096),
    external_identifier character varying(255)
);
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
CREATE TABLE current_inventory_levels (
    id integer NOT NULL,
    site_id integer,
    location_id integer,
    pallet_id integer,
    sku_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    lock_version integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    expires_on date,
    held_for_id integer,
    held_for_class varchar(4096),
    base_quantity numeric(16,5) DEFAULT 0.0,
    inventory_status_id integer
);
CREATE TABLE custom_charge_settings (
    id integer NOT NULL,
    account_id integer,
    name varchar(4096),
    default_percentage numeric(16,5) DEFAULT 0.0,
    default_source varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    default_markup numeric(16,5) DEFAULT 0.0,
    default_markup_type varchar(4096),
    enabled boolean DEFAULT true
);
CREATE TABLE custom_fields (
    id integer NOT NULL,
    name varchar(4096),
    identifier varchar(4096),
    enabled boolean DEFAULT false,
    account_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    field_type varchar(4096),
    index integer,
    site_id integer
);
CREATE TABLE custom_output_attachments (
    id integer NOT NULL,
    size integer,
    content_type varchar(4096),
    document varchar(4096),
    description varchar(4096),
    custom_output_id integer,
    site_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
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
CREATE TABLE custom_outputs (
    id integer NOT NULL,
    name varchar(4096),
    preview_id character varying(255),
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT false,
    parameters varchar(4096),
    prince boolean DEFAULT true NOT NULL,
    content varchar(4096),
    output_type varchar(4096)
);
CREATE TABLE custom_per_unit_charges (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name varchar(4096),
    scenario_charge_id integer,
    account_id integer,
    cost_per_unit numeric(16,5) DEFAULT 0.0,
    charge_per_unit numeric(16,5) DEFAULT 0.0,
    markup_per_unit numeric(16,5) DEFAULT 0.0,
    markup_percentage numeric(16,5) DEFAULT 0.0,
    percentage numeric(16,5) DEFAULT 0.0,
    source varchar(4096),
    markup_type varchar(4096)
);
CREATE TABLE custom_project_field_values (
    id integer NOT NULL,
    description varchar(4096),
    custom_project_field_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer
);
CREATE TABLE custom_project_fields (
    id integer NOT NULL,
    label varchar(4096) DEFAULT 'Custom Project Field'::character varying,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
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
CREATE TABLE customers (
    id integer NOT NULL,
    name varchar(4096),
    description varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer,
    billing_address varchar(4096),
    code varchar(4096),
    qb_list_id varchar(4096),
    qb_last_sync_at timestamp without time zone,
    netsuite_id varchar(4096),
    netsuite_last_sync_at timestamp without time zone,
    inactive boolean DEFAULT false,
    shipment_notes varchar(4096),
    reference varchar(4096),
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
CREATE TABLE cycle_count_items (
    id integer NOT NULL,
    reference_id integer,
    location_id integer,
    pallet_id integer,
    sku_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
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
CREATE TABLE cycle_counts (
    id integer NOT NULL,
    performed_at timestamp without time zone,
    counted_by_id integer,
    status integer DEFAULT 1 NOT NULL,
    notes varchar(4096),
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    total_units numeric(16,5) DEFAULT 0.0,
    sign_off_user_id integer,
    closed_at timestamp without time zone,
    qb_txn_id varchar(4096),
    synchronized_status varchar(4096),
    qb_last_sync_at timestamp without time zone,
    frozen_units_changed numeric(16,5),
    frozen_value_changed numeric(16,5),
    frozen_accuracy numeric(16,5)
);
CREATE TABLE deleted_entities (
    id integer NOT NULL,
    entity_type varchar(4096),
    entity_id integer,
    deleted_at timestamp without time zone,
    account_id integer,
    site_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
CREATE TABLE discrepancy_reasons (
    id integer NOT NULL,
    code varchar(4096),
    reason varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer
);
CREATE TABLE dock_appointments (
    id integer NOT NULL,
    site_id integer,
    external_identifier varchar(4096),
    customer_id integer,
    bill_to varchar(4096),
    bill_to_address varchar(4096),
    carrier_name varchar(4096),
    carrier_code varchar(4096),
    carrier_type varchar(4096),
    carrier_contact varchar(4096),
    carrier_phone varchar(4096),
    bill_of_lading_number bigint,
    tracking_number varchar(4096),
    freight_charge_amount numeric,
    freight_charge_terms varchar(4096),
    expected_ship_at timestamp without time zone,
    ship_from_phone varchar(4096),
    ship_from varchar(4096),
    internal_notes varchar(4096),
    expected_arrival_at timestamp without time zone,
    min_temperature numeric,
    min_temperature_unit varchar(4096),
    max_temperature numeric,
    max_temperature_unit varchar(4096),
    reference_1 varchar(4096),
    reference_2 varchar(4096),
    reference_3 varchar(4096),
    integration_reference_1 varchar(4096),
    integration_reference_2 varchar(4096),
    outbound_trailer_route_id integer NOT NULL,
    trailer_length numeric,
    trailer_length_unit varchar(4096),
    equipment_type varchar(4096),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    outbound_trailer_id integer,
    cancelled boolean DEFAULT false NOT NULL,
    staging_location_id integer
);
CREATE TABLE downtime_reasons (
    id integer NOT NULL,
    code varchar(4096),
    name varchar(4096),
    description varchar(4096),
    paid boolean DEFAULT false NOT NULL,
    planned boolean DEFAULT false NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    site_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
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
CREATE TABLE edi_configurations (
    id integer NOT NULL,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    destination_url_for_outbound_944 varchar(4096),
    destination_url_for_outbound_850 varchar(4096),
    ca_certificate_for_outbound_850_file varchar(4096),
    ca_certificate_for_outbound_944_file varchar(4096),
    ca_certificate_for_outbound_944_data varchar(4096),
    ca_certificate_for_outbound_850_data varchar(4096),
    edi_workflow_mcl_conagra boolean DEFAULT false NOT NULL,
    edi_workflow_exel_clorox boolean DEFAULT false NOT NULL,
    edi_workflow_belvika_hershey boolean DEFAULT false NOT NULL,
    edi_workflow_strive_kraft boolean DEFAULT false,
    edi_workflow_exel_standard boolean DEFAULT false NOT NULL
);
CREATE TABLE edi_customer_triggers (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    customer_id integer,
    site_id integer,
    edi_class varchar(4096),
    scheduled_846_task_id integer,
    destination_url varchar(4096)
);
CREATE TABLE edi_inbounds (
    id integer NOT NULL,
    type varchar(4096),
    request_xml varchar(4096),
    site_id integer,
    object_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    details varchar(4096),
    status integer DEFAULT 0
);
CREATE TABLE edi_logs (
    id integer NOT NULL,
    edi_type varchar(4096),
    edi_id integer,
    reference_1 varchar(4096),
    sent_at timestamp without time zone,
    sku_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    transaction_type varchar(4096),
    unit_quantity numeric(16,5),
    unit_of_measure varchar(4096),
    site_id integer,
    edi_class varchar(4096),
    reference_2 varchar(4096),
    reference_3 varchar(4096)
);
CREATE TABLE edi_mapping_items (
    id integer NOT NULL,
    edi_mapping_id integer,
    sku_id integer,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE edi_mappings (
    id integer NOT NULL,
    customer_product_code varchar(4096),
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    default_inbound_item_id integer
);
CREATE TABLE edi_outbounds (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    sent_at timestamp without time zone,
    status integer DEFAULT 4,
    site_id integer,
    payload varchar(4096),
    type varchar(4096),
    source_id integer,
    source_type varchar(4096),
    source_occurred_at timestamp without time zone,
    customer_id integer,
    error_messages varchar(4096)
);
CREATE TABLE edi_skip_locations (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    location_id integer,
    customer_id integer,
    site_id integer
);
CREATE TABLE edi_status_locations (
    id integer NOT NULL,
    customer_id integer,
    site_id integer,
    edi_status varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    location_id integer,
    edi_location varchar(4096)
);
CREATE TABLE email_domains (
    id integer NOT NULL,
    domain varchar(4096),
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE events (
    id integer NOT NULL,
    event_uid varchar(4096),
    content varchar(4096),
    tenant varchar(4096),
    event_type varchar(4096),
    site_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    processed boolean DEFAULT false NOT NULL
);
CREATE TABLE expected_order_on_dock_appointments (
    id integer NOT NULL,
    site_id integer NOT NULL,
    dock_appointment_id integer NOT NULL,
    ship_order_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
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
CREATE TABLE expected_unit_moves (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    from_pallet_id integer,
    to_pallet_id integer,
    to_location_id integer,
    sku_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
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
CREATE TABLE expiry_date_formats (
    id integer NOT NULL,
    output_format_string varchar(4096),
    user_format_guide varchar(4096),
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    input_format_string varchar(4096)
);
CREATE TABLE external_inventory_levels (
    id integer NOT NULL,
    site_id integer,
    sku_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    unit_quantity numeric(16,5) DEFAULT 0.0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    external_inventory_location_id integer,
    unit_uom_id integer
);
CREATE TABLE external_inventory_locations (
    id integer NOT NULL,
    site_id integer,
    external_identifier character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
CREATE TABLE floor_locations (
    id integer NOT NULL,
    location_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description varchar(4096),
    inbound boolean DEFAULT false,
    outbound boolean DEFAULT false,
    site_id integer
);
CREATE TABLE gl_accounts (
    id integer NOT NULL,
    list_id varchar(4096),
    full_name varchar(4096),
    account_type varchar(4096),
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
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
CREATE TABLE item_shelf_lives (
    id integer NOT NULL,
    account_id integer,
    customer_id integer,
    label varchar(4096),
    shelf_life integer,
    unit varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE icg_reference_data_fields (
    id integer NOT NULL,
    reference_data_table_id integer,
    field_name varchar(4096),
    length integer,
    required boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    custom boolean DEFAULT true,
    account_id integer
);
CREATE TABLE icg_reference_data_rows (
    id integer NOT NULL,
    key varchar(4096),
    reference_data_table_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    data varchar(4096),
    account_id integer
);
CREATE TABLE icg_reference_data_tables (
    id integer NOT NULL,
    customer_id integer,
    table_name varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    editable boolean DEFAULT true,
    key_type varchar(4096) DEFAULT 'string'::character varying,
    account_id integer
);
CREATE TABLE icg_rule_fragments (
    id integer NOT NULL,
    rule_id integer,
    name varchar(4096),
    data_type varchar(4096),
    reference_table varchar(4096),
    reference_field_name varchar(4096),
    "from" integer,
    "to" integer,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    use_for_interpretation boolean DEFAULT false NOT NULL,
    driver varchar(4096)
);
CREATE TABLE icg_rules (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name varchar(4096),
    description varchar(4096),
    type varchar(4096),
    customer_id integer,
    account_id integer,
    lot_code_length integer DEFAULT 0,
    state_name varchar(4096),
    shelf_life_strategy varchar(4096),
    operation varchar(4096),
    date_rounding_field varchar(4096)
);
CREATE TABLE imported_inventories (
    id integer NOT NULL,
    xml_data varchar(4096),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id integer NOT NULL
);
CREATE TABLE inbound_stock_transfer_items (
    id integer NOT NULL,
    site_id integer,
    sku_id integer,
    inventory_adjustment_id integer,
    location_id integer,
    unit_quantity numeric(16,5) DEFAULT 0,
    old_each_quantity numeric(16,5) DEFAULT 0,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    inbound_stock_transfer_pallet_id integer,
    external_identifier varchar(4096),
    inventory_status_id integer,
    unit_uom_id integer
);
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
    pre_rounded_uom_code varchar(4096),
    notes varchar(4096),
    lot_code character varying(255),
    expiry_date character varying(255),
    unit_uom_id integer
);
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
    reference varchar(4096),
    created_by varchar(4096),
    status varchar(4096) DEFAULT 'new'::varchar,
    unit_uom_id integer
);
CREATE TABLE inbound_stock_transfer_pallets (
    id integer NOT NULL,
    inbound_stock_transfer_id integer,
    pallet_id integer,
    site_id integer,
    transferred_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    transfer_status varchar(4096),
    external_identifier varchar(4096)
);
CREATE TABLE inbound_stock_transfers (
    id integer NOT NULL,
    inbound_stock_transfer_order_id integer,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    transfer_status varchar(4096) DEFAULT 'completed'::character varying NOT NULL,
    external_identifier varchar(4096)
);
CREATE TABLE inventory_adjustments (
    id integer NOT NULL,
    sku_id integer,
    lot_code varchar(4096),
    unit_quantity numeric(16,5) DEFAULT NULL::numeric,
    base_quantity_value numeric(16,5) DEFAULT NULL::numeric,
    pallet_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    location_id integer,
    expiry_date varchar(4096),
    expires_on date,
    unit_uom_id integer,
    inventory_status_id integer
);
CREATE TABLE inventory_discrepancies (
    id integer NOT NULL,
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    user_id integer,
    reason varchar(4096),
    remove_adjustment_id integer,
    add_adjustment_id integer,
    site_id integer,
    production_id integer,
    subcomponent_consumption_id integer,
    receipt_item_id integer,
    rejected_item_id integer,
    qb_txn_id varchar(4096),
    synchronized_status varchar(4096),
    qb_last_sync_at timestamp without time zone,
    cycle_count_id integer,
    shipment_id integer,
    user_generated boolean DEFAULT false,
    job_reconciliation_id integer,
    discrepancy_reason_id integer,
    blind_count_id integer,
    sign_off_user_id integer,
    external_identifier varchar(4096)
);
CREATE TABLE inventory_snapshot_schedules (
    id integer NOT NULL,
    customer_id integer,
    site_id integer,
    scheduled_task_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    snapshot_type character varying(255),
    include_inventory_in_wip boolean DEFAULT false,
    name varchar(4096)
);
CREATE TABLE inventory_snapshots (
    id integer NOT NULL,
    site_id integer,
    customer_id integer,
    inventory_snapshot_rows_old varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    xml_payload varchar(4096)
);
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
CREATE TABLE inventory_statuses (
    id integer NOT NULL,
    name varchar(4096),
    integration_key varchar(4096),
    site_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category_id character varying(255),
    active boolean DEFAULT true NOT NULL
);
CREATE TABLE invoice_items (
    id integer NOT NULL,
    sku_id integer,
    notes varchar(4096),
    unit_quantity numeric(16,5) DEFAULT 0.0,
    unit_rate numeric(16,5) DEFAULT 0.0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    invoice_id integer,
    shipment_id integer,
    site_id integer NOT NULL,
    project_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    unit_uom_id integer
);
CREATE TABLE invoices (
    id integer NOT NULL,
    customer_id integer,
    invoiced_at timestamp without time zone,
    terms varchar(4096),
    payment_due_on date,
    reference_1 varchar(4096),
    customer_notes varchar(4096),
    internal_notes varchar(4096),
    paid_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    invoice_type varchar(4096),
    bill_to varchar(4096),
    bill_to_address varchar(4096),
    site_id integer,
    qb_txn_id varchar(4096),
    qb_last_sync_at timestamp without time zone,
    synchronized_status varchar(4096),
    quickbooks_reference_number varchar(4096),
    quickbooks_po_number varchar(4096),
    reference_2 varchar(4096),
    status varchar(4096) DEFAULT 'open'::varchar
);
CREATE TABLE ip_white_list_entries (
    id integer NOT NULL,
    address varchar(4096),
    netmask varchar(4096),
    enabled boolean DEFAULT true,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description varchar(4096)
);
CREATE TABLE item_carts (
    id integer NOT NULL,
    user_id integer,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    location_id integer
);
CREATE TABLE item_categories (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name varchar(4096),
    account_id integer
);
CREATE TABLE item_classes (
    id integer NOT NULL,
    name character varying(255),
    account_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE item_families (
    id integer NOT NULL,
    name varchar(4096),
    account_id integer,
    customer_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE item_types (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name varchar(4096),
    account_id integer,
    pick_strategy varchar(4096) DEFAULT 'none'::character varying NOT NULL
);
CREATE TABLE job_lot_expiries (
    id integer NOT NULL,
    sku_id integer,
    job_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL
);
CREATE TABLE job_reconciliation_counts (
    id integer NOT NULL,
    sku_id integer,
    job_reconciliation_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    old_each_quantity numeric(16,5),
    unit_quantity numeric(16,5),
    site_id integer,
    pallet_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    expires_on date,
    unit_uom_id integer
);
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
    notes varchar(4096),
    percentage_adjusted numeric(16,5),
    adjusted_by_id integer
);
CREATE TABLE job_reconciliations (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    reconciled_at timestamp without time zone
);
CREATE TABLE jobs (
    id integer NOT NULL,
    project_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    scheduled_start_at timestamp without time zone,
    scheduled_end_at timestamp without time zone,
    review boolean DEFAULT false,
    accepted_by_id integer,
    status varchar(4096) DEFAULT 'stopped'::character varying,
    units_expected numeric(16,5) DEFAULT 0 NOT NULL,
    invoice_item_id integer,
    comments varchar(4096),
    reference varchar(4096),
    line_id integer,
    qb_production_txn_id varchar(4096),
    qb_labor_txn_id varchar(4096),
    qb_last_sync_at timestamp without time zone,
    synchronized_status varchar(4096),
    site_id integer NOT NULL,
    qb_non_production_labour_txn_id varchar(4096),
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
    external_identifier varchar(4096)
);
CREATE TABLE licensing_events (
    id integer NOT NULL,
    holder_id integer,
    holder_type varchar(4096),
    billee_id integer,
    billee_type varchar(4096),
    event_type varchar(4096),
    license_type varchar(4096),
    occurred_at timestamp without time zone
);
CREATE TABLE lines (
    id integer NOT NULL,
    description varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    location_id integer,
    site_id integer,
    wip_pallet_id integer,
    inactive boolean DEFAULT false
);
CREATE TABLE locations (
    id integer NOT NULL,
    name varchar(4096),
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pallet_capacity integer DEFAULT 1,
    code varchar(4096),
    active boolean DEFAULT true,
    warehouse_zone_id integer
);
CREATE TABLE master_reference_documents (
    id integer NOT NULL,
    document varchar(4096),
    description varchar(4096),
    customer_id integer,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    enabled boolean DEFAULT true NOT NULL
);
CREATE TABLE modification_restrictions (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sku_id integer,
    locker_id integer,
    site_id integer NOT NULL
);
CREATE TABLE pick_plans (
    id integer NOT NULL,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pick_plan_type varchar(4096)
);
CREATE TABLE moves (
    id integer NOT NULL,
    site_id integer,
    requested_at timestamp without time zone,
    notes varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    assigned_to_id integer,
    status varchar(4096) DEFAULT 'open'::character varying,
    job_id integer,
    pick_plan_id integer,
    pick_constraint_id integer,
    shipment_id integer
);
CREATE TABLE notifications (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id integer,
    company_id integer,
    title varchar(4096),
    message varchar(4096),
    message_type varchar(4096),
    active boolean DEFAULT false NOT NULL,
    require_acknowledgement boolean DEFAULT false NOT NULL
);
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
CREATE TABLE outbound_stock_transfer_units (
    id integer NOT NULL,
    site_id integer,
    sku_id integer,
    pallet_id integer,
    location_id integer,
    unit_quantity numeric(16,5) DEFAULT 0,
    old_each_quantity numeric(16,5) DEFAULT 0,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    inventory_adjustment_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    outbound_stock_transfer_pallet_id integer,
    inventory_status_id integer,
    unit_uom_id integer
);
CREATE TABLE outbound_stock_transfers (
    id integer NOT NULL,
    site_id integer,
    status integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reference_1 varchar(4096),
    reference_2 varchar(4096)
);
CREATE TABLE outbound_trailer_routes (
    id integer NOT NULL,
    site_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
CREATE TABLE outbound_trailer_stops (
    id integer NOT NULL,
    consignee_name varchar(4096),
    number integer,
    outbound_trailer_route_id integer,
    site_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    bill_of_lading_number varchar(4096)
);
CREATE TABLE outbound_trailers (
    id integer NOT NULL,
    site_id integer,
    external_identifier varchar(4096),
    shipped boolean DEFAULT false,
    customer_id integer,
    bill_to varchar(4096),
    bill_to_address varchar(4096),
    carrier_name varchar(4096),
    carrier_code varchar(4096),
    carrier_type varchar(4096),
    carrier_contact varchar(4096),
    carrier_phone varchar(4096),
    bill_of_lading_number bigint,
    trailer_number varchar(4096),
    seal_number varchar(4096),
    tracking_number varchar(4096),
    freight_charge_amount numeric,
    freight_charge_terms varchar(4096),
    expected_ship_at timestamp without time zone,
    actual_ship_at timestamp without time zone,
    ship_from_phone varchar(4096),
    ship_from varchar(4096),
    staging_location_id integer,
    internal_notes varchar(4096),
    invoice_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    expected_arrival_at timestamp without time zone,
    min_temperature numeric,
    min_temperature_unit varchar(4096),
    max_temperature numeric,
    max_temperature_unit varchar(4096),
    reference_1 varchar(4096),
    reference_2 varchar(4096),
    reference_3 varchar(4096),
    integration_reference_1 varchar(4096),
    integration_reference_2 varchar(4096),
    actual_arrival_at timestamp without time zone,
    trailer_length numeric,
    trailer_length_unit varchar(4096),
    outbound_trailer_route_id integer NOT NULL,
    equipment_type varchar(4096),
    dock_appointment_id integer,
    shipped_by_id integer
);
CREATE TABLE overhead_worksheets (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    scenario_id integer,
    labour_percentage numeric(16,5) DEFAULT 0.0,
    account_id integer
);
CREATE TABLE pallet_assignments (
    id integer NOT NULL,
    site_id integer NOT NULL,
    pallet_id integer,
    assigned_for_id integer,
    assigned_for_type varchar(4096),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
CREATE TABLE pallet_charge_settings (
    id integer NOT NULL,
    account_id integer,
    name varchar(4096),
    default_charge numeric(16,5) DEFAULT 0,
    default_charge_full_amount_for_partial boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT false
);
CREATE TABLE pallet_charges (
    id integer NOT NULL,
    account_id integer,
    scenario_charge_id integer,
    name varchar(4096),
    charge numeric(16,5) DEFAULT 0,
    charge_full_amount_for_partial boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE pallet_moves (
    id integer NOT NULL,
    move_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    status integer DEFAULT 1 NOT NULL,
    site_id integer NOT NULL
);
CREATE TABLE pallet_shipments (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pallet_id integer,
    shipment_id integer,
    site_id integer,
    purchase_order_number varchar(4096),
    confirmed boolean,
    customer_reference varchar(4096),
    tracking_number varchar(4096),
    sscc varchar(4096)
);
CREATE TABLE pallets (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    job_id integer,
    reference varchar(4096),
    site_id integer,
    shipped boolean DEFAULT false,
    number varchar(4096),
    pallet_type integer DEFAULT 0 NOT NULL,
    generated_at timestamp without time zone,
    lock_version integer DEFAULT 0 NOT NULL,
    reserve_for_id integer,
    reserve_for_class varchar(4096),
    sequence_number integer
);
CREATE TABLE priority_configurations (
    id integer NOT NULL,
    site_id integer,
    pick_plan_id integer,
    sku_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    priority integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE pick_constraints (
    id integer NOT NULL,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE pick_list_line_items (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    site_id integer NOT NULL,
    pick_list_id integer NOT NULL,
    sku_id integer NOT NULL,
    unit_quantity numeric(21,10) NOT NULL,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    exact_quantity_pick boolean DEFAULT false,
    unit_uom_id integer
);
CREATE TABLE pick_list_picks (
    id integer NOT NULL,
    pick_list_id integer,
    pallet_id integer,
    site_id integer NOT NULL,
    status varchar(4096),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
CREATE TABLE pick_lists (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    site_id integer NOT NULL,
    reservable_id integer,
    destination_location_id integer,
    status character varying(255),
    notes varchar(4096),
    reservable_type varchar(4096)
);
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
    lot_code varchar(4096),
    expiry_date varchar(4096),
    inventory_status_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
CREATE TABLE picked_inventory (
    id integer NOT NULL,
    sku_id integer,
    location_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    expected_base_quantity numeric(16,5) DEFAULT 0.0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    exact_quantity_pick boolean DEFAULT false,
    priority integer,
    actual_base_quantity numeric(16,5) DEFAULT 0.0,
    site_id integer,
    pick_constraint_id integer
);
CREATE TABLE planned_receipt_items (
    id integer NOT NULL,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    expiry_date varchar(4096),
    lot_code varchar(4096),
    notes varchar(4096),
    unit_quantity numeric(16,5) DEFAULT 0.0,
    pallet_id integer,
    planned_receipt_id integer,
    receive_order_item_id integer,
    site_id integer NOT NULL,
    sku_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    external_identifier varchar(4096),
    unit_uom_id integer
);
CREATE TABLE planned_receipts (
    id integer NOT NULL,
    bill_of_lading varchar(4096),
    expected_receive_at timestamp without time zone,
    internal_notes varchar(4096),
    reference_1 varchar(4096),
    reference_2 varchar(4096),
    trailer_number varchar(4096),
    carrier_id integer,
    customer_id integer,
    site_id integer,
    vendor_id integer,
    receive_to_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    external_identifier varchar(4096)
);
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
    carrier_code varchar(4096),
    carrier_name varchar(4096),
    bill_to varchar(4096),
    staging_location_id integer
);
CREATE TABLE production_archives (
    id integer NOT NULL,
    archived_record_id integer NOT NULL,
    archived_record_created_at timestamp without time zone,
    archived_record_updated_at timestamp without time zone,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    pallet_id integer NOT NULL,
    lot_code varchar(4096),
    produced_at timestamp without time zone,
    inventory_adjustment_id integer,
    cost_per_unit numeric(16,5) DEFAULT 0.0 NOT NULL,
    reference varchar(4096),
    expiry_date varchar(4096),
    job_id integer NOT NULL,
    site_id integer NOT NULL,
    printed_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    base_quantity numeric(16,5) DEFAULT 0.0
);
CREATE TABLE productions (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    pallet_id integer NOT NULL,
    lot_code varchar(4096),
    produced_at timestamp without time zone,
    inventory_adjustment_id integer,
    cost_per_unit numeric(16,5) DEFAULT 0.0 NOT NULL,
    reference varchar(4096),
    expiry_date varchar(4096),
    job_id integer NOT NULL,
    site_id integer NOT NULL,
    printed_at timestamp without time zone,
    base_quantity numeric(16,5) DEFAULT 0.0
);
CREATE TABLE project_attachments (
    id integer NOT NULL,
    size integer,
    content_type varchar(4096),
    document varchar(4096),
    project_id integer,
    description varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL,
    uuid varchar(4096)
);
CREATE TABLE project_charge_settings (
    id integer NOT NULL,
    account_id integer,
    name varchar(4096),
    default_charge numeric(16,5) DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT false
);
CREATE TABLE project_charges (
    id integer NOT NULL,
    name varchar(4096),
    charge numeric(16,5) DEFAULT 0,
    scenario_charge_id integer,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE projects (
    id integer NOT NULL,
    code varchar(4096),
    description varchar(4096),
    sku_id integer,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    scenario_id integer,
    customer_id integer,
    long_running boolean DEFAULT false,
    units_expected numeric(16,5) DEFAULT 0.0,
    reference_1 varchar(4096),
    reference_2 varchar(4096),
    last_job_completed_at timestamp without time zone,
    due_date_at timestamp without time zone,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    base_quantity_produced numeric(16,5) DEFAULT 0.0,
    lock_version integer DEFAULT 0,
    status integer DEFAULT 0 NOT NULL,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    use_lot_code boolean DEFAULT false,
    use_expiry_date boolean DEFAULT false,
    reference_3 varchar(4096),
    custom_project_field_value_id integer,
    external_identifier varchar(4096)
);
CREATE TABLE qb_logs (
    id integer NOT NULL,
    xml varchar(4096),
    transaction_type varchar(4096),
    qb_class varchar(4096),
    object_id integer,
    user_id integer,
    message varchar(4096),
    qb_error varchar(4096),
    stack_trace varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    progress varchar(4096),
    state varchar(4096),
    account_id integer NOT NULL
);
CREATE TABLE qc_sheet_items (
    id integer NOT NULL,
    qc_sheet_id integer,
    name varchar(4096),
    description varchar(4096),
    result varchar(4096),
    notes varchar(4096),
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL
);
CREATE TABLE qc_sheets (
    id integer NOT NULL,
    qc_template_id integer,
    job_id integer,
    name varchar(4096),
    sign_off_role varchar(4096),
    sign_off_user_id integer,
    notes varchar(4096),
    performed_at timestamp without time zone,
    last_modified_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    shipment_id integer,
    receipt_id integer,
    project_id integer,
    site_id integer NOT NULL
);
CREATE TABLE qc_template_items (
    id integer NOT NULL,
    name varchar(4096),
    description varchar(4096),
    qc_template_id integer,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer NOT NULL
);
CREATE TABLE qc_templates (
    id integer NOT NULL,
    sku_id integer,
    name varchar(4096),
    sign_off_role varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer,
    report_url varchar(4096),
    visible_by integer DEFAULT 1
);
CREATE TABLE quote_attachments (
    id integer NOT NULL,
    size integer,
    content_type varchar(4096),
    document varchar(4096),
    quote_id integer,
    description varchar(4096),
    account_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uuid varchar(4096)
);
CREATE TABLE quote_reference_documents (
    id integer NOT NULL,
    master_reference_document_id integer,
    quote_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer NOT NULL
);
CREATE TABLE quoted_bom_items (
    id integer NOT NULL,
    item_code varchar(4096),
    quantity numeric(16,5) DEFAULT 0,
    cost_per_unit numeric(16,5) DEFAULT 0,
    markup_per_unit numeric(16,5) DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    scenario_id integer,
    account_id integer,
    description varchar(4096),
    "position" integer,
    reject_rate numeric(16,5) DEFAULT 0,
    external_identifier varchar(4096),
    unit_of_measure_id integer
);
CREATE TABLE quotes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name varchar(4096),
    customer_id integer,
    reference varchar(4096),
    requestor varchar(4096),
    estimator varchar(4096),
    requested_on date,
    estimated_on date,
    expires_on date,
    launch_on date,
    revision integer DEFAULT 0,
    account_id integer,
    custom_estimate_field_1 varchar(4096),
    custom_estimate_field_2 varchar(4096),
    custom_estimate_field_3 varchar(4096),
    custom_estimate_field_4 varchar(4096),
    custom_estimate_field_5 varchar(4096),
    external_identifier varchar(4096),
    status varchar(4096)
);
CREATE TABLE rack_locations (
    id integer NOT NULL,
    label1 varchar(4096),
    break1 varchar(4096),
    label2 varchar(4096),
    break2 varchar(4096),
    label3 varchar(4096),
    break3 varchar(4096),
    label4 varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    location_id integer
);
CREATE TABLE receipt_attachments (
    id integer NOT NULL,
    size integer,
    content_type varchar(4096),
    document varchar(4096),
    receipt_id integer,
    description varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    uuid varchar(4096)
);
CREATE TABLE receipt_item_logs (
    id integer NOT NULL,
    receipt_item_id integer,
    field_name varchar(4096),
    changed_from varchar(4096),
    changed_to varchar(4096),
    username varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL
);
CREATE TABLE receipt_items (
    id integer NOT NULL,
    receipt_id integer,
    inventory_adjustment_id integer,
    notes varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    sku_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    purchase_price_per_unit numeric(16,5) DEFAULT 0,
    site_id integer NOT NULL,
    unit_quantity_per_skid numeric(16,5) DEFAULT 0,
    number_of_skids integer DEFAULT 1,
    pallet_id integer,
    receive_to_id integer,
    receive_order_item_id integer,
    reference varchar(4096),
    external_identifier varchar(4096),
    unit_uom_id integer,
    inventory_status_id integer
);
CREATE TABLE receipts (
    id integer NOT NULL,
    vendor_id integer,
    site_id integer,
    received_at timestamp without time zone,
    bill_of_lading varchar(4096),
    packing_slip varchar(4096),
    internal_notes varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reference_1 varchar(4096),
    received_by varchar(4096),
    reference_2 varchar(4096),
    trailer_number varchar(4096),
    synchronized_status varchar(4096),
    qb_txn_id varchar(4096),
    qb_last_sync_at timestamp without time zone,
    receive_to_id integer,
    customer_id integer,
    carrier_id integer,
    status integer,
    mobile_receive_order_id integer,
    expected_at timestamp without time zone,
    planned_receipt_id integer,
    external_identifier varchar(4096)
);
CREATE TABLE receive_order_archives (
    id integer NOT NULL,
    vendor_id integer,
    reference varchar(4096),
    expected_delivery_at timestamp without time zone,
    vendor_notes varchar(4096),
    internal_notes varchar(4096),
    archived_record_id integer NOT NULL,
    archived_record_created_at timestamp without time zone,
    archived_record_updated_at timestamp without time zone,
    site_id integer,
    ro_date_at timestamp without time zone,
    received boolean DEFAULT false,
    customer_id integer,
    project_id integer,
    synchronized_status varchar(4096),
    qb_txn_id varchar(4096),
    qb_last_sync_at timestamp without time zone,
    netsuite_id varchar(4096),
    netsuite_last_sync_at timestamp without time zone,
    carrier_id integer,
    quickbooks_reference_number varchar(4096),
    sent_edi_940 boolean DEFAULT false,
    external_identifier varchar(4096),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    purchaser varchar(4096),
    status varchar(4096),
    code varchar(4096)
);
CREATE TABLE receive_order_attachments (
    id integer NOT NULL,
    size integer,
    content_type varchar(4096),
    document varchar(4096),
    receive_order_id integer,
    description varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL,
    uuid varchar(4096)
);
CREATE TABLE receive_order_item_archives (
    id integer NOT NULL,
    archived_record_id integer NOT NULL,
    archived_record_created_at timestamp without time zone,
    archived_record_updated_at timestamp without time zone,
    sku_id integer,
    receive_order_id integer,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    purchase_price_per_unit numeric(16,5) DEFAULT 0.0,
    qb_txn_id varchar(4096),
    qb_last_sync_at timestamp without time zone,
    "position" integer,
    site_id integer NOT NULL,
    old_each_quantity numeric,
    reference_1 varchar(4096),
    external_identifier varchar(4096),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unit_uom_id integer
);
CREATE TABLE receive_order_items (
    id integer NOT NULL,
    sku_id integer,
    receive_order_id integer,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    purchase_price_per_unit numeric(16,5) DEFAULT 0.0,
    qb_txn_id varchar(4096),
    qb_last_sync_at timestamp without time zone,
    "position" integer,
    site_id integer NOT NULL,
    old_each_quantity numeric,
    reference_1 varchar(4096),
    external_identifier varchar(4096),
    unit_uom_id integer
);
CREATE TABLE receive_orders (
    id integer NOT NULL,
    vendor_id integer,
    reference varchar(4096),
    expected_delivery_at timestamp without time zone,
    vendor_notes varchar(4096),
    internal_notes varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    ro_date_at timestamp without time zone,
    received boolean DEFAULT false,
    customer_id integer,
    project_id integer,
    synchronized_status varchar(4096),
    qb_txn_id varchar(4096),
    qb_last_sync_at timestamp without time zone,
    netsuite_id varchar(4096),
    netsuite_last_sync_at timestamp without time zone,
    carrier_id integer,
    quickbooks_reference_number varchar(4096),
    sent_edi_940 boolean DEFAULT false,
    external_identifier varchar(4096),
    purchaser varchar(4096) DEFAULT 'unspecified'::varchar,
    status varchar(4096) DEFAULT 'unspecified'::varchar,
    code varchar(4096)
);
CREATE TABLE reconciliation_reasons (
    id integer NOT NULL,
    code varchar(4096),
    reason varchar(4096),
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer
);
CREATE TABLE reject_reasons (
    id integer NOT NULL,
    code varchar(4096),
    reason varchar(4096),
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    enabled boolean DEFAULT true NOT NULL
);
CREATE TABLE rejected_item_archives (
    id integer NOT NULL,
    archived_record_id integer,
    archived_record_created_at timestamp without time zone,
    archived_record_updated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    sku_id integer,
    lot_code varchar(4096),
    unit_quantity numeric(16,5) DEFAULT 0.0,
    job_id integer,
    cost_per_unit numeric(16,5) DEFAULT 0.0 NOT NULL,
    expiry_date varchar(4096),
    add_adjustment_id integer,
    remove_adjustment_id integer,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    reject_reason_id integer,
    site_id integer NOT NULL,
    pallet_id integer,
    track_by_job boolean DEFAULT false,
    unit_uom_id integer
);
CREATE TABLE rejected_items (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    sku_id integer,
    lot_code varchar(4096),
    unit_quantity numeric(16,5) DEFAULT 0,
    job_id integer,
    cost_per_unit numeric(16,5) DEFAULT 0.0 NOT NULL,
    expiry_date varchar(4096),
    add_adjustment_id integer,
    remove_adjustment_id integer,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    reject_reason_id integer,
    site_id integer NOT NULL,
    pallet_id integer,
    track_by_job boolean DEFAULT false,
    unit_uom_id integer
);
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
CREATE TABLE reserved_inventory_levels (
    id integer NOT NULL,
    reservable_id integer,
    reservable_type varchar(4096),
    sku_id integer,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    base_quantity numeric(16,5) DEFAULT 0.0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer
);
CREATE TABLE scenario_attachments (
    id integer NOT NULL,
    size integer,
    content_type varchar(4096),
    filename varchar(4096),
    description varchar(4096),
    custom_output_id integer,
    account_id integer,
    scenario_id integer,
    document varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uuid varchar(4096)
);
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
    external_identifier varchar(4096)
);
CREATE TABLE scenario_loss_reasons (
    id integer NOT NULL,
    reason varchar(4096),
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE scenario_to_scenario_attachments (
    id integer NOT NULL,
    scenario_id integer,
    scenario_attachment_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer NOT NULL
);
CREATE TABLE scenarios (
    id integer NOT NULL,
    quote_id integer,
    name varchar(4096),
    description varchar(4096),
    volume numeric(16,5) DEFAULT 0,
    production_time numeric(16,5) DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    item varchar(4096),
    account_id integer,
    wage numeric(16,5) DEFAULT 0.0,
    status character varying(255) DEFAULT NULL::character varying,
    item_description varchar(4096),
    item_type_id integer,
    item_category_id integer,
    scenario_loss_reason_id integer,
    eaches_per_case numeric(16,5) DEFAULT 1.0,
    cases_per_pallet numeric(16,5) DEFAULT 1.0,
    item_family_id integer,
    custom_scenario_field_1 varchar(4096),
    custom_scenario_field_2 varchar(4096),
    custom_scenario_field_3 varchar(4096),
    custom_scenario_field_4 varchar(4096),
    custom_scenario_field_5 varchar(4096),
    custom_scenario_field_6 varchar(4096),
    custom_scenario_field_7 varchar(4096),
    custom_scenario_field_8 varchar(4096),
    custom_scenario_field_9 varchar(4096),
    custom_scenario_field_10 varchar(4096),
    custom_scenario_field_11 varchar(4096),
    custom_scenario_field_12 varchar(4096),
    custom_scenario_field_13 varchar(4096),
    custom_scenario_field_14 varchar(4096),
    custom_scenario_field_15 varchar(4096),
    external_identifier varchar(4096),
    unit_of_measure_id integer NOT NULL,
    chargeable_units_per_pallet numeric(16,5) DEFAULT 1
);
CREATE TABLE scheduled_tasks (
    id integer NOT NULL,
    name varchar(4096),
    user_id integer,
    account_id integer,
    schedule varchar(4096),
    action_class_name varchar(4096),
    action_args varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    company_id integer,
    site_id integer,
    task_type varchar(4096)
);
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
CREATE TABLE scheduling_line_assignments (
    id integer NOT NULL,
    site_id integer,
    scheduling_line_id integer,
    scheduling_project_demand_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
CREATE TABLE scheduling_lines (
    id integer NOT NULL,
    site_id integer,
    name varchar(4096),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    external_id varchar(4096),
    description varchar(4096)
);
CREATE TABLE scheduling_project_demands (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    external_id varchar(4096),
    site_id integer,
    unit_quantity_remaining numeric(16,5),
    units_per_hour numeric(16,5),
    performance numeric(16,5),
    project_code varchar(4096),
    item_external_id varchar(4096),
    item_code varchar(4096),
    due_date_at timestamp without time zone,
    priority integer,
    minutes_remaining integer,
    item_description varchar(4096)
);
CREATE TABLE scheduling_shifts (
    id integer NOT NULL,
    site_id integer,
    external_id varchar(4096),
    name varchar(4096),
    start_at time without time zone,
    end_at time without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
CREATE TABLE schema_migrations (
    version varchar(4096)
);
CREATE TABLE selected_items (
    id integer NOT NULL,
    location_id integer,
    pallet_id integer,
    sku_id integer,
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    item_cart_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL,
    base_quantity numeric(16,5) DEFAULT 0.0,
    inventory_status_id integer
);
CREATE TABLE selected_pallets (
    id integer NOT NULL,
    pallet_id integer,
    item_cart_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL
);
CREATE TABLE sequence_generators (
    id integer NOT NULL,
    account_id integer,
    site_id integer,
    seq_type varchar(4096),
    source_id integer,
    current_value integer,
    lock_version integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    additional_info varchar(4096)
);
CREATE TABLE sessions (
    id integer NOT NULL,
    session_id varchar(4096),
    data varchar(4096),
    updated_at timestamp without time zone
);
CREATE TABLE shifts (
    id integer NOT NULL,
    name varchar(4096),
    start_at time without time zone,
    end_at time without time zone,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE ship_order_attachments (
    id integer NOT NULL,
    size integer,
    content_type varchar(4096),
    document varchar(4096),
    ship_order_id integer,
    description varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL,
    uuid varchar(4096)
);
CREATE TABLE ship_order_items (
    id integer NOT NULL,
    ship_order_id integer,
    sku_id integer,
    unit_quantity numeric(16,5) DEFAULT 0.0,
    purchase_order_number varchar(4096),
    project_id integer,
    price_per_unit numeric(16,5) DEFAULT 0,
    qb_txn_id varchar(4096),
    qb_last_sync_at timestamp without time zone,
    site_id integer NOT NULL,
    customer_reference varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    external_identifier varchar(4096),
    unit_uom_id integer,
    consignee_sku varchar(4096)
);
CREATE TABLE ship_orders (
    id integer NOT NULL,
    expected_ship_at timestamp without time zone,
    reference_number varchar(4096),
    notes varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer,
    shipped boolean DEFAULT false,
    consignee_id integer,
    customer_id integer,
    synchronized_status varchar(4096),
    qb_last_sync_at timestamp without time zone,
    qb_txn_id varchar(4096),
    so_date_at timestamp without time zone,
    netsuite_id varchar(4096),
    netsuite_last_sync_at timestamp without time zone,
    carrier_id integer,
    freight_charge_terms varchar(4096),
    external_identifier varchar(4096),
    custom_ship_order_field_1 varchar(4096),
    custom_ship_order_field_2 varchar(4096),
    custom_ship_order_field_3 varchar(4096),
    custom_ship_order_field_4 varchar(4096),
    custom_ship_order_field_5 varchar(4096),
    custom_ship_order_field_6 varchar(4096),
    custom_ship_order_field_7 varchar(4096),
    code varchar(4096)
);
CREATE TABLE shipment_attachments (
    id integer NOT NULL,
    size integer,
    content_type varchar(4096),
    document varchar(4096),
    shipment_id integer,
    description varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    site_id integer NOT NULL,
    uuid varchar(4096)
);
CREATE TABLE shipments (
    id integer NOT NULL,
    ship_order_id integer,
    ship_to_old_address varchar(4096),
    actual_ship_at timestamp without time zone,
    shipment_notes varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ship_to varchar(4096),
    ship_to_id integer,
    site_id integer,
    shipped boolean DEFAULT false,
    bill_of_lading_number bigint,
    invoice_id integer,
    ship_to_phone varchar(4096),
    synchronized_status varchar(4096),
    qb_txn_id varchar(4096),
    qb_last_sync_at timestamp without time zone,
    ship_to_attention varchar(4096),
    ship_to_address_1 varchar(4096),
    ship_to_address_2 varchar(4096),
    ship_to_city varchar(4096),
    ship_to_province varchar(4096),
    ship_to_postal_code varchar(4096),
    ship_to_country varchar(4096),
    custom_1 varchar(4096),
    custom_2 varchar(4096),
    estimated_delivery_at timestamp without time zone,
    quickbooks_reference_number varchar(4096),
    actual_delivery_at timestamp without time zone,
    quickbooks_po_number varchar(4096),
    external_identifier varchar(4096),
    planned_shipment_id integer,
    ship_to_code varchar(4096),
    outbound_trailer_id integer NOT NULL,
    ship_to_facility_number varchar(4096)
);
CREATE TABLE sites (
    id integer NOT NULL,
    name varchar(4096),
    description varchar(4096),
    account_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    inventory boolean DEFAULT false,
    tna boolean DEFAULT false,
    timezone varchar(4096) DEFAULT 'America/New_York'::character varying,
    address varchar(4096),
    drp boolean DEFAULT false,
    production_metric_tracking varchar(4096) DEFAULT 'units_per_hour'::character varying,
    phone_number varchar(4096),
    display_alt_code_1_on_pallet_tag boolean DEFAULT false,
    display_alt_code_2_on_pallet_tag boolean DEFAULT false,
    default_shipment_quickbooks_status varchar(4096) DEFAULT 'entered'::character varying,
    default_production_graph varchar(4096) DEFAULT 'line_efficiency'::varchar,
    display_creation_date_on_pallet_tag boolean DEFAULT false,
    validate_quick_consume boolean DEFAULT false,
    default_shift_id integer,
    use_shipment_custom_1 boolean DEFAULT false,
    use_shipment_custom_2 boolean DEFAULT false,
    shipment_custom_1_label varchar(4096) DEFAULT 'Reference 1'::character varying,
    shipment_custom_2_label varchar(4096) DEFAULT 'Reference 2'::character varying,
    add_receipt_items_automatically boolean DEFAULT true,
    workflow varchar(4096) DEFAULT 'none'::character varying,
    display_job_on_pallet_tag boolean DEFAULT false,
    setting_create_projects_from_ship_orders boolean DEFAULT false,
    show_availability_report boolean DEFAULT false,
    show_current_inventory_report boolean DEFAULT true,
    missing_inventory_on_production varchar(4096) DEFAULT 'warning'::character varying,
    show_subcomponent_availability_report boolean DEFAULT false,
    show_freight_charge_terms_on_ship_order boolean DEFAULT false,
    require_trailer_number_on_shipments boolean DEFAULT false,
    require_seal_number_on_shipments boolean DEFAULT false,
    edi boolean DEFAULT false,
    global_access boolean DEFAULT true,
    allow_top_up_from_previous_jobs boolean DEFAULT true,
    no_labor_on_production_or_manual_consumption varchar(4096) DEFAULT 'error'::varchar,
    planning boolean DEFAULT false,
    lock_shipments_for varchar(4096) DEFAULT 'lead'::varchar,
    minimum_dequarantine_role varchar(4096),
    dequarantine_signoff_required boolean DEFAULT false,
    minimum_inventory_adjustment_role varchar(4096) DEFAULT 'lead'::varchar,
    default_reconciliation_uom varchar(4096) DEFAULT 'eaches'::character varying,
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
    minimum_recall_shipment_role varchar(4096) DEFAULT 'site_admin'::character varying,
    setting_enforce_complex_passwords boolean DEFAULT false,
    minimum_password_length integer DEFAULT 4,
    setting_allow_case_label_printing boolean DEFAULT false,
    setting_password_expiry integer DEFAULT 0,
    setting_password_reuse integer DEFAULT 0,
    setting_allow_custom_outputs boolean DEFAULT false,
    setting_autoset_project_booked_status boolean DEFAULT true,
    allow_can_run boolean DEFAULT false,
    minimum_locked_ship_order_modification_role varchar(4096) DEFAULT 'site_admin'::character varying,
    setting_default_pallet_tag_printing_on_add_production boolean DEFAULT false,
    display_location_on_pallet_tags_for_jobs boolean DEFAULT false,
    setting_minimum_pallet_number_digits integer DEFAULT 0,
    include_track_by_job_subs_in_missing_inventory boolean DEFAULT true,
    setting_show_print_duplicate_pallet_tag_warning_for_job boolean DEFAULT true,
    setting_require_lot_expiry_for_track_by_job_rejects boolean DEFAULT false,
    setting_allow_multiple_bols boolean DEFAULT true NOT NULL,
    allow_top_up_from_current_job boolean DEFAULT true NOT NULL,
    minimum_reconcile_role varchar(4096) DEFAULT 'lead'::varchar,
    return_subcomponents_to_matching_pallet boolean DEFAULT true,
    setting_require_quality_to_change_lot_expiries_on_production boolean DEFAULT false,
    copy_project_reference_2_to_shipment_po boolean DEFAULT false,
    external_pallet_numbers integer DEFAULT 0,
    mobile_auto_show_pallet_details_on_move boolean DEFAULT false NOT NULL,
    round_inbound_sto_to varchar(4096) DEFAULT 'item_uom'::character varying NOT NULL,
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
    ist_creation_setting_code varchar(4096) DEFAULT 'edi_created_as_complete'::character varying,
    new_job_creator_page boolean DEFAULT false NOT NULL,
    tenant_uid varchar(4096),
    send_events boolean DEFAULT false NOT NULL,
    enable_planned_receipts boolean DEFAULT false NOT NULL,
    collect_user_feedback boolean DEFAULT false,
    lockdown_reconciled_jobs boolean DEFAULT false NOT NULL,
    maximum_number_of_case_labels integer DEFAULT 30,
    min_reorder_on_job_role varchar(4096) DEFAULT 'disallow'::varchar,
    enable_gs1_128_barcodes_on_mobile boolean DEFAULT false,
    setting_production_pallet_sequencing character varying(255),
    background_reports varchar(4096) DEFAULT ''::character varying,
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
CREATE TABLE sku_attachments (
    id integer NOT NULL,
    size integer,
    content_type varchar(4096),
    document varchar(4096),
    sku_id integer,
    description varchar(4096),
    account_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uuid varchar(4096)
);
CREATE TABLE skus (
    id integer NOT NULL,
    code varchar(4096),
    description varchar(4096),
    customer_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer,
    cost_per_unit numeric(16,5) DEFAULT 0,
    item_type_id integer,
    item_category_id integer,
    alternate_code_1 varchar(4096),
    alternate_code_2 varchar(4096),
    weight_per_pallet numeric(16,5) DEFAULT 0,
    inactive boolean DEFAULT false,
    track_lot_code_by varchar(4096) DEFAULT 'pallet'::character varying,
    quick_consume boolean DEFAULT false,
    track_pallets boolean DEFAULT true,
    vendor_id integer,
    qb_list_id varchar(4096),
    qb_last_sync_at timestamp without time zone,
    export_to_accounting boolean DEFAULT false,
    reorder_strategy integer DEFAULT 0,
    netsuite_id varchar(4096),
    netsuite_last_sync_at timestamp without time zone,
    auto_backflush boolean DEFAULT true,
    country_of_origin varchar(4096),
    nmfc_code varchar(4096),
    freight_class varchar(4096),
    weight_per_case numeric(16,5) DEFAULT 0.0,
    custom_item_field_1 varchar(4096),
    custom_item_field_2 varchar(4096),
    custom_item_field_3 varchar(4096),
    custom_item_field_4 varchar(4096),
    custom_item_field_5 varchar(4096),
    custom_item_field_6 varchar(4096),
    custom_item_field_7 varchar(4096),
    custom_item_field_8 varchar(4096),
    custom_item_field_9 varchar(4096),
    custom_item_field_10 varchar(4096),
    custom_item_field_11 varchar(4096),
    custom_item_field_12 varchar(4096),
    custom_item_field_13 varchar(4096),
    custom_item_field_14 varchar(4096),
    custom_item_field_15 varchar(4096),
    custom_item_field_16 varchar(4096),
    custom_item_field_17 varchar(4096),
    custom_item_field_18 varchar(4096),
    custom_item_field_19 varchar(4096),
    custom_item_field_20 varchar(4096),
    custom_item_field_21 varchar(4096),
    custom_item_field_22 varchar(4096),
    custom_item_field_23 varchar(4096),
    custom_item_field_24 varchar(4096),
    custom_item_field_25 varchar(4096),
    item_family_id integer,
    is_subcomponent boolean DEFAULT false,
    is_finished_good boolean DEFAULT false,
    auto_quarantine_on_receipt boolean DEFAULT false,
    auto_quarantine_on_production boolean DEFAULT false,
    safety_stock numeric(16,5) DEFAULT 0.0,
    safety_stock_unit_of_measure varchar(4096) DEFAULT 'eaches'::character varying,
    expiry_date_format_id integer,
    lead_time_type integer DEFAULT 0,
    lead_time_days integer DEFAULT 0,
    reject_rate numeric(16,5) DEFAULT 0,
    item_shelf_life_id integer,
    lot_code_policy varchar(4096) DEFAULT 'do not track'::character varying NOT NULL,
    expiry_date_policy varchar(4096) DEFAULT 'do not track'::character varying NOT NULL,
    lot_code_rule_id integer,
    expiry_date_rule_id integer,
    external_identifier varchar(4096),
    pick_strategy varchar(4096) DEFAULT 'none'::character varying NOT NULL,
    pick_strategy_source varchar(4096) DEFAULT 'none'::character varying NOT NULL,
    stop_ship_limit integer,
    item_class_id integer,
    safety_stock_uom_id integer,
    record_consumption character varying(255) DEFAULT 'automatically'::character varying,
    require_physical_count_during_reconciliation boolean DEFAULT true NOT NULL,
    reconciliation_threshold_percentage numeric(16,5) DEFAULT 0.0 NOT NULL
);
CREATE TABLE staging_locations (
    id integer NOT NULL,
    location_id integer,
    site_id integer,
    description varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE subcomponent_consumption_archives (
    id integer NOT NULL,
    archived_record_id integer,
    archived_record_created_at timestamp without time zone,
    archived_record_updated_at timestamp without time zone,
    lot_code varchar(4096),
    unit_quantity numeric(16,5) DEFAULT 0.0,
    production_id integer,
    sku_id integer,
    inventory_adjustment_id integer,
    job_id integer,
    expiry_date varchar(4096),
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    site_id integer NOT NULL,
    track_by_job boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unit_uom_id integer
);
CREATE TABLE subcomponent_consumptions (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    lot_code varchar(4096),
    unit_quantity numeric(16,5) DEFAULT 0,
    production_id integer,
    sku_id integer,
    inventory_adjustment_id integer,
    job_id integer,
    expiry_date varchar(4096),
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    site_id integer NOT NULL,
    track_by_job boolean DEFAULT false NOT NULL,
    unit_uom_id integer
);
CREATE TABLE time_cards (
    id integer NOT NULL,
    badge_code varchar(4096),
    time_in_at timestamp without time zone,
    comments varchar(4096),
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
CREATE TABLE time_reports (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    started_at timestamp without time zone,
    ended_at timestamp without time zone,
    job_id integer,
    badge_code varchar(4096),
    badge_type_id integer,
    site_id integer,
    cost_per_hour numeric(16,5) DEFAULT 0 NOT NULL
);
CREATE TABLE trailer_background_shipments (
    id integer NOT NULL,
    outbound_trailer_id integer,
    background_task_id integer,
    site_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
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
    expiry_date varchar(4096),
    lot_code varchar(4096),
    from_pallet_id integer,
    from_location_id integer,
    to_pallet_id integer,
    to_location_id integer,
    job_reconciliation_id integer,
    inventory_status_id integer,
    unit_uom_id integer
);
CREATE TABLE unit_of_measures (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    label varchar(4096),
    code varchar(4096),
    short_label varchar(4096),
    account_id integer,
    active boolean DEFAULT true NOT NULL,
    integration_key varchar(4096)
);
CREATE TABLE unit_shipments (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pallet_id integer,
    unit_quantity numeric(16,5) DEFAULT 0,
    lot_code varchar(4096),
    expiry_date varchar(4096),
    sku_id integer,
    shipment_id integer,
    inventory_adjustment_id integer,
    purchase_order_number varchar(4096),
    old_each_quantity numeric(16,5) DEFAULT 0.0,
    location_id integer,
    confirmed boolean,
    site_id integer NOT NULL,
    pallet_shipment_id integer,
    customer_reference varchar(4096),
    unit_uom_id integer,
    inventory_status_id integer,
    tracking_number varchar(4096),
    sscc varchar(4096)
);
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
CREATE TABLE uom_ratios (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    code varchar(4096),
    dimension_id integer NOT NULL,
    account_id integer,
    ratio_to_base numeric(32,10) DEFAULT 0.0,
    base_uom boolean DEFAULT false,
    unit_of_measure_id integer,
    conversion_ratio numeric(32,10),
    conversion_unit_of_measure_id integer,
    active boolean DEFAULT true NOT NULL
);
CREATE TABLE users (
    id integer NOT NULL,
    login varchar(4096),
    email varchar(4096),
    crypted_password varchar(4096) DEFAULT ''::character varying NOT NULL,
    password_salt varchar(4096) DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer,
    site_id integer,
    role varchar(4096),
    financial_access varchar(4096) DEFAULT 'none'::varchar,
    customer_id integer,
    tooltip_delay boolean DEFAULT false,
    last_login_at timestamp without time zone,
    persistence_token varchar(4096),
    single_access_token varchar(4096),
    perishable_token varchar(4096),
    login_count integer DEFAULT 0 NOT NULL,
    failed_login_count integer DEFAULT 0 NOT NULL,
    last_request_at timestamp without time zone,
    current_login_at timestamp without time zone,
    current_login_ip varchar(4096),
    last_login_ip varchar(4096),
    announcement_id integer,
    show_announcement boolean DEFAULT true,
    password_updated_at timestamp without time zone,
    expired boolean DEFAULT false,
    previous_passwords varchar(4096) DEFAULT '--- []

'::varchar,
    mobile_access boolean DEFAULT false,
    desktop_access boolean DEFAULT true,
    allow_quality boolean DEFAULT false,
    nulogy_employee boolean DEFAULT false NOT NULL,
    company_id integer,
    active boolean DEFAULT true NOT NULL,
    locale varchar(4096) DEFAULT 'en_US'::character varying NOT NULL,
    billing_site_id integer NOT NULL,
    uservoice_allow_forums character varying(255)
);
CREATE TABLE vendors (
    id integer NOT NULL,
    name varchar(4096),
    contact varchar(4096),
    phone varchar(4096),
    email varchar(4096),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id integer,
    address varchar(4096),
    code varchar(4096),
    qb_list_id varchar(4096),
    qb_last_sync_at timestamp without time zone,
    order_lead_time integer DEFAULT 0,
    netsuite_id varchar(4096),
    netsuite_last_sync_at timestamp without time zone,
    default_receipt_status integer DEFAULT 1,
    fax varchar(4096),
    external_identifier character varying(255)
);
CREATE TABLE wage_details (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    badge_type_id integer,
    quantity numeric(16,5) DEFAULT 0.0,
    scenario_id integer,
    account_id integer NOT NULL
);
CREATE TABLE zoning_rules (
    id integer NOT NULL,
    site_id integer NOT NULL,
    warehouse_zone_id integer NOT NULL,
    item_class_id integer NOT NULL
);
CREATE TABLE warehouse_zones (
    id integer NOT NULL,
    name character varying(255),
    site_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    allow_all_items boolean DEFAULT false
);
CREATE TABLE workdays (
    id integer NOT NULL,
    day_of_week integer,
    site_id integer,
    workday boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: allowed_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: allowed_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: allowed_sites_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: allowed_sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: application_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: application_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: assembly_item_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: assembly_item_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: assembly_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: assembly_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: assembly_procedures_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: assembly_procedures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: background_query_results_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: background_query_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: background_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: background_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: badge_types_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: badge_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: barcode_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: barcode_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: barcode_segments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: barcode_segments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: bc_snapshot_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: bc_snapshot_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: blind_count_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: blind_count_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: blind_count_rows_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: blind_count_rows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: blind_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: blind_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: bom_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: bom_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: bookmark_users_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: bookmark_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: bookmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: bookmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: breaks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: breaks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: cancel_pick_up_picks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: cancel_pick_up_picks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: carriers_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: carriers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: cc_historical_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: cc_historical_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: company_locales_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: company_locales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: consignee_custom_outputs_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: consignee_custom_outputs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: consignees_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: consignees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: consumption_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: consumption_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: consumption_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: consumption_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: current_inventory_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: current_inventory_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: custom_charge_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: custom_charge_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: custom_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: custom_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: custom_output_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: custom_output_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: custom_output_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: custom_output_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: custom_outputs_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: custom_outputs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: custom_per_unit_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: custom_per_unit_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: custom_project_field_values_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: custom_project_field_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: custom_project_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: custom_project_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: customer_access_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: customer_access_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: cycle_count_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: cycle_count_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: cycle_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: cycle_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: deleted_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: deleted_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: discrepancy_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: discrepancy_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: dock_appointments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: dock_appointments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: downtime_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: downtime_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: drop_off_picks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: drop_off_picks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: edi_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: edi_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: edi_customer_triggers_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: edi_customer_triggers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: edi_inbounds_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: edi_inbounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: edi_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: edi_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: edi_mapping_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: edi_mapping_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: edi_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: edi_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: edi_outbounds_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: edi_outbounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: edi_skip_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: edi_skip_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: edi_status_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: edi_status_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: email_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: email_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: events_conforming_to_cpi; Type: VIEW; Schema: public; Owner: nulogy


--
-- Name: VIEW events_conforming_to_cpi; Type: COMMENT; Schema: public; Owner: nulogy


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: expected_order_on_dock_appointments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: expected_order_on_dock_appointments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: expected_pallet_moves_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: expected_pallet_moves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: expected_unit_moves_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: expected_unit_moves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: expiry_date_formats_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: expiry_date_formats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: external_inventory_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: external_inventory_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: external_inventory_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: external_inventory_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: floor_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: floor_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: gl_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: gl_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: gs1_gsin_sequences_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: gs1_gsin_sequences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: gs1_sscc_sequences_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: gs1_sscc_sequences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: icg_item_shelf_lives_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: icg_item_shelf_lives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: icg_reference_data_field_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: icg_reference_data_field_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: icg_reference_data_tables; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 


--
-- Name: icg_reference_data_types_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: icg_reference_data_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: icg_reference_datum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: icg_rule_fragments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: icg_rule_fragments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: icg_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: icg_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: imported_inventories_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: imported_inventories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: inbound_stock_transfer_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: inbound_stock_transfer_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: inbound_stock_transfer_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: inbound_stock_transfer_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: inbound_stock_transfer_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: inbound_stock_transfer_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: inbound_stock_transfer_pallets_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: inbound_stock_transfer_pallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: inbound_stock_transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: inbound_stock_transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: inventory_adjustments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: inventory_adjustments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: inventory_discrepancies_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: inventory_discrepancies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: inventory_snapshot_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: inventory_snapshot_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: inventory_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: inventory_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: inventory_status_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: inventory_status_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: inventory_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: inventory_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: invoice_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: invoice_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: ip_white_list_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: ip_white_list_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: item_carts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: item_carts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: item_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: item_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: item_classes_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: item_classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: item_families_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: item_families_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: item_types_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: item_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: job_lot_expiries_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: job_lot_expiries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: job_reconciliation_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: job_reconciliation_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: job_reconciliation_records_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: job_reconciliation_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: job_reconciliations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: job_reconciliations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: licensing_events_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: licensing_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: lines_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: master_reference_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: master_reference_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: modification_restrictions; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 


--
-- Name: modification_restrictions_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: modification_restrictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: move_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: move_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: moves_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: moves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: outbound_stock_transfer_pallets_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: outbound_stock_transfer_pallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: outbound_stock_transfer_units_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: outbound_stock_transfer_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: outbound_stock_transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: outbound_stock_transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: outbound_trailer_routes_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: outbound_trailer_routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: outbound_trailer_stops_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: outbound_trailer_stops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: outbound_trailers_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: outbound_trailers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: overhead_worksheets_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: overhead_worksheets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: pallet_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: pallet_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: pallet_charge_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: pallet_charge_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: pallet_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: pallet_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: pallet_moves_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: pallet_moves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: pallet_shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: pallet_shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: pallets_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: pallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: priority_configurations; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 


--
-- Name: pick_constraint_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: pick_constraint_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: pick_list_line_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 


--
-- Name: pick_list_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: pick_list_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: pick_list_picks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: pick_list_picks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: pick_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: pick_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: pick_up_picks; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 


--
-- Name: pick_up_picks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: pick_up_picks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: planned_receipt_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 


--
-- Name: planned_receipt_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: planned_receipt_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: planned_receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: planned_receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: planned_shipments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 


--
-- Name: production_archives; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 


--
-- Name: production_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: production_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: productions_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: productions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: project_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: project_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: project_charge_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: project_charge_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: project_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: project_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: qb_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: qb_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: qc_sheet_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: qc_sheet_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: qc_sheets_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: qc_sheets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: qc_template_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: qc_template_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: qc_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: qc_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: quote_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: quote_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: quote_reference_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: quote_reference_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: quoted_bom_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: quoted_bom_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: quotes_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: quotes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: rack_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: rack_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: receipt_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: receipt_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: receipt_item_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: receipt_item_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: receipt_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: receipt_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: receive_order_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: receive_order_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: receive_order_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: receive_order_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: receive_order_item_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: receive_order_item_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: receive_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: receive_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: receive_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: receive_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: reconciliation_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: reconciliation_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: reject_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: reject_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: rejected_item_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: rejected_item_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: rejected_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: rejected_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: required_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: required_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: scenario_attachments; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 


--
-- Name: scenario_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: scenario_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: scenario_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: scenario_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: scenario_loss_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: scenario_loss_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: scenario_to_scenario_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: scenario_to_scenario_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: scenarios_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: scenarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: scheduled_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: scheduled_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: scheduling_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: scheduling_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: scheduling_default_shift_capacities_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: scheduling_default_shift_capacities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: scheduling_line_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: scheduling_line_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: scheduling_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: scheduling_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: scheduling_project_demands_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: scheduling_project_demands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: scheduling_shifts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: scheduling_shifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: selected_items; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 


--
-- Name: selected_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: selected_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: selected_pallets_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: selected_pallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: sequence_generators_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: sequence_generators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: shifts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: shifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: ship_order_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: ship_order_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: ship_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: ship_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: ship_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: ship_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: shipment_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: shipment_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: site_101_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_102_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_103_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_104_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_105_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_106_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_107_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_108_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_109_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_10_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_10_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_110_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_111_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_112_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_113_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_114_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_115_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_116_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_117_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_118_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_119_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_11_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_120_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_121_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_121_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_122_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_123_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_124_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_124_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_125_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_125_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_126_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_126_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_127_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_127_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_128_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_128_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_129_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_129_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_12_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_12_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_130_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_130_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_131_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_131_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_132_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_132_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_133_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_133_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_134_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_134_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_135_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_135_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_136_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_136_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_137_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_137_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_138_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_138_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_139_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_139_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_13_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_13_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_140_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_140_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_141_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_141_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_142_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_142_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_143_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_143_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_144_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_144_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_145_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_145_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_146_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_146_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_147_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_147_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_148_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_148_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_149_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_149_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_14_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_14_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_150_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_150_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_151_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_151_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_152_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_152_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_153_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_153_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_154_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_154_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_155_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_155_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_156_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_156_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_157_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_157_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_158_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_158_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_159_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_159_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_15_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_15_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_160_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_160_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_161_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_161_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_162_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_162_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_163_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_163_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_164_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_164_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_165_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_165_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_166_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_166_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_167_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_167_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_168_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_168_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_169_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_16_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_16_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_170_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_170_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_171_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_171_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_172_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_172_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_173_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_173_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_174_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_174_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_175_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_175_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_176_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_176_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_177_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_177_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_17_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_17_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_18_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_18_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_19_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_19_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_1_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_1_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_20_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_20_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_210_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_210_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_21_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_21_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_22_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_22_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_23_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_23_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_243_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_243_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_244_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_244_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_245_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_245_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_246_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_246_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_247_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_247_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_248_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_248_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_249_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_249_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_24_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_24_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_250_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_250_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_251_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_251_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_252_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_252_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_253_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_253_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_254_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_254_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_255_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_255_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_256_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_256_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_257_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_257_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_258_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_258_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_259_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_259_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_25_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_25_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_260_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_260_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_261_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_261_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_262_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_262_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_263_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_263_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_264_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_264_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_265_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_265_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_266_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_266_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_267_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_267_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_268_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_268_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_269_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_269_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_26_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_26_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_270_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_270_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_271_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_271_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_272_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_272_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_273_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_273_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_274_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_274_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_275_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_275_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_276_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_276_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_277_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_277_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_278_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_278_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_279_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_279_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_27_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_27_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_280_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_280_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_281_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_281_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_282_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_282_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_283_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_283_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_284_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_284_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_285_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_285_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_286_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_286_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_287_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_287_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_28_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_28_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_29_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_29_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_2_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_2_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30327_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30327_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30329_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30329_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30330_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30330_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30332_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30332_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30335_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30335_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30336_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30336_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30337_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30337_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30338_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30338_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30341_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30341_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30342_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30342_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30344_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30344_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30346_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30346_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30347_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30347_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30352_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30352_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30385_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30385_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30386_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30386_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30387_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30387_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30388_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30388_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30389_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30389_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30390_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30390_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30391_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30391_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_30_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_319_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_319_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_31_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_31_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_320_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_320_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_322_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_322_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_323_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_323_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_324_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_324_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_325_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_325_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_326_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_326_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_32_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_32_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_33_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_33_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_34_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_34_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_35_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_35_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_36_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_36_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_37_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_37_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_38_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_38_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_39_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_39_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_3_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_3_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_40_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_40_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_41_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_41_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_42_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_42_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_43_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_43_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_44_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_44_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_45_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_45_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_46_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_46_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_47_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_47_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_48_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_48_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_49_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_49_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_4_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_4_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_50_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_50_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_51_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_51_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_52_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_52_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_53_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_53_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_54_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_54_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_55_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_55_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_56_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_56_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_57_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_57_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_58_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_58_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_59_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_59_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_5_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_5_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_60_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_60_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_61_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_61_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_62_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_62_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_63_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_63_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_66_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_66_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_67_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_67_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_68_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_68_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_69_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_69_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_6_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_6_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_70_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_70_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_71_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_71_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_73_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_73_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_74_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_75_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_76_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_77_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_78_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_79_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_7_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_7_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_80_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_81_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_82_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_83_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_84_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_85_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_86_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_87_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_88_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_89_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_8_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_8_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_90_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_91_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_92_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_93_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_94_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_95_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_96_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_97_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_98_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_99_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_9_bol_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: site_9_pallet_number_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: sites; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 


--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: sku_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: sku_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: skus_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: skus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: subcomponent_consumption_archives; Type: TABLE; Schema: public; Owner: nulogy; Tablespace: 


--
-- Name: subcomponent_consumption_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: subcomponent_consumption_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: subcomponent_consumptions_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: subcomponent_consumptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: time_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: time_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: time_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: time_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: trailer_background_shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: trailer_background_shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: unit_moves_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: unit_moves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: unit_of_measures_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: unit_of_measures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: unit_shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: unit_shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: uom_contexts_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: uom_contexts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: uom_ratios_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: uom_ratios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: vendors_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: vendors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: wage_details_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: wage_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: warehouse_zone_item_classes_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: warehouse_zone_item_classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: warehouse_zones_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: warehouse_zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: wms_allocated_inventory_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: wms_job_staging_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: wms_pick_constraints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: wms_pick_constraints_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: wms_pick_plan_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: wms_planned_shipment_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: wms_planned_shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy


--
-- Name: workdays_id_seq; Type: SEQUENCE; Schema: public; Owner: nulogy


--
-- Name: workdays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nulogy



--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: nulogy; Tablespace: 
ALTER TABLE accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);
ALTER TABLE allowed_accounts
    ADD CONSTRAINT allowed_accounts_pkey PRIMARY KEY (id);
ALTER TABLE allowed_sites
    ADD CONSTRAINT allowed_sites_pkey PRIMARY KEY (id);
ALTER TABLE announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);
ALTER TABLE application_configurations
    ADD CONSTRAINT application_configurations_pkey PRIMARY KEY (id);
ALTER TABLE assembly_item_templates
    ADD CONSTRAINT assembly_item_templates_pkey PRIMARY KEY (id);
ALTER TABLE assembly_steps
    ADD CONSTRAINT assembly_items_pkey PRIMARY KEY (id);
ALTER TABLE assembly_procedures
    ADD CONSTRAINT assembly_procedures_pkey PRIMARY KEY (id);
ALTER TABLE background_tasks
    ADD CONSTRAINT background_jobs_pkey PRIMARY KEY (id);
ALTER TABLE background_report_results
    ADD CONSTRAINT background_query_results_pkey PRIMARY KEY (id);
ALTER TABLE badge_types
    ADD CONSTRAINT badges_pkey PRIMARY KEY (id);
ALTER TABLE barcode_configurations
    ADD CONSTRAINT barcode_configurations_pkey PRIMARY KEY (id);
ALTER TABLE barcode_segments
    ADD CONSTRAINT barcode_segments_pkey PRIMARY KEY (id);
ALTER TABLE bc_snapshot_items
    ADD CONSTRAINT bc_snapshot_items_pkey PRIMARY KEY (id);
ALTER TABLE blind_count_items
    ADD CONSTRAINT blind_count_items_pkey PRIMARY KEY (id);
ALTER TABLE blind_count_rows
    ADD CONSTRAINT blind_count_pallet_rows_pkey PRIMARY KEY (id);
ALTER TABLE blind_counts
    ADD CONSTRAINT blind_counts_pkey PRIMARY KEY (id);
ALTER TABLE bom_items
    ADD CONSTRAINT bom_items_pkey PRIMARY KEY (id);
ALTER TABLE bookmark_users
    ADD CONSTRAINT bookmark_users_pkey PRIMARY KEY (id);
ALTER TABLE bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);
ALTER TABLE breaks
    ADD CONSTRAINT breaks_pkey PRIMARY KEY (id);
ALTER TABLE cancel_pick_up_picks
    ADD CONSTRAINT cancel_pick_up_picks_pkey PRIMARY KEY (id);
ALTER TABLE carriers
    ADD CONSTRAINT carriers_pkey PRIMARY KEY (id);
ALTER TABLE cycle_count_items
    ADD CONSTRAINT cc_adjustment_items_pkey PRIMARY KEY (id);
ALTER TABLE cc_historical_items
    ADD CONSTRAINT cc_historical_items_pkey PRIMARY KEY (id);
ALTER TABLE companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);
ALTER TABLE company_locales
    ADD CONSTRAINT company_locales_pkey PRIMARY KEY (id);
ALTER TABLE consignee_custom_outputs
    ADD CONSTRAINT consignee_custom_outputs_pkey PRIMARY KEY (id);
ALTER TABLE consignees
    ADD CONSTRAINT consignees_pkey PRIMARY KEY (id);
ALTER TABLE consumption_entries
    ADD CONSTRAINT consumption_entries_pkey PRIMARY KEY (id);
ALTER TABLE consumption_plans
    ADD CONSTRAINT consumption_plans_pkey PRIMARY KEY (id);
ALTER TABLE current_inventory_levels
    ADD CONSTRAINT current_inventories_pkey PRIMARY KEY (id);
ALTER TABLE custom_charge_settings
    ADD CONSTRAINT custom_charge_settings_pkey PRIMARY KEY (id);
ALTER TABLE custom_fields
    ADD CONSTRAINT custom_item_fields_pkey PRIMARY KEY (id);
ALTER TABLE custom_output_attachments
    ADD CONSTRAINT custom_output_attachments_pkey PRIMARY KEY (id);
ALTER TABLE custom_output_mappings
    ADD CONSTRAINT custom_output_mappings_pkey PRIMARY KEY (id);
ALTER TABLE custom_outputs
    ADD CONSTRAINT custom_outputs_pkey PRIMARY KEY (id);
ALTER TABLE custom_per_unit_charges
    ADD CONSTRAINT custom_per_unit_charges_pkey PRIMARY KEY (id);
ALTER TABLE custom_project_field_values
    ADD CONSTRAINT custom_project_field_values_pkey PRIMARY KEY (id);
ALTER TABLE custom_project_fields
    ADD CONSTRAINT custom_project_fields_pkey PRIMARY KEY (id);
ALTER TABLE customer_access_configurations
    ADD CONSTRAINT customer_access_configurations_pkey PRIMARY KEY (id);
ALTER TABLE customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);
ALTER TABLE cycle_counts
    ADD CONSTRAINT cycle_counts_pkey PRIMARY KEY (id);
ALTER TABLE inventory_status_configurations
    ADD CONSTRAINT default_inventory_statuses_pkey PRIMARY KEY (id);
ALTER TABLE deleted_entities
    ADD CONSTRAINT deleted_entities_pkey PRIMARY KEY (id);
ALTER TABLE discrepancy_reasons
    ADD CONSTRAINT discrepancy_reasons_pkey PRIMARY KEY (id);
ALTER TABLE dock_appointments
    ADD CONSTRAINT dock_appointments_pkey PRIMARY KEY (id);
ALTER TABLE downtime_reasons
    ADD CONSTRAINT downtime_reasons_pkey PRIMARY KEY (id);
ALTER TABLE edi_customer_triggers
    ADD CONSTRAINT edi_customer_triggers_pkey PRIMARY KEY (id);
ALTER TABLE edi_status_locations
    ADD CONSTRAINT edi_location_properties_pkey PRIMARY KEY (id);
ALTER TABLE edi_logs
    ADD CONSTRAINT edi_logs_pkey PRIMARY KEY (id);
ALTER TABLE edi_mapping_items
    ADD CONSTRAINT edi_mapping_items_pkey PRIMARY KEY (id);
ALTER TABLE edi_mappings
    ADD CONSTRAINT edi_mappings_pkey PRIMARY KEY (id);
ALTER TABLE edi_outbounds
    ADD CONSTRAINT edi_outbounds_pkey PRIMARY KEY (id);
ALTER TABLE edi_configurations
    ADD CONSTRAINT edi_settings_pkey PRIMARY KEY (id);
ALTER TABLE edi_skip_locations
    ADD CONSTRAINT edi_skip_locations_pkey PRIMARY KEY (id);
ALTER TABLE email_domains
    ADD CONSTRAINT email_domains_pkey PRIMARY KEY (id);
ALTER TABLE events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);
ALTER TABLE expected_pallet_moves
    ADD CONSTRAINT expected_move_items_pkey PRIMARY KEY (id);
ALTER TABLE expected_unit_moves
    ADD CONSTRAINT expected_unit_moves_pkey PRIMARY KEY (id);
ALTER TABLE expiry_date_formats
    ADD CONSTRAINT expiry_date_formats_pkey PRIMARY KEY (id);
ALTER TABLE external_inventory_levels
    ADD CONSTRAINT external_inventory_levels_pkey PRIMARY KEY (id);
ALTER TABLE external_inventory_locations
    ADD CONSTRAINT external_inventory_locations_pkey PRIMARY KEY (id);
ALTER TABLE floor_locations
    ADD CONSTRAINT floor_locations_pkey PRIMARY KEY (id);
ALTER TABLE gl_accounts
    ADD CONSTRAINT gl_accounts_pkey PRIMARY KEY (id);
ALTER TABLE gs1_gsin_sequences
    ADD CONSTRAINT gsin_sequences_pkey PRIMARY KEY (id);
ALTER TABLE item_shelf_lives
    ADD CONSTRAINT icg_item_shelf_lives_pkey PRIMARY KEY (id);
ALTER TABLE icg_reference_data_fields
    ADD CONSTRAINT icg_reference_data_field_infos_pkey PRIMARY KEY (id);
ALTER TABLE icg_reference_data_tables
    ADD CONSTRAINT icg_reference_data_types_pkey PRIMARY KEY (id);
ALTER TABLE icg_reference_data_rows
    ADD CONSTRAINT icg_reference_datum_pkey PRIMARY KEY (id);
ALTER TABLE icg_rule_fragments
    ADD CONSTRAINT icg_rule_fragments_pkey PRIMARY KEY (id);
ALTER TABLE icg_rules
    ADD CONSTRAINT icg_rules_pkey PRIMARY KEY (id);
ALTER TABLE imported_inventories
    ADD CONSTRAINT imported_inventories_pkey PRIMARY KEY (id);
ALTER TABLE edi_inbounds
    ADD CONSTRAINT inbound_edis_pkey PRIMARY KEY (id);
ALTER TABLE inbound_stock_transfer_items
    ADD CONSTRAINT inbound_stock_transfer_items_pkey PRIMARY KEY (id);
ALTER TABLE inbound_stock_transfer_order_items
    ADD CONSTRAINT inbound_stock_transfer_order_items_pkey PRIMARY KEY (id);
ALTER TABLE inbound_stock_transfer_orders
    ADD CONSTRAINT inbound_stock_transfer_orders_pkey PRIMARY KEY (id);
ALTER TABLE inbound_stock_transfer_pallets
    ADD CONSTRAINT inbound_stock_transfer_pallets_pkey PRIMARY KEY (id);
ALTER TABLE inbound_stock_transfers
    ADD CONSTRAINT inbound_stock_transfers_pkey PRIMARY KEY (id);
ALTER TABLE inventory_adjustments
    ADD CONSTRAINT inventory_adjustments_pkey PRIMARY KEY (id);
ALTER TABLE inventory_discrepancies
    ADD CONSTRAINT inventory_discrepancies_pkey PRIMARY KEY (id);
ALTER TABLE inventory_snapshot_schedules
    ADD CONSTRAINT inventory_snapshot_schedules_pkey PRIMARY KEY (id);
ALTER TABLE inventory_snapshots
    ADD CONSTRAINT inventory_snapshots_pkey PRIMARY KEY (id);
ALTER TABLE inventory_statuses
    ADD CONSTRAINT inventory_statuses_pkey PRIMARY KEY (id);
ALTER TABLE invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);
ALTER TABLE invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);
ALTER TABLE ip_white_list_entries
    ADD CONSTRAINT ip_white_list_entries_pkey PRIMARY KEY (id);
ALTER TABLE item_carts
    ADD CONSTRAINT item_carts_pkey PRIMARY KEY (id);
ALTER TABLE item_categories
    ADD CONSTRAINT item_categories_pkey PRIMARY KEY (id);
ALTER TABLE item_classes
    ADD CONSTRAINT item_classes_pkey PRIMARY KEY (id);
ALTER TABLE item_families
    ADD CONSTRAINT item_families_pkey PRIMARY KEY (id);
ALTER TABLE item_types
    ADD CONSTRAINT item_types_pkey PRIMARY KEY (id);
ALTER TABLE job_lot_expiries
    ADD CONSTRAINT job_lot_expiries_pkey PRIMARY KEY (id);
ALTER TABLE job_reconciliation_counts
    ADD CONSTRAINT job_reconciliation_counts_pkey PRIMARY KEY (id);
ALTER TABLE job_reconciliation_records
    ADD CONSTRAINT job_reconciliation_records_pkey PRIMARY KEY (id);
ALTER TABLE job_reconciliations
    ADD CONSTRAINT job_reconciliations_pkey PRIMARY KEY (id);
ALTER TABLE jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);
ALTER TABLE licensing_events
    ADD CONSTRAINT licensing_events_pkey PRIMARY KEY (id);
ALTER TABLE lines
    ADD CONSTRAINT lines_pkey PRIMARY KEY (id);
ALTER TABLE locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);
ALTER TABLE master_reference_documents
    ADD CONSTRAINT master_reference_documents_pkey PRIMARY KEY (id);
ALTER TABLE modification_restrictions
    ADD CONSTRAINT modification_restrictions_pkey PRIMARY KEY (id);
ALTER TABLE pallet_moves
    ADD CONSTRAINT move_items_pkey PRIMARY KEY (id);
ALTER TABLE pick_plans
    ADD CONSTRAINT move_orders_pkey PRIMARY KEY (id);
ALTER TABLE moves
    ADD CONSTRAINT moves_pkey PRIMARY KEY (id);
ALTER TABLE notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);
ALTER TABLE outbound_stock_transfer_pallets
    ADD CONSTRAINT outbound_pallet_stock_transfer_items_pkey PRIMARY KEY (id);
ALTER TABLE outbound_stock_transfer_units
    ADD CONSTRAINT outbound_stock_transfer_items_pkey PRIMARY KEY (id);
ALTER TABLE outbound_stock_transfers
    ADD CONSTRAINT outbound_stock_transfers_pkey PRIMARY KEY (id);
ALTER TABLE expected_order_on_dock_appointments
    ADD CONSTRAINT outbound_trailer_plan_items_pkey PRIMARY KEY (id);
ALTER TABLE outbound_trailer_routes
    ADD CONSTRAINT outbound_trailer_routes_pkey PRIMARY KEY (id);
ALTER TABLE outbound_trailer_stops
    ADD CONSTRAINT outbound_trailer_stops_pkey PRIMARY KEY (id);
ALTER TABLE outbound_trailers
    ADD CONSTRAINT outbound_trailers_pkey PRIMARY KEY (id);
ALTER TABLE overhead_worksheets
    ADD CONSTRAINT overhead_worksheets_pkey PRIMARY KEY (id);
ALTER TABLE pallet_assignments
    ADD CONSTRAINT pallet_assignments_pkey PRIMARY KEY (id);
ALTER TABLE pallet_charge_settings
    ADD CONSTRAINT pallet_charge_settings_pkey PRIMARY KEY (id);
ALTER TABLE pallet_charges
    ADD CONSTRAINT pallet_charges_pkey PRIMARY KEY (id);
ALTER TABLE pallets
    ADD CONSTRAINT pallets_pkey PRIMARY KEY (id);
ALTER TABLE priority_configurations
    ADD CONSTRAINT pick_constraint_templates_pkey PRIMARY KEY (id);
ALTER TABLE pick_list_line_items
    ADD CONSTRAINT pick_list_line_items_pkey PRIMARY KEY (id);
ALTER TABLE pick_list_picks
    ADD CONSTRAINT pick_list_picks_pkey PRIMARY KEY (id);
ALTER TABLE drop_off_picks
    ADD CONSTRAINT pick_list_unit_picks_pkey PRIMARY KEY (id);
ALTER TABLE pick_lists
    ADD CONSTRAINT pick_lists_pkey PRIMARY KEY (id);
ALTER TABLE pick_up_picks
    ADD CONSTRAINT pick_up_picks_pkey PRIMARY KEY (id);
ALTER TABLE planned_receipt_items
    ADD CONSTRAINT planned_receipt_items_pkey PRIMARY KEY (id);
ALTER TABLE planned_receipts
    ADD CONSTRAINT planned_receipts_pkey PRIMARY KEY (id);
ALTER TABLE production_archives
    ADD CONSTRAINT production_archives_pkey PRIMARY KEY (id);
ALTER TABLE productions
    ADD CONSTRAINT productions_pkey PRIMARY KEY (id);
ALTER TABLE project_attachments
    ADD CONSTRAINT project_attachments_pkey PRIMARY KEY (id);
ALTER TABLE project_charge_settings
    ADD CONSTRAINT project_charge_settings_pkey PRIMARY KEY (id);
ALTER TABLE project_charges
    ADD CONSTRAINT project_charges_pkey PRIMARY KEY (id);
ALTER TABLE projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);
ALTER TABLE qb_logs
    ADD CONSTRAINT qb_logs_pkey PRIMARY KEY (id);
ALTER TABLE qc_template_items
    ADD CONSTRAINT qc_template_items_pkey PRIMARY KEY (id);
ALTER TABLE qc_sheet_items
    ADD CONSTRAINT quality_control_checks_pkey PRIMARY KEY (id);
ALTER TABLE qc_sheets
    ADD CONSTRAINT quality_control_sheets_pkey PRIMARY KEY (id);
ALTER TABLE qc_templates
    ADD CONSTRAINT quality_control_templates_pkey PRIMARY KEY (id);
ALTER TABLE quote_attachments
    ADD CONSTRAINT quote_attachments_pkey PRIMARY KEY (id);
ALTER TABLE quote_reference_documents
    ADD CONSTRAINT quote_reference_documents_pkey PRIMARY KEY (id);
ALTER TABLE quoted_bom_items
    ADD CONSTRAINT quoted_bom_items_pkey PRIMARY KEY (id);
ALTER TABLE quotes
    ADD CONSTRAINT quotes_pkey PRIMARY KEY (id);
ALTER TABLE rack_locations
    ADD CONSTRAINT rack_locations_pkey PRIMARY KEY (id);
ALTER TABLE receipt_attachments
    ADD CONSTRAINT receipt_attachments_pkey PRIMARY KEY (id);
ALTER TABLE receipt_item_logs
    ADD CONSTRAINT receipt_item_logs_pkey PRIMARY KEY (id);
ALTER TABLE receipt_items
    ADD CONSTRAINT receipt_items_pkey PRIMARY KEY (id);
ALTER TABLE receipts
    ADD CONSTRAINT receipts_pkey PRIMARY KEY (id);
ALTER TABLE receive_order_archives
    ADD CONSTRAINT receive_order_archives_pkey PRIMARY KEY (id);
ALTER TABLE receive_order_attachments
    ADD CONSTRAINT receive_order_attachments_pkey PRIMARY KEY (id);
ALTER TABLE receive_order_item_archives
    ADD CONSTRAINT receive_order_item_archives_pkey PRIMARY KEY (id);
ALTER TABLE receive_order_items
    ADD CONSTRAINT receive_order_items_pkey PRIMARY KEY (id);
ALTER TABLE receive_orders
    ADD CONSTRAINT receive_orders_pkey PRIMARY KEY (id);
ALTER TABLE reconciliation_reasons
    ADD CONSTRAINT reconciliation_reasons_pkey PRIMARY KEY (id);
ALTER TABLE reject_reasons
    ADD CONSTRAINT reject_reasons_pkey PRIMARY KEY (id);
ALTER TABLE rejected_item_archives
    ADD CONSTRAINT rejected_item_archives_pkey PRIMARY KEY (id);
ALTER TABLE rejected_items
    ADD CONSTRAINT rejected_items_pkey PRIMARY KEY (id);
ALTER TABLE required_items
    ADD CONSTRAINT required_move_items_pkey PRIMARY KEY (id);
ALTER TABLE scenario_attachments
    ADD CONSTRAINT scenario_attachments_pkey PRIMARY KEY (id);
ALTER TABLE scenario_charges
    ADD CONSTRAINT scenario_charges_pkey PRIMARY KEY (id);
ALTER TABLE scenario_loss_reasons
    ADD CONSTRAINT scenario_loss_reasons_pkey PRIMARY KEY (id);
ALTER TABLE scenario_to_scenario_attachments
    ADD CONSTRAINT scenario_to_scenario_attachments_pkey PRIMARY KEY (id);
ALTER TABLE scenarios
    ADD CONSTRAINT scenarios_pkey PRIMARY KEY (id);
ALTER TABLE scheduled_tasks
    ADD CONSTRAINT scheduled_tasks_pkey PRIMARY KEY (id);
ALTER TABLE scheduling_blocks
    ADD CONSTRAINT scheduling_blocks_pkey PRIMARY KEY (id);
ALTER TABLE scheduling_default_shift_capacities
    ADD CONSTRAINT scheduling_default_shift_capacities_pkey PRIMARY KEY (id);
ALTER TABLE scheduling_line_assignments
    ADD CONSTRAINT scheduling_line_assignments_pkey PRIMARY KEY (id);
ALTER TABLE scheduling_lines
    ADD CONSTRAINT scheduling_lines_pkey PRIMARY KEY (id);
ALTER TABLE scheduling_project_demands
    ADD CONSTRAINT scheduling_project_demands_pkey PRIMARY KEY (id);
ALTER TABLE scheduling_shifts
    ADD CONSTRAINT scheduling_shifts_pkey PRIMARY KEY (id);
ALTER TABLE selected_items
    ADD CONSTRAINT selected_items_pkey PRIMARY KEY (id);
ALTER TABLE selected_pallets
    ADD CONSTRAINT selected_pallets_pkey PRIMARY KEY (id);
ALTER TABLE sequence_generators
    ADD CONSTRAINT sequence_generators_pkey PRIMARY KEY (id);
ALTER TABLE sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);
ALTER TABLE shifts
    ADD CONSTRAINT shifts_pkey PRIMARY KEY (id);
ALTER TABLE ship_order_attachments
    ADD CONSTRAINT ship_order_attachments_pkey PRIMARY KEY (id);
ALTER TABLE ship_order_items
    ADD CONSTRAINT ship_order_items_pkey PRIMARY KEY (id);
ALTER TABLE ship_orders
    ADD CONSTRAINT ship_orders_pkey PRIMARY KEY (id);
ALTER TABLE shipment_attachments
    ADD CONSTRAINT shipment_attachments_pkey PRIMARY KEY (id);
ALTER TABLE pallet_shipments
    ADD CONSTRAINT shipment_items_pkey PRIMARY KEY (id);
ALTER TABLE shipments
    ADD CONSTRAINT shipments_pkey PRIMARY KEY (id);
ALTER TABLE sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);
ALTER TABLE sku_attachments
    ADD CONSTRAINT sku_attachments_pkey PRIMARY KEY (id);
ALTER TABLE skus
    ADD CONSTRAINT skus_pkey PRIMARY KEY (id);
ALTER TABLE gs1_sscc_sequences
    ADD CONSTRAINT sscc_sequences_pkey PRIMARY KEY (id);
ALTER TABLE subcomponent_consumption_archives
    ADD CONSTRAINT subcomponent_consumption_archives_pkey PRIMARY KEY (id);
ALTER TABLE subcomponent_consumptions
    ADD CONSTRAINT subcomponent_consumptions_pkey PRIMARY KEY (id);
ALTER TABLE time_cards
    ADD CONSTRAINT time_cards_pkey PRIMARY KEY (id);
ALTER TABLE time_reports
    ADD CONSTRAINT time_reports_pkey PRIMARY KEY (id);
ALTER TABLE trailer_background_shipments
    ADD CONSTRAINT trailer_background_shipments_pkey PRIMARY KEY (id);
ALTER TABLE unit_moves
    ADD CONSTRAINT unit_moves_pkey PRIMARY KEY (id);
ALTER TABLE uom_ratios
    ADD CONSTRAINT unit_of_measures_pkey PRIMARY KEY (id);
ALTER TABLE unit_of_measures
    ADD CONSTRAINT unit_of_measures_pkey1 PRIMARY KEY (id);
ALTER TABLE unit_shipments
    ADD CONSTRAINT unit_shipments_pkey PRIMARY KEY (id);
ALTER TABLE uom_contexts
    ADD CONSTRAINT uom_contexts_pkey PRIMARY KEY (id);
ALTER TABLE users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
ALTER TABLE vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);
ALTER TABLE wage_details
    ADD CONSTRAINT wage_details_pkey PRIMARY KEY (id);
ALTER TABLE zoning_rules
    ADD CONSTRAINT warehouse_zone_item_classes_pkey PRIMARY KEY (id);
ALTER TABLE warehouse_zones
    ADD CONSTRAINT warehouse_zones_pkey PRIMARY KEY (id);
ALTER TABLE reserved_inventory_levels
    ADD CONSTRAINT wms_allocated_inventory_levels_pkey PRIMARY KEY (id);
ALTER TABLE staging_locations
    ADD CONSTRAINT wms_job_staging_locations_pkey PRIMARY KEY (id);
ALTER TABLE picked_inventory
    ADD CONSTRAINT wms_pick_constraints_pkey PRIMARY KEY (id);
ALTER TABLE pick_constraints
    ADD CONSTRAINT wms_pick_constraints_pkey1 PRIMARY KEY (id);
ALTER TABLE pick_plan_items
    ADD CONSTRAINT wms_pick_plan_items_pkey PRIMARY KEY (id);
ALTER TABLE planned_shipment_items
    ADD CONSTRAINT wms_planned_shipment_items_pkey PRIMARY KEY (id);
ALTER TABLE planned_shipments
    ADD CONSTRAINT wms_planned_shipments_pkey PRIMARY KEY (id);
ALTER TABLE workdays
    ADD CONSTRAINT workdays_pkey PRIMARY KEY (id);
