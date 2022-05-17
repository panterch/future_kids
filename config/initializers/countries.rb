ISO3166::Data.register(
  alpha2: "XK",
  iso_short_name: 'Kosovo',
  translations: {
    'en' => "Kosovo",
    'de' => "Kosovo"
  }
)

ISO3166::Country.new('XK').iso_short_name == 'Kosovo'
