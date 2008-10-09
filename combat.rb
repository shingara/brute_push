require 'mechanize'

# Mettre 2 arguments si on veux ce rand. Utile pour mettre dans un cron
# et avoir un démarrage un peu aléatoire dans l'heure 
sleep(rand(3600)) if ARGV[1]

YAML::load_file('user.yml').each do |player|
  user = player['name']
  pass = player['pwd']
  puts "Joueur : #{user}"

  a = WWW::Mechanize.new
  page_post = a.post("http://#{user}.labrute.fr/login", 'pass' => pass)

  while true do
    login = nil
    a.get("http://#{user}.labrute.fr/arene") do |page|
      if page.search("//div[@class='cellule']").empty?
        # pas dans la page cellule donc bien sur arene
        brute_a_combattre = rand(6)
        login = page.search("//div[@class='name']")[brute_a_combattre].inner_text
      else
        login = nil
      end
    end

    unless login.nil?
      a.get("http://#{user}.labrute.fr/vs/#{login}")
      puts "combat avec #{login}"
      # sleep car sinon plein de combat et pas forcement tous fait.
      # Ajout d'un random pour se faire un peu moins détecter.
      sleep(rand(10) + 2)   
    else
      puts 'plus de combat à réaliser'
      break
    end
  end

  puts 'HISTORIQUE'

  #Recuperation des derniers évenements
  a.get("http://#{user}.labrute.fr/cellule") do |page|
    page.search("//div[@class='logs']")[0].each_child do |child|
      if child.is_a? Hpricot::Elem
        line = ''
        case child.get_attribute('class')
        when 'log log-win'
          line = 'GAGNE : '
        when 'log log-lose'
          line = 'PERDU : '
        when 'log log-childup'
          line = 'ELEVE MONTE '
        else
          puts "class inconnu : #{child.get_attribute('class')}"
        end

        line += child.search("//div[@class='lmain']").inner_text.gsub("\n", "")
        line += '('
        line += child.search("//div[@class='ldetails']").inner_text.gsub("\n", "")
        line += ')'
        puts line
      end
    end
  end
  puts ''

end
