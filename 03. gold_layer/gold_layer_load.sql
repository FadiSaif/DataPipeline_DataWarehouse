/*
============================================================================
Gold Layer LOAD — Option 3: Header Dimension + Line Fact (SAR-Normalized)

Database:    sales_DataWarehouse
Schema:      gold
Description: Populates the gold star schema tables from the silver layer.
             Includes full text parsing & classification of products:
               - Vehicle Make & Model (main_group)
               - Origin / Quality: Genuine, Korean, Chinese, Other (sub_group)
               - Normalized Part Category (category)
               - Vehicle System Classification (classification_key)

Load order:
  1. dim_date          (generated date series 2023-2030)
  2. dim_product       (classified from silver.stock_item)
  3. dim_customer      (from silver.sales_order_header)
  4. dim_currency      (from silver.gl_currency)
  5. dim_sales_center  (from silver.sales_order_header)
  6. dim_sales_order   (from silver.sales_order_header)
  7. fact_sales        (from silver.sales_order_detail + dimensions)

Currency Conversion to SAR:
    CASE
        WHEN TRIM(currency) = '01' THEN 0.002421307506053   -- YER → SAR
        WHEN TRIM(currency) = '02' THEN 3.8                  -- USD → SAR
        ELSE 1                                                -- SAR (03 or blank)
    END
============================================================================
*/


-- ============================================================================
-- 1. Load dim_date (2023-01-01 through 2030-12-31)
-- ============================================================================
TRUNCATE TABLE gold.dim_date CASCADE;

INSERT INTO gold.dim_date (date_key, full_date, year, quarter, month, day, month_name, day_name, is_weekend)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER         AS date_key,
    d                                        AS full_date,
    EXTRACT(YEAR FROM d)::SMALLINT           AS year,
    EXTRACT(QUARTER FROM d)::SMALLINT        AS quarter,
    EXTRACT(MONTH FROM d)::SMALLINT          AS month,
    EXTRACT(DAY FROM d)::SMALLINT            AS day,
    TO_CHAR(d, 'FMMonth')                    AS month_name,
    TO_CHAR(d, 'FMDay')                      AS day_name,
    EXTRACT(ISODOW FROM d) IN (6, 7)         AS is_weekend
FROM GENERATE_SERIES('2023-01-01'::DATE, '2030-12-31'::DATE, '1 day'::INTERVAL) AS d;


-- ============================================================================
-- 2. Load dim_product (Classified from silver.stock_item)
-- ============================================================================
TRUNCATE TABLE gold.dim_product CASCADE;

