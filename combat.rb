require 'mechanize'

user = ARGV[0]
pass = ARGV[1]

a = WWW::Mechanize.new
page_post = a.post("http://#{user}.labrute.fr/login", 'pass' => pass)

while true do
  login = nil
  a.get("http://#{user}.labrute.fr/arene") do |page|
    if page.search("//div[@class='cellule']").nil?
      # pas dans la page cellule donc bien sur arene
      login = page.search("//div[@class='name']")[0].inner_text
    else
      login = nil
    end
  end

  unless login.nil?
    a.get("http://#{user}.labrute.fr/vs/#{login}")
    puts "combat avec #{login}"
  else
    puts 'plus de combat à réaliser'
    break
  end
end
