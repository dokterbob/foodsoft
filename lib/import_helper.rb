class ImportHelper
  # try to guess a proper category from supplied category name
  def self.guess_category(name)
      # exact match first
      category = ArticleCategory.find_by_name(name)
      category and return category

      # partial match in category name
      category = ArticleCategory.where('name LIKE ?', name).first
      category and return category

      # partial match in category description
      category = ArticleCategory.where('description LIKE ?', name).first
      category and return category

      # fallback to 'Other' category
      # TODO may not exist; check multiple fallback category names? or even create one?
      category = ArticleCategory.find_by_name('Other')
      category
  end
end