INSERT INTO gold.dim_product (
    item_code, 
    item_name, 
    item_name_alt, 
    main_group, 
    sub_group, 
    category, 
    classification_key, 
    item_type
)
SELECT
    clean.item_code,
    clean.item_name,
    clean.item_name_alt,
    
    -- 1. Vehicle Make & Model (main_group)
    CASE
        WHEN clean.is_dummy THEN 'General / Non-Automotive'
        WHEN clean.text ~* '(سوناتا|سوناتة|sonata|\m3s\M|\mc1\M)' THEN 'Hyundai Sonata'
        WHEN clean.text ~* '(النترا|النتراء|النتراة|elantra|افانتي|أفانتي|avante|\m2h\M|\m3x\M|\mf2\M|\mad\M|\mmd\M|\mhd\M)' THEN 'Hyundai Elantra'
        WHEN clean.text ~* '(اكسنت|أكسنت|accent|فيرنا|verna|\m1r\M|\m4l\M|\mmc\M|\mrb\M)' THEN 'Hyundai Accent'
        WHEN clean.text ~* '(توسان|تكسون|tucson|\m2e\M|\m2s\M|\md3\M|\mnx4\M)' THEN 'Hyundai Tucson'
        WHEN clean.text ~* '(سنتافي|سنتافى|سانتافي|santa fe|santafe|\m2b\M|\m2w\M|\mtm\M)' THEN 'Hyundai Santa Fe'
        WHEN clean.text ~* '(ازيرا|أزيرا|azera|جراندور|grandeur|\m3l\M|\m3c\M|\mhg\M|\mig\M)' THEN 'Hyundai Azera'
        WHEN clean.text ~* '(كريتا|creta)' THEN 'Hyundai Creta'
        WHEN clean.text ~* '(فيراكروز|veracruz)' THEN 'Hyundai Veracruz'
        WHEN clean.text ~* '(ماتركس|ماتريكس|matrix)' THEN 'Hyundai Matrix'
        WHEN clean.text ~* '(جتز|جيتز|getz)' THEN 'Hyundai Getz'
        WHEN clean.text ~* '(اتوز|أتوز|atos)' THEN 'Hyundai Atos'
        WHEN clean.text ~* '(تراجيت|trajet)' THEN 'Hyundai Trajet'
        WHEN clean.text ~* '(تركان|terracan)' THEN 'Hyundai Terracan'
        WHEN clean.text ~* '(جينيسيس|genesis)' THEN 'Genesis'
        WHEN clean.text ~* '(استاركس|ستاركس|starex|اتش ون|اتش1|\mh1\M|باص)' THEN 'Hyundai H1 / Starex'
        WHEN clean.text ~* '(اتش 100|\mh100\M|بورتر|porter|دينة|دينا)' THEN 'Hyundai H100 / Porter'
        WHEN clean.text ~* '\mi10\M' THEN 'Hyundai i10'
        WHEN clean.text ~* '\mi20\M' THEN 'Hyundai i20'
        WHEN clean.text ~* '\mi30\M' THEN 'Hyundai i30'
        WHEN clean.text ~* '\mi40\M' THEN 'Hyundai i40'
        WHEN clean.text ~* '(كونا|kona)' THEN 'Hyundai Kona'
        WHEN clean.text ~* '(باليسيد|palisade)' THEN 'Hyundai Palisade'
        WHEN clean.text ~* '(فيلوستر|veloster)' THEN 'Hyundai Veloster'
        WHEN clean.text ~* '(اوبتيما|اوبتما|أوبتيما|optima|\mk5\M|كيا 5)' THEN 'Kia Optima / K5'
        WHEN clean.text ~* '(سيراتو|cerato|forte|\mk3\M)' THEN 'Kia Cerato'
        WHEN clean.text ~* '(سبورتاج|سبورتج|sportage)' THEN 'Kia Sportage'
        WHEN clean.text ~* '(سورينتو|سورنتو|sorento)' THEN 'Kia Sorento'
        WHEN clean.text ~* '(سول|كياسول|soul)' THEN 'Kia Soul'
        WHEN clean.text ~* '(ريو|rio)' THEN 'Kia Rio'
        WHEN clean.text ~* '(بيكانتو|بيكاندو|picanto)' THEN 'Kia Picanto'
        WHEN clean.text ~* '(كادينزا|كدينزا|cadenza|\mk7\M)' THEN 'Kia Cadenza'
        WHEN clean.text ~* '(كرنفال|كارنفال|carnival|sedona)' THEN 'Kia Carnival'
        WHEN clean.text ~* '(موهافي|mohave)' THEN 'Kia Mohave'
        WHEN clean.text ~* '(سيلتوس|seltos)' THEN 'Kia Seltos'
        WHEN clean.text ~* '(كارينز|كارنس|carens)' THEN 'Kia Carens'
        WHEN clean.text ~* '(كيا|kia)' THEN 'Kia (General)'
        WHEN clean.text ~* '(هونداي|هيونداي|hyundai)' THEN 'Hyundai (General)'
        WHEN clean.text ~* '(تويوتا|toyota)' THEN 'Toyota'
        WHEN clean.text ~* '(نيسان|داتسون|nissan)' THEN 'Nissan'
        WHEN clean.text ~* '(هوندا|honda)' THEN 'Honda'
        WHEN clean.text ~* '(ميتسوبيشي|mitsubishi)' THEN 'Mitsubishi'
        WHEN clean.text ~* '(كليبسات|كلبسات|زيت|شحم|فيوز|غراء|صمغ|لمبات)' THEN 'Universal / Consumables'
        ELSE 'Hyundai / Kia (Universal)'
    END AS main_group,

    -- 2. Origin / Quality (sub_group)
    CASE
        WHEN clean.is_dummy THEN 'Other'
        WHEN clean.clean_code ~ '.*(K|K-G|-K)$' OR clean.text ~* '(كوري|كورية|ctr|mando|ondo|korea)' THEN 'Korean'
        WHEN clean.clean_code ~ '.*(C|-C)$' OR clean.text ~* '(صيني|صينيه|china|تجين)' THEN 'Chinese'
        WHEN clean.clean_code ~ '.*(BSF|TIA|T|J|G|DDU|DD-)$' OR clean.text ~* '(تايوان|ياباني|الماني|امريكي|ماليزي|اندونيسي|koyo)' THEN 'Other'
        WHEN clean.clean_code ~ '.*(M|A)$' OR clean.text ~* '(وكالة|وكاله|اصلي|أصلي|genuine|mobis|موبيس)' THEN 'Genuine'
        WHEN clean.clean_code ~ '^\d{5}-[0-9A-Za-z]{5}$' THEN 'Genuine'
        ELSE 'Other'
    END AS sub_group,

    -- 3. Part Category (category)
    CASE
        WHEN clean.is_dummy THEN 'Unspecified / Placeholder'
        WHEN clean.text ~* '(مقص|مقصات)' AND clean.text !~* '(بوش|ربل|جلب)' THEN 'Control Arm / مقصات'
        WHEN clean.text ~* '(بوش|بوشة|بوشات|جلب مقص|جلبه مقص)' THEN 'Control Arm Bushing / بوشات مقص'
        WHEN clean.text ~* '(مسمار توازن|عمود توازن|مسمار عمود توازن|توازن)' AND clean.text !~* '(ربل|بوش)' THEN 'Sway Bar Link / مسامير توازن'
        WHEN clean.text ~* '(ربل.*توازن|ربلة.*توازن)' THEN 'Sway Bar Bushing / ربلات توازن'
        WHEN clean.text ~* '(مساعد|مساعدات|ياي|سبرنج|مساعد كبوت|مساعد شنطة)' AND clean.text !~* '(كرسي مساعد|قاعدة مساعد)' THEN 'Shock Absorber & Strut / مساعدات'
        WHEN clean.text ~* '(كرسي مساعد|قاعدة مساعد|ربلة مساعد|كراسي مساعد)' THEN 'Strut Mount / كراسي مساعد'
        WHEN clean.text ~* '(جوزة|ركبة مقص|جوز مقص|جوز)' THEN 'Ball Joint / جوز مقص'
        WHEN clean.text ~* '(مشرعة|مشرعه|ذراع سكان|ذراع دركسون|أذرعة|اذرعة|بيضة دركسون)' THEN 'Tie Rod End / أذرعة سكان'
        WHEN clean.text ~* '(دودة|دوده|علبة سكان|طرمبة سكان|سكان|دركسون)' THEN 'Steering Rack & Pump / دودة وطرمبة سكان'
        WHEN clean.text ~* '(كنويسات|كنوسات|فحمات|براصات|قماشات|قماش بريك|بريك|فرامل)' AND clean.text !~* '(هوب|لي بريك|لي سم)' THEN 'Brake Pads & Shoes / فحمات وقماشات فرامل'
        WHEN clean.text ~* '(هوب|هوبات|ديسك فرامل)' THEN 'Brake Rotors / هوبات فرامل'
        WHEN clean.text ~* '(كليبر|سلندر بريك|سلندر فرامل|مكبس فرامل)' THEN 'Brake Caliper & Cylinder / كليبر وسلندر فرامل'
        WHEN clean.text ~* '(لي سم بريك|لي بريك|لي فرامل|هوز فرامل)' THEN 'Brake Hose & Pipe / ليات وهوزات فرامل'
        WHEN clean.text ~* '(عكس|عكوس|ركبة عكس|ركبه عكس|صبيرة|صبرة عكس|كوبلن|كواشين عكس|كوانش عكس)' THEN 'CV Axle & Joint / عكوس وركب عكس'
        WHEN clean.text ~* '(صليب|صليبة|عمود كردان)' THEN 'Driveshaft U-Joint / صلايب عمود دوران'
        WHEN clean.text ~* '(صحن كلتش|ديسك كلتش|فحمة كلتش|كلتش|طنجرة قير|فلتر قير)' THEN 'Clutch & Transmission / كلتش وقير'
        WHEN clean.text ~* '(بيرنج|فلنجة|فلنجه|فلنجات|رمان بلي|رمان عجلة)' THEN 'Wheel Hub & Bearing / فلنجات وبيرنجات'
        WHEN clean.text ~* '(كرسي مكينة|كرسي قير|كرسي جير|كراسي مكينة|ربلة قير)' THEN 'Engine & Transmission Mount / كراسي محرك وقير'
        WHEN clean.text ~* '(سير دينمو|سير مروحة|بطة|سير مكينة|سيور|شداد|بكرة شداد|مكرة|\mpk\M)' THEN 'Drive Belt & Tensioner / سيور وبكرات وشدادات'
        WHEN clean.text ~* '(تيمت|جنزير|سير تيمت|طقم تيمت|جنزير صدر)' THEN 'Timing Belt & Chain / سيور وجنازير تيمت'
        WHEN clean.text ~* '(باكن|وجوه|وجه راس|صوفة|صوفه|صوف|كسكيت|سيلات|ربلات صباب)' THEN 'Gaskets & Oil Seals / باكنات وصوف وسيلات'
        WHEN clean.text ~* '(بستن|بساتم|شنابر|سبايك|كرنك|عمود كرنك|بلوف|صبابات|مكينة)' THEN 'Engine Internal Components / أجزاء المحرك الداخلية'
        WHEN clean.text ~* '(طرمبة ماء|طرمبه ماء|بمب ماء|مضخة ماء)' THEN 'Water Pump / طرمبات ماء'
        WHEN clean.text ~* '(كوع ماء|كوع بيسة|بلف حرارة|ترموستات|بيسة ماء|قاعدة كوع|بيسة)' THEN 'Thermostat & Water Outlet / أكواع وبلوف حرارة'
        WHEN clean.text ~* '(رديتر|لديتر|مبرد ماء|غطاء رديتر|طبة ماء)' THEN 'Radiator & Components / رديترات وأغطية'
        WHEN clean.text ~* '(لي ماء|لي رديتر|ماصورة ماء|هوز ماء)' THEN 'Radiator & Water Hoses / خراطيش وليات ماء'
        WHEN clean.text ~* '(مروحة|دينمو مروحة|ريشة مروحة|كلتش مروحة)' THEN 'Cooling Fan & Motor / مراوح ودينموهات تبريد'
        WHEN clean.text ~* '(بمب.*بترول|طرمب.*بترول|مضخ.*وقود|عوامة|عوامه|بخاخات|تانكي|غطاء تانكي)' THEN 'Fuel Pump & Delivery / طرمبات وعوامات وقود'
        WHEN clean.text ~* '(فلتر زيت|سيفون زيت|عيار زيت|مبرد زيت|بمب زيت|مشن بمب)' THEN 'Oil Filter & Lubrication / فلاتر وتزييت المحرك'
        WHEN clean.text ~* '(فلتر بترول|فلتر بنزين|صفاية بترول)' THEN 'Fuel Filter / فلاتر وقود'
        WHEN clean.text ~* '(فلتر هواء|فلتر مكينة هواء)' THEN 'Air Filter / فلاتر هواء'
        WHEN clean.text ~* '(فلتر مكيف|فلتر صالون)' THEN 'Cabin AC Filter / فلاتر مكيف'
        WHEN clean.text ~* '(كويل|كويلات|بوبينة|بواجي|شمعات احتراق|وايرات بواجي)' THEN 'Ignition Coils & Plugs / كويلات وبواجي'
        WHEN clean.text ~* '(سلف|مارش|اتوماتيك سلف|ترس سلف)' THEN 'Starter Motor & Parts / سلف وملحقاته'
        WHEN clean.text ~* '(دينمو|دينمة|فحمة دينمة|فحمات دينمو|بلية دينمو|كتاوت|فيوز)' THEN 'Alternator & Components / دينموهات شحن وملحقاتها'
        WHEN clean.text ~* '(بطارية|بطاريه)' THEN 'Battery & Electrical / بطاريات وكهرباء'
        WHEN clean.text ~* '(حساس|سنسر|حساس اكسجين|حساس كرنك|حساس حرارة|حساس كمبروسر|حساس abs)' THEN 'Sensors & Switches / حساسات وسويتشات'
        WHEN clean.text ~* '(شمعة نور|شمعه نور|شمعة|كشافة|كشافات|نور امامي|لمبات|لمبة)' THEN 'Headlights & Fog Lights / شمعات وكشافات'
        WHEN clean.text ~* '(اسطب|اسطبات|عاكس|نور خلفي|فلشر)' THEN 'Tail Lights & Indicators / اسطبات وإشارات'
        WHEN clean.text ~* '(كمبروسر|مكيف|رديتر مكيف|ثلاجة مكيف|بلف مكيف|لي مكيف|دينمو مكيف)' THEN 'Air Conditioning (HVAC) / أجزاء التكييف والتبريد'
        WHEN clean.text ~* '(صدام|صدامات|شبك|علامة|علامات|لحية|عظمة صدام|قواعد صدام|فيبر صدام)' THEN 'Bumper & Grille / صدامات وشبوك وعلامات'
        WHEN clean.text ~* '(كبوت|رفرف|رفارف|بطانة|بطانات|نسافات|شعار)' THEN 'Body Panels & Liners / كبوت ورفارف وبطانات'
        WHEN clean.text ~* '(باب|ابواب|يد باب|قفل باب|كالون|مراية|مرايات|زجاج|مكينة زجاج)' THEN 'Doors, Mirrors & Windows / أبواب ومرايا وزجاج'
        WHEN clean.text ~* '(مساحات|دينمة مساحات|قربة مساحات|دبة مساحات|ذراع مساحات|بزاغ)' THEN 'Wiper System / منظومة المساحات'
        WHEN clean.text ~* '(كليبسات|كلبسات|كلبس|مسمار|صامولة|براغي)' THEN 'Clips & Fasteners / كلبسات وبراغي'
        WHEN clean.text ~* '(غراء|صمغ|شحم|زيت|سائل|منظف|شليشن|تيب|فرش|تلبيسة)' THEN 'Chemicals & Accessories / زيوت وكيماويات وكماليات'
        ELSE 'Other Parts & Accessories'
    END AS category,

    -- 4. Vehicle System Classification (classification_key)
    CASE
        WHEN clean.is_dummy THEN 'General / Miscellaneous'
        WHEN clean.text ~* '(مقص|بوش|توازن|مساعد|ياي|سبرنج|جوز|مشرع|ذراع سكان|دودة|سكان|دركسون|بيرنج|فلنج|رمان)' THEN 'Suspension & Steering'
        WHEN clean.text ~* '(كنويس|كنوس|فحمات|براص|قماش|بريك|فرامل|هوب|كليبر|سلندر بريك|لي سم بريك|لي بريك)' THEN 'Brake System'
        WHEN clean.text ~* '(مكينة|سير|بطة|شداد|تيمت|جنزير|باكن|صوف|كسكيت|بستن|كرنك|بلوف|كرسي مكينة|كرسي قير|فلتر زيت|فلتر هواء|مبرد زيت)' THEN 'Engine & Mechanical'
        WHEN clean.text ~* '(طرمبة ماء|بمب ماء|كوع ماء|بيسة ماء|بلف حرارة|ترموستات|رديتر|لديتر|مبرد ماء|لي ماء|لي رديتر|مروحة)' THEN 'Cooling System'
        WHEN clean.text ~* '(بترول|بنزين|وقود|عوامة|بخاخات|تانكي|فلتر بترول)' THEN 'Fuel System'
        WHEN clean.text ~* '(كويل|بواجي|سلف|دينمو|دينمة|بطارية|حساس|شمعة|كشافة|اسطب|فلشر|لمبات|فيوز)' THEN 'Electrical & Lighting'
        WHEN clean.text ~* '(كمبروسر|مكيف|فلتر مكيف|ثلاجة مكيف)' THEN 'Air Conditioning & Heating'
        WHEN clean.text ~* '(عكس|عكوس|ركبة عكس|صبيرة|صليب|كلتش|قير|جير)' THEN 'Transmission & Drivetrain'
        WHEN clean.text ~* '(صدام|شبك|علامة|كبوت|رفرف|بطانة|نسافات|مساحات)' THEN 'Body & Exterior'
        WHEN clean.text ~* '(باب|ابواب|يد باب|قفل باب|كالون|مراية|زجاج)' THEN 'Body & Interior'
        WHEN clean.text ~* '(كليبسات|كلبسات|مسمار|براغي|غراء|صمغ|شحم|زيت|منظف)' THEN 'Maintenance & Consumables'
        ELSE 'General / Miscellaneous'
    END AS classification_key,

    clean.item_type

