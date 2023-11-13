require 'json'
require 'httparty'
require 'nokogiri'
require 'csv'

class YardiTools < Thor
  desc 'extract_tenant URL TENANT_ID', 'extracts a tenant information from a url'
  def extract_tenant(url, tenant_id)
    url = url.sub('TENANT_ID', tenant_id)
    response = do_request(url)
    noko_doc = Nokogiri::HTML(response.body)
    data = []
    fields.each do |field|
      element = noko_doc.css("##{field[:id]}").first
      value = case element.name
        when 'span' then element.inner_text
        when 'a' then element.inner_text
        else element['value']
        end
      data << value
      puts sprintf("%-20s: %s", field[:title], value)
    end
    return data
    #puts noko_doc.css('#Tent_FirstName_TextBox').first['value']
  end

  desc 'extract_all_tenants URL', "extracts all tenants to a CSV out.csv"
  def extract_all_tenants(url)
    ids = File.readlines('tenant_ids.txt')
    CSV.open("out.csv", "wb") do |csv|
      csv << fields.map{ |f| f[:title]}
      ids.each do |id|
        puts "Extracting tenant #{id}"
        csv << extract_tenant(url, id)
      end
    end
  end

  no_commands do
    def fields
      [
        {id: "Tent_FirstName_TextBox", title: "first name"},
        {id: "Tent_MiddleName_TextBox", title: "middle_name"},
        {id: "Tent_LastName_TextBox", title: "last_name"},
        {id: "Tent_Address1_TextBox", title: "address1"},
        {id: "Tent_Address2_TextBox", title: "address2"},
        {id: "Tent_City_TextBox", title: "city"},
        {id: "Tent_State_lblTent_State", title: "state"},
        {id: "Tent_ZipCode_TextBox", title: "zip"},
        {id: "Tent_Code_TextBox", title: "tenant_code"},
        {id: "PropertyLink", title: "property"},
        {id: "UnitLink", title: "unit"},
        {id: "ProspectLink", title: "prospect"},
        {id: "myStatus_lblmyStatus", title: "status"},
        #{id: "Legal_Label", title: "legal"},


        # LEASE INFO TAB
        {id: "Tent_LeaseSignDate_TextBox", title: "lease sign date"},
        {id: "Tent_LeaseFrom_TextBox", title: "lease from text"},
        {id: "Tent_MoveIn_TextBox", title: "move in"},
        {id: "Tent_NoticeDate_TextBox", title: "notice"},
        {id: "Tent_MoveOut_TextBox", title: "move out"},
        {id: "Tent_LeaseTo_TextBox", title: "lease to"},
        {id: "Tent_NoticeResponsibilityDate_TextBox", title: "Notice Responsibility Date"},
        {id: "Tent_Notes_TextBox", title: "Notes"},
        {id: "MarketRent_TextBox", title: "Market Rent"},
        {id: "Tent_Rent_TextBox", title: "Rent"},
        {id: "OtherCharges_TextBox", title: "Other Charges"},
        {id: "Tent_TotalCharges_TextBox", title: "Total Charges"},
        {id: "Tent_MoveOutReason_lblTent_MoveOutReason", title: "Reason for Move Out"},
        {id: "Tent_LeaseDescription_lblTent_LeaseDescription", title: "Lease Description"},

        # DEPOSIT INFO TAB
        {id: "Tent_Deposittxt0_TextBox", title: "Deposit"},
        {id: "Tent_DepositTxt1:TextBox", title: "Pet Deposit"},
        {id: "Tent_DepositTxt2:TextBox", title: "Garage Deposit"},
        {id: "Tent_DepositTxt3:TextBox", title: "Swipe Card Deposit"},
        {id: "Tent_DepositTxt4:TextBox", title: "Cable Deposit"},
        {id: "Tent_DepositTxt5:TextBox", title: "Furniture Deposit"},
        {id: "Tent_DepositTxt6:TextBox", title: "Other1 Deposit"},
        {id: "Tent_DepositTxt7:TextBox", title: "Other2 Deposit"},
        {id: "Tent_DepositTxt8:TextBox", title: "Other3 Deposit"},
        {id: "Tent_DepositTxt9:TextBox", title: "Other4 Deposit"},

        {id: "Tent_LateMonthDeposit_TextBox", title: "Last Month's"},
        {id: "Tent_AnniversaryMonth_lblTent_AnniversaryMonth", title: "Anniversary"},
        {id: "DepositInterest_TextBox", title: "Interest"},
      ]
    end  
    def load_cookies
      cookies = File.read('./cookies.txt')
      @cookie_hash = HTTParty::CookieHash.new
      @cookie_hash.add_cookies cookies
    end

    def do_request(url)
      load_cookies if @cookie_hash.nil?
      response = HTTParty.get(url, {headers: {'Cookie' => @cookie_hash.to_cookie_string }} )
    end
  end
end
