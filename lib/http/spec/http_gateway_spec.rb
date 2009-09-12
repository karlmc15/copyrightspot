# moved this to the lib directory of the code so it's not run by default every time all tests are run
# because it makes calls to external sites.  Run this mannually if the Http::Gateway code is changed

require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe "Http::Gateway" do
  before(:each) do
    @good_url = 'http://myfreecopyright.com'
    @redirect_url = 'http://www.myfreecopyright.com'
    @bad_url = 'http://foobarness123.com'
  end
  it "should successfully retrieve valid http document" do
    Http::Gateway.get(@good_url).should be_success
  end
  it "should successfully follow a redirect and return http document" do
    Http::Gateway.get(@redirect_url).last_effective_url.should == 'http://myfreecopyright.com/'
  end
  it "should return an empty response on error" do
    Http::Gateway.get(@bad_url).body.should be_blank
  end
  it "should return successfully and with only headers" do
    Http::Gateway.get_head(@good_url).should be_success
  end
end