FROM (
    SELECT
        TRIM(itemno)                        AS item_code,
        TRIM(name)                          AS item_name,
        TRIM(lname)                         AS item_name_alt,
        REGEXP_REPLACE(TRIM(itemno), '^[.-]+', '') AS clean_code,
        LOWER(CONCAT_WS(' ', TRIM(name), TRIM(lname), TRIM(itemno))) AS text,
        (TRIM(name) IN ('0', '.', '..', 'nan', '', '*') AND (LENGTH(TRIM(itemno)) <= 5 OR TRIM(itemno) ~ '^\d+$')) AS is_dummy,
        TRIM(itemtype)                      AS item_type
    FROM silver.stock_item
) clean;


-- ============================================================================
-- 3. Load dim_customer (denormalized from silver.sales_order_header)
-- ============================================================================
TRUNCATE TABLE gold.dim_customer CASCADE;

INSERT INTO gold.dim_customer (customer_code, customer_name)
SELECT DISTINCT ON (TRIM(customer_number))
    TRIM(customer_number)   AS customer_code,
    TRIM(customer_name)     AS customer_name
FROM silver.sales_order_header
WHERE customer_number IS NOT NULL
ORDER BY TRIM(customer_number), customer_name NULLS LAST;


-- ============================================================================
-- 4. Load dim_currency (from silver.gl_currency + SAR rate)
-- ============================================================================
TRUNCATE TABLE gold.dim_currency CASCADE;

