top_links = {
  es: { transparency: "Transparencia", open_data: "Datos abiertos" },
  gl: { transparency: "Transparencia", open_data: "Datos abertos" }
}

social_links = {
  es: { lg: "cas", weather: "El Tiempo" },
  gl: { lg: "gal", weather: "O Tempo" }
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



social_links.each do |locale, texts|
  next if SiteCustomization::ContentBlock.find_by(locale: locale, name: "footer")

  SiteCustomization::ContentBlock.create!(
    locale: locale,
    name: "footer",
    body: %Q{
      <li class="inline-block">
        <a href="http://www.santiagodecompostela.gal/tempo.php?lg=#{texts[:lg]}" title="#{texts[:weather]}">
          <span class="show-for-sr">#{texts[:weather]}</span>
          <span class="icon-otempo" aria-hidden="true"></span>
        </a>
      </li>
    }
  )
end
