require File.dirname(__FILE__) + '/test_helper.rb'
Depo.configure do
  root 'public'
  author 'niquola@gmail.com'
  generators do
    head_of_test_page <<-HTML
    <link rel="stylesheet" href="#{Depo.config.src_path}/common.css" type="text/css" />
    HTML
  end
end


class ViewsGeneratorTest < GeneratorTest
  def test_config_generator
    generate 'depo_config'
    assert_file 'config/depo.rb'
    result = read 'config/depo.rb'
    assert_match(/Depo.config/, result)
  end

  def from_src(path)
    File.join(Depo.config.src_path,path)
  end

  def test_widget_generator
    generate 'dijit','app.my.Dijit'

    file = from_src("app/my/Dijit.js")
    assert_file file
    result = read file
    assert_match(/dojo.provide/, result)
    assert_match(/dojo.declare/, result)

    file = from_src("app/tests/my/Dijit.js")
    assert_file file
    result = read file
    assert_match(/dojo.require/, result)

    file = from_src("app/tests/my/Dijit.html")
    assert_file file
    result = read file
    assert_match(/common.css/, result)

    file = from_src("app/themes/basic/my/Dijit.css")
    assert_file file
    result = read file
    assert_match(/.AppMyDijit/, result)
  end

  def test_page_generator
  end
end