INSERT INTO gold.dim_currency (currency_code, currency_name, currency_symbol, standard_iso_code, sar_exchange_rate)
SELECT
    TRIM(curcode)               AS currency_code,
    TRIM(curname)               AS currency_name,
    TRIM(cursname)              AS currency_symbol,
    TRIM(standard_fcy_code)     AS standard_iso_code,
    CASE
        WHEN TRIM(curcode) = '01' THEN 0.002421307506053    -- YER → SAR
        WHEN TRIM(curcode) = '02' THEN 3.8                   -- USD → SAR
        ELSE 1                                                -- SAR (curcode '03') or others
    END                         AS sar_exchange_rate
FROM silver.gl_currency;


-- ============================================================================
-- 5. Load dim_sales_center (from silver.sales_order_header)
-- ============================================================================
TRUNCATE TABLE gold.dim_sales_center CASCADE;

INSERT INTO gold.dim_sales_center (sales_center_code, company_id)
SELECT DISTINCT
    TRIM(sales_center)  AS sales_center_code,
    TRIM(company_id)    AS company_id
FROM silver.sales_order_header
WHERE sales_center IS NOT NULL;


-- ============================================================================
-- 6. Load dim_sales_order (Invoice Header Metadata Dimension)
-- ============================================================================
TRUNCATE TABLE gold.dim_sales_order CASCADE;

