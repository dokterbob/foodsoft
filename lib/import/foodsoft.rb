# Foodsoft CSV article import filter

require 'csv'

class Import::Foodsoft
  cattr_accessor :name, :title

  @@name = "Foodsoft"
  @@title = "Foodsoft (CSV)"

  def self.import(file)
    # parses the articles from a csv and creates a form-table with the parsed data.
    # the csv must have the following format:
    # status | number | name | note | manufacturer | origin | unit | clear price | tax | deposit | unit_quantity | scale quantity | scale price | category
    # the first line will be ignored.
    # field-seperator: ";"
    # text-seperator: ""
    row_index = 1
    col_sep = ::ImportHelper.csv_guess_col_sep(file)
    ::CSV.parse(file.read, {:col_sep => col_sep, :headers => true}) do |row|
      row_index += 1
      # somehow this is needed for uploaded files
      row.each {|k,v| v.nil? or row[k]=v.force_encoding('UTF-8')}
      # skip empty lines
      (row[2] == "" || row[2].nil?) and next
      # skip outlisted articles ('x' in first column)
      row[0] == 'x' and next
      # create a new article
      category = ::ImportHelper.guess_category(row[13])
      article = ::Article.new(
                             :order_number => row[1],
                             :name => row[2], 
                             :note => row[3],
                             :manufacturer => row[4],
                             :origin => row[5],
                             :unit => row[6],
                             :price => row[7],
                             :tax => row[8],
                             :deposit => (row[9].nil? ? '0' : row[9]),
                             :unit_quantity => row[10],
                             :article_category => category
                           )
      # stop parsing, when an article isn't valid
      unless article.valid?
        raise article.errors.full_messages.join(", ") + " ..in line " + row_index.to_s
      end
      yield article
    end
  end
end
