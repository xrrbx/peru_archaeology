with source as (

    select * from {{ source('peru_archaeo_rc_dataset', 'rejected_dates') }}

),

renamed as (

    select
        "rejected" as date_status,
        site_name,
        country_dept,
        split(country_dept, ',')[safe_offset(0)] as country,
        trim(split(country_dept, ',')[safe_offset(1)]) as department,
        ecoregion,
        ecoregion_nsa,
        latitude,
        longitude,
        elevation,
        coordinate_source,
        lab_code,
        method_of_sample_analysis,
        material_dated,
        safe_cast(replace(c14_bp, '>', '') as int64) as c14_bp,
        sigma,
        c13,
        collagen_yield_pct_mass,
        marine20_68_pct,
        marine20_95_pct,
        shcal20_68_pct,
        shcal20_95_pct,
        
        -- 1. Coalesce to choose whichever 95% curve is populated
        coalesce(shcal20_95_pct, marine20_95_pct) as calibrated_range_95,

        -- 2. DEFENSIVE CASTING: Using safe_cast handles "no data" strings beautifully by returning NULL instead of crashing
        safe_cast(split(coalesce(shcal20_95_pct, marine20_95_pct), '-')[safe_offset(0)] as int64) as cal_bp_start,
        safe_cast(split(coalesce(shcal20_95_pct, marine20_95_pct), '-')[safe_offset(1)] as int64) as cal_bp_end,

        year_published,
        is_in_2013_db,
        sample_provenience,
        context,
        notes_on_dated_sample,
        site_type,
        associated_material,
        paleoconomy,
        paleoenvironment,
        cultural_affiliation,
        accepted_rejected,
        problems_reason_for_exclusion,
        date_references

    from source

)

select * from renamed
where lab_code is not null