INSERT INTO gold.dim_sales_order (
    company_id,
    invoice_type,
    reference_number,
    line_item_count,
    salesman_code,
    header_discount_pct,
    vat_percent,
    is_posted,
    is_released,
    is_cheque,
    payment_mode,
    due_date_key
)
SELECT DISTINCT ON (TRIM(hd.company_id), TRIM(hd.invoice_type), hd.reference_number)
    TRIM(hd.company_id)                                         AS company_id,
    TRIM(hd.invoice_type)                                       AS invoice_type,
    hd.reference_number                                         AS reference_number,
    hd.entries                                                  AS line_item_count,
    TRIM(hd.slcode)                                             AS salesman_code,
    hd.invdspc                                                  AS header_discount_pct,
    hd.vat_percent                                              AS vat_percent,
    hd.posted                                                   AS is_posted,
    hd.released                                                 AS is_released,
    hd.ischeque                                                 AS is_cheque,
    CASE
        WHEN COALESCE(hd.ccpayment, 0) > 0 AND COALESCE(hd.stcpay_amt, 0) > 0 THEN 'Mixed (Card+STCPay)'
        WHEN COALESCE(hd.ccpayment, 0) > 0 THEN 'Credit Card'
        WHEN COALESCE(hd.stcpay_amt, 0) > 0 THEN 'STCPay'
        WHEN hd.ischeque = TRUE THEN 'Cheque'
        ELSE 'Cash'
    END                                                         AS payment_mode,
    CASE
        WHEN hd.due_date IS NOT NULL AND TRIM(hd.due_date) ~ '^[0-9]{8}$'
        THEN CAST(TRIM(hd.due_date) AS INTEGER)
        ELSE NULL
    END                                                         AS due_date_key
