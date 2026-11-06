with source as (

    select * from {{ source('peru_archaeo_rc_dataset', 'raw_south_america_radiocarbon') }}

),

renamed as (

    select
        labid,
        age,
        error,
        material,
        taxa,
        d13c,
        method,
        long,
        lat,
        locaccuracy,
        period,
        siteid,
        sitename,
        country,
        province,
        continent,
        source,
        reference

    from source

)

select * from renamed