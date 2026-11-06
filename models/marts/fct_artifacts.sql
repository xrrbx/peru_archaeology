with stg_radiocarbon as (

    select * 
    from {{ ref('stg_south_america_radiocarbon') }}

),

calculated_dates as (

    select
        *,
        -- 1. Convert BP to Gregorian Calendar Year (BP 0 = 1950 CE)
        (1950 - cast(age as int64)) as cal_year

    from stg_radiocarbon

),

derived_centuries as (

    select
        *,
        -- 2. Derive continuous Integer Century Number for Looker Studio Sliders
        -- BCE: year -550 -> 6th c. BCE -> -6
        -- CE:  year 350  -> 4th c. CE  -> +4
        case
            when cal_year <= 0 then -1 * cast(ceil(abs(cal_year - 1) / 100.0) as int64)
            else cast(ceil(cal_year / 100.0) as int64)
        end as century_number

    from calculated_dates

),

formatted as (

    select
        labid as lab_id,
        age,
        error,
        material,
        taxa,
        d13c,
        method,
        long as longitude,
        lat as latitude,
        concat(lat, ', ', long) as coordinates,
        locaccuracy,
        period,
        siteid as site_id,
        sitename as site_name,
        country,
        province,
        continent,
        source,
        reference as bibliographic_reference,

        cal_year,
        century_number,

        -- 3. Formatted display string for dashboard tooltips/labels
        case
            when cal_year <= 0 then
                concat(
                    cast(abs(century_number) as string),
                    case 
                        when abs(century_number) in (11, 12, 13) then 'th'
                        when mod(abs(century_number), 10) = 1 then 'st'
                        when mod(abs(century_number), 10) = 2 then 'nd'
                        when mod(abs(century_number), 10) = 3 then 'rd'
                        else 'th'
                    end,
                    ' century BCE'
                )
            else
                concat(
                    cast(century_number as string),
                    case 
                        when century_number in (11, 12, 13) then 'th'
                        when mod(century_number, 10) = 1 then 'st'
                        when mod(century_number, 10) = 2 then 'nd'
                        when mod(century_number, 10) = 3 then 'rd'
                        else 'th'
                    end,
                    ' century CE'
                )
        end as century_display

    from derived_centuries

)

select * 
from formatted