FROM silver.sales_order_header hd
ORDER BY TRIM(hd.company_id), TRIM(hd.invoice_type), hd.reference_number;


-- ============================================================================
-- 7. Load fact_sales (Line-Item Grain Fact with SAR Normalization)
-- ============================================================================
TRUNCATE TABLE gold.fact_sales;

INSERT INTO gold.fact_sales (
    sales_order_key,
    date_key,
    product_key,
    customer_key,
    sales_center_key,
    currency_key,
    folio,
    quantity,
    unit_price_sar,
    unit_cost_sar,
    discount_pct,
    discount_amount_sar,
    net_price_sar,
    line_total_sar,
    vat_amount_sar,
    returned_quantity
)
SELECT
    -- Dimension Surrogate Keys (Star schema direct joins)
    dso.sales_order_key                                                 AS sales_order_key,
    CAST(dt.invoice_date AS INTEGER)                                    AS date_key,
    dp.product_key                                                      AS product_key,
    dc.customer_key                                                     AS customer_key,
    dsc.sales_center_key                                                AS sales_center_key,
    dcur.currency_key                                                   AS currency_key,

    -- Degenerate Line Item identifier
    dt.folio                                                            AS folio,

    -- Measures (SAR-converted)
    dt.quantity                                                         AS quantity,

    ROUND((dt.item_price * sar_rate.rate)::NUMERIC, 4)                  AS unit_price_sar,
    ROUND((dt.item_cost  * sar_rate.rate)::NUMERIC, 4)                  AS unit_cost_sar,

    dt.discounted_price                                                 AS discount_pct,

    ROUND((COALESCE(dt.dsc_amt, 0) * sar_rate.rate)::NUMERIC, 4)        AS discount_amount_sar,
    ROUND((COALESCE(dt.item_price_net, 0) * sar_rate.rate)::NUMERIC, 4)  AS net_price_sar,
    ROUND((dt.quantity * dt.item_price * sar_rate.rate)::NUMERIC, 4)     AS line_total_sar,
    ROUND((COALESCE(dt.item_vat, 0) * sar_rate.rate)::NUMERIC, 4)       AS vat_amount_sar,

    dt.rtnqty                                                           AS returned_quantity

