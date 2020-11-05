top_links = {
  es: { transparency: "Transparencia", open_data: "Datos abiertos" },
  gl: { transparency: "Transparencia", open_data: "Datos abertos" }
}

top_links.each do |locale, texts|
  next if SiteCustomization::ContentBlock.find_by(locale: locale, name: "top_links")

  SiteCustomization::ContentBlock.create!(
    locale: locale,
    name: "top_links",
    body: %Q{
      <li>
        <a href="https://transparencia.santiagodecompostela.gal/portada/gl">#{texts[:transparency]}</a>
      </li>
      <li>
        <a href="https://datos.santiagodecompostela.gal/gl">#{texts[:open_data]}</a>
      </li>
    }
  )
end
