with accepted as (

    select 
        date_status,
        site_name,
        country,
        department,
        ecoregion,
        latitude,
        longitude,
        elevation,
        lab_code,
        material_dated,
        c14_bp,
        sigma,
        cultural_affiliation,
        problems_reason_for_exclusion,
        date_references,
        cal_bp_start,
        cal_bp_end
    from {{ ref('stg_accepted_dates') }}

),

rejected as (
    select 
        date_status,
        site_name,
        country,
        department,
        ecoregion,
        latitude,
        longitude,
        elevation,
        lab_code,
        material_dated,
        c14_bp,
        sigma,
        cultural_affiliation,
        problems_reason_for_exclusion,
        date_references,
        cal_bp_start,
        cal_bp_end
    from {{ ref('stg_rejected_dates') }}

),

unioned as (

    select * from accepted
    union all
    select * from rejected

),

final_calculations as (

    select
        *,
        -- 1. Calculate the midpoint of the calibrated BP range (handling nulls gracefully)
        (cal_bp_start + cal_bp_end) / 2 as mean_cal_bp,

        -- 2. Add 76 years to convert Calibrated BP (referenced to 1950) to real-world Years Old Today (2026)
        ((cal_bp_start + cal_bp_end) / 2) + 76 as mean_calendar_age_years
        
    from unioned

)

select * from final_calculations