FROM silver.sales_order_detail dt

-- Join header for customer link and fallback currency
INNER JOIN silver.sales_order_header hd
    ON  dt.company_id       = hd.company_id
    AND dt.invoice_type     = hd.invoice_type
    AND dt.reference_number = hd.reference_number

-- SAR conversion rate calculation
CROSS JOIN LATERAL (
    SELECT
        CASE
            WHEN TRIM(COALESCE(NULLIF(TRIM(dt.currency), ''), hd.currency)) = '01'
                THEN 0.002421307506053
            WHEN TRIM(COALESCE(NULLIF(TRIM(dt.currency), ''), hd.currency)) = '02'
                THEN 3.8
            ELSE 1
        END AS rate,
        TRIM(COALESCE(NULLIF(TRIM(dt.currency), ''), hd.currency)) AS resolved_currency
) sar_rate

-- Dimension lookups
INNER JOIN gold.dim_sales_order dso
    ON  TRIM(dt.company_id)       = dso.company_id
    AND TRIM(dt.invoice_type)     = dso.invoice_type
    AND dt.reference_number       = dso.reference_number

INNER JOIN gold.dim_product dp
    ON TRIM(dt.item_code) = dp.item_code

INNER JOIN gold.dim_customer dc
    ON TRIM(hd.customer_number) = dc.customer_code

INNER JOIN gold.dim_currency dcur
    ON sar_rate.resolved_currency = dcur.currency_code

INNER JOIN gold.dim_sales_center dsc
    ON  TRIM(dt.sales_center) = dsc.sales_center_code
    AND TRIM(dt.company_id)   = dsc.company_id

-- Filter to target date series range (2023+)
INNER JOIN gold.dim_date dd
    ON CAST(dt.invoice_date AS INTEGER) = dd.date_key;
