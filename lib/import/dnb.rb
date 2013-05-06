# De Nieuwe Band article import filter

require 'csv'

class Import::DNB
  cattr_accessor :name, :title

  @@name = "DNB"
  @@title = "De Nieuwe Band (CSV)"

  def self.import(file)
    # parses the articles from a csv and creates a form-table with the parsed data.
    row_index = 1
    col_sep = ::ImportHelper.csv_guess_col_sep(file)
    ::CSV.parse(file.read, {:col_sep => col_sep, :headers => true}) do |row|
      row_index += 1
      # somehow this is needed for uploaded files
      row.each {|k,v| v.nil? or row[k]=v.force_encoding('UTF-8')}
      # skip empty lines
      (row[2] == "" || row[2].nil?) and next
      # skip outlisted articles ('x' in first column)
      row['status'] == 'x' and next
      # create a new article
      category = ::ImportHelper.guess_category(row['trefwoord'])
      unit = (row['eenheid'] or 'st')
      unit == 'g' and unit = 'gr' # unit currently needs to be at least 2 characters
      unit == 'l' and unit = '1L' # unit currently needs to be at least 2 characters
      not row['inhoud'].nil? and row['inhoud'].to_i > 1 and unit = row['inhoud'] + unit
      tax = case row['btw'].to_i
        when 0 then 0.0
        when 1 then 6.0
        when 2 then 21.0
        else '?'
      end
      article = ::Article.new(
                             :order_number => row['art.nr.'],
                             :name => row['omschrijving'], 
                             :note => row['kwaliteit'],
                             :manufacturer => row['merk'],
                             :origin => row['land'],
                             :unit => unit,
                             :price => row['inkoopprijs'],
                             :unit_quantity => row['aantal'],
                             :tax => tax,
                             :deposit => row['statiegeld'],
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
