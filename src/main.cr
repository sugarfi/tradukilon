require "http/client"
require "crystagiri"
require "uri"
require "option_parser"

URL = "https://lernu.net"
PATH = "/en/vortaro"

direction = "eo|en"
word = nil

OptionParser.parse do |parser|
    parser.banner = "Usage: tradukilon [-h|--help] [-d|--direction DIRECTION] [-w|--word WORD]"
    parser.on("-d DIRECTION", "--direction=DIRECTION", "Sets the translation direction, must be of format LANG|LANG (default eo|en)") { |d| direction = d }
    parser.on("-w WORD", "--word=WORD", "Sets the word to translate (default read from stdin") { |w| word = w }
    parser.on("-h", "--help", "Shows this help") do
        puts parser
        exit
    end
    parser.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag} is not a valid option."
        STDERR.puts parser
        exit 1
    end
end

unless word
    STDOUT << "Please enter a word to translate: "
    word = gets
    unless word
        exit 1
    end
end

HTTP::Client.new(URI.parse(URL)) do |client|
    res = client.get(PATH)
    php_sess_id = res.cookies["PHPSESSID"]
    Crystagiri::HTML.new(res.body).css("form > input") do |tag| 
        token = tag.node["value"] 

        params = HTTP::Params.encode({
            "YII_CSRF_TOKEN" => token,
            "DictWords[dictionary]" => direction,
            "DictWords[word]" => word.as(String)
        })

        headers = HTTP::Headers.new

        cookies = HTTP::Cookies.new
        cookies["PHPSESSID"] = php_sess_id
        cookies["YII_CSRF_TOKEN"] = token
        cookies.add_request_headers headers

        res = client.post PATH, headers: headers, form: params
        if res.status_code != 200
            STDERR.puts "ERROR: couldn't get definition. Try again later."
            exit 1
        end

        structures = [] of Array(String)
        defs = [] of String

        # >_<
        Crystagiri::HTML.new(res.body).css("#dictionary-search-results > ul > li > span") do |tag|
            structures << tag.node.children[0].to_s[1..-2].split(" ← ")
        end
        Crystagiri::HTML.new(res.body).css("#dictionary-search-results > ul > li > ul > li") do |tag|
            d = ""
            tag.node.children.each do |child|
                if child.children.size > 0
                    d += child.children[0].to_s
                else
                    d += child.to_s
                end
            end
            defs << d
        end

        if defs.size == 0
            STDERR.puts "ERROR: no definitions found."
            exit 1
        end

        if structures.size == 0
            puts word
        end

        defs.size.times do |i|
            d = defs[i]
            if structures[i]?
                if structures[i].size == 2
                    parts, root = structures[i]
                    puts "#{parts} (from #{root})"
                else
                    puts structures[i][0]
                end
                puts "  #{d}"
            else
                puts "  #{d}"
            end
        end
    end
end



