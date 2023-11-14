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
        {id: "Tent_DepositTxt1_TextBox", title: "Pet Deposit"},
        {id: "Tent_DepositTxt2_TextBox", title: "Garage Deposit"},
        {id: "Tent_DepositTxt3_TextBox", title: "Swipe Card Deposit"},
        {id: "Tent_DepositTxt4_TextBox", title: "Cable Deposit"},
        {id: "Tent_DepositTxt5_TextBox", title: "Furniture Deposit"},
        {id: "Tent_DepositTxt6_TextBox", title: "Other1 Deposit"},
        {id: "Tent_DepositTxt7_TextBox", title: "Other2 Deposit"},
        {id: "Tent_DepositTxt8_TextBox", title: "Other3 Deposit"},
        {id: "Tent_DepositTxt9_TextBox", title: "Other4 Deposit"},
        {id: "Tent_LateMonthDeposit_TextBox", title: "Last Month's"},
        {id: "Tent_AnniversaryMonth_lblTent_AnniversaryMonth", title: "Anniversary"},
        {id: "DepositInterest_TextBox", title: "Interest"},

        #LATE FEE TAB
        {id: "Tent_DueDay_TextBox", title: "Due Day"},
        {id: "Tent_LateFeeMinimum_TextBox", title: "Late Fee Minimum"},
        {id: "MyLateFeeType_lblMyLateFeeType", title: "Late Fee Type"},
        {id: "Tent_LateFeeGraceDays_TextBox", title: "Late Fee Grace Days"},
        {id: "Tent_LateFeeAmount2_TextBox", title: "Late Fee Amount"},
        {id: "MyLateFeeAmountType2_lblMyLateFeeAmountType2", title: "Late Fee Amount Type 2"},
        {id: "Tent_LateFeeGraceDays2_TextBox", title: "Late Fee Grace Days Type 2"},
        {id: "Tent_LateFeeMax_TextBox", title: "Late Fee Maximum"},
        {id: "MyLateFeeAmountTypeMax_lblMyLateFeeAmountTypeMax", title: "Late Fee Amount Max Type"},
        {id: "Tent_LateFeePerDay_TextBox", title: "Late Fee Per Day"},
        {id: "Tent_LateFeeMaxDays_TextBox", title: "Late Fee Max Days"},
        {id: "Tent_LateFeeMinDue_TextBox", title: "Late Fee Minimum Due"},
        {id: "Tent_NsfCount_TextBox", title: "NSF Count"},
        {id: "Tent_LateFeeCount_Label", title: "Late Fee Count"},


        #OTHER INFORMATION
        {id: "TentInfo_StatementType_lblTentInfo_StatementType", title: "Statement Options"},
        {id: "Tent_MaintenanceNotes_TextBox", title: "Maintenance Notes"},

        {id: "Tent_Field0_ChildTextBox_TextBox", title: "License Number"},
        {id: "Tent_Field2_ChildTextBox_TextBox", title: "Bank"},
        {id: "Tent_Field4_ChildTextBox_TextBox", title: "Children"},
        {id: "Tent_Field6_ChildTextBox_TextBox", title: "Pets"},
        {id: "Tent_Field8_ChildTextBox_TextBox", title: "Gurantor"},
        {id: "Tent_Field10_ChildTextBox_TextBox", title: "Other 1"},
        {id: "Tent_Field12_ChildTextBox_TextBox", title: "Other 4"},
        {id: "Tent_Field14_ChildTextBox_TextBox", title: "First"},

        {id: "Tent_Field1_ChildTextBox_TextBox", title: "Car"},
        {id: "Tent_Field3_ChildTextBox_TextBox", title: "Account #"},
        {id: "Tent_Field5_ChildTextBox_TextBox", title: "Ages"},
        {id: "Tent_Field7_ChildTextBox_TextBox", title: "Reference"},
        {id: "Tent_Field9_ChildTextBox_TextBox", title: "Collection"},
        {id: "Tent_Field11_ChildTextBox_TextBox", title: "Other3"},
        {id: "Tent_Field13_ChildTextBox_TextBox", title: "Parking Tag #"},
        {id: "Tent_Field15_ChildTextBox_TextBox", title: "Dear"},

        #PERSONAL INFO
        {id: "PhoneTxt0_TextBox", title: "Office Phone"},
        {id: "PhoneTxt1_TextBox", title: "Home Phone"},
        {id: "PhoneTxt2_TextBox", title: "Fax Phone"},
        {id: "PhoneTxt3_TextBox", title: "Mobile Phone"},
        {id: "PhoneTxt4_TextBox", title: "Pager Phone"},
        {id: "PhoneTxt5_TextBox", title: "Secretary"},
        {id: "PhoneTxt6_TextBox", title: "Other Phone 1"},
        {id: "PhoneTxt7_TextBox", title: "Other Phone 2"},
        {id: "PhoneTxt8_TextBox", title: "Other Phone 3"},
        {id: "PhoneTxt9_TextBox", title: "Other Phone 4"},
        {id: "Tent_Email_TextBox", title: "Email"},
        {id: "Tent_Email2_TextBox", title: "Email 2"},
        {id: "Tent_GovernmentId_TextBox", title: "SSN"},
        {id: "TenVeh_DriversLicense_TextBox", title: "Drivers License #"},
        {id: "TenVeh_DriversLicenseState_lblTenVeh_DriversLicenseState", title: "Drivers License State"},

        {id: "TenVeh_EmergencyName_TextBox", title: "Emergency Contact Name"},
        {id: "TenVeh_EmergencyRelation_lblTenVeh_EmergencyRelation", title: "Emergency Contact Relation"},
        {id: "TenVeh_EmergencyAddress1_TextBox", title: "Emergency Contact Address1"},
        {id: "TenVeh_EmergencyAddress2_TextBox", title: "Emergency Contact Address2"},
        {id: "TenVeh_EmergencyCity_TextBox", title: "Emergency Contact City"},
        {id: "TenVeh_EmergencyState_TextBox", title: "Emergency Contact State"},
        {id: "TenVeh_EmergencyZip_TextBox", title: "Emergency Contact Zip"},
        {id: "TenVeh_EmergencyPhoneOther_TextBox", title: "Emergency Contact Phone"},

        {id: "TenVeh_Vehicle1Type_TextBox", title: "Vehicle 1 Make"},
        {id: "TenVeh_Vehicle1Model_TextBox", title: "Vehicle 1 Model"},
        {id: "TenVeh_Vehicle1Color_TextBox", title: "Vehicle 1 Color"},
        {id: "TenVeh_Vehicle1Year_TextBox", title: "Vehicle 1 Year"},
        {id: "TenVeh_Vehicle1License_TextBox", title: "Vehicle 1 License"},
        {id: "TenVeh_Vehicle1State_lblTenVeh_Vehicle1State", title: "Vehicle 1 State"},
        
        {id: "TenVeh_Vehicle2Type_TextBox", title: "Vehicle 2 Make"},
        {id: "TenVeh_Vehicle2Model_TextBox", title: "Vehicle 2 Model"},
        {id: "TenVeh_Vehicle2Color_TextBox", title: "Vehicle 2 Color"},
        {id: "TenVeh_Vehicle2Year_TextBox", title: "Vehicle 2 Year"},
        {id: "TenVeh_Vehicle2License_TextBox", title: "Vehicle 2 License"},
        {id: "TenVeh_Vehicle2State_lblTenVeh_Vehicle2State", title: "Vehicle 2 State"},

        {id: "TenVeh_Vehicle3Type_TextBox", title: "Vehicle 3 Make"},
        {id: "TenVeh_Vehicle3Model_TextBox", title: "Vehicle 3 Model"},
        {id: "TenVeh_Vehicle3Color_TextBox", title: "Vehicle 3 Color"},
        {id: "TenVeh_Vehicle3Year_TextBox", title: "Vehicle 3 Year"},
        {id: "TenVeh_Vehicle3License_TextBox", title: "Vehicle 3 License"},
        {id: "TenVeh_Vehicle3State_lblTenVeh_Vehicle3State", title: "Vehicle 3 State"},

        {id: "TenVeh_Vehicle4Type_TextBox", title: "Vehicle 4 Make"},
        {id: "TenVeh_Vehicle4Model_TextBox", title: "Vehicle 4 Model"},
        {id: "TenVeh_Vehicle4Color_TextBox", title: "Vehicle 4 Color"},
        {id: "TenVeh_Vehicle4Year_TextBox", title: "Vehicle 4 Year"},
        {id: "TenVeh_Vehicle4License_TextBox", title: "Vehicle 4 License"},
        {id: "TenVeh_Vehicle4State_lblTenVeh_Vehicle4State", title: "Vehicle 4 State"},

        {id: "PetsDataGrid_DataTable_row0_PetType", title: "Pet 1 Type"},
        {id: "PetsDataGrid_DataTable_row0_PetWeight", title: "Pet 1 Weight"},
        {id: "PetsDataGrid_DataTable_row0_PetAge", title: "Pet 1 Age"},
        {id: "PetsDataGrid_DataTable_row0_PetColor", title: "Pet 1 Color"},
        {id: "PetsDataGrid_DataTable_row0_PetName", title: "Pet 1 Name"},
        {id: "PetsDataGrid_DataTable_row0_PetBreed", title: "Pet 1 Breed"},
        {id: "PetsDataGrid_DataTable_row0_PetGender", title: "Pet 1 Gender"},
        {id: "PetsDataGrid_DataTable_row0_ReadOnlyColPetSpayedOrNeutered", title: "Pet 1 Spayed/Neutered"},
        {id: "PetsDataGrid_DataTable_row0_ReadOnlyColIsServiceAnimal", title: "Pet 1 Service Animal"},


        {id: "PetsDataGrid_DataTable_row0_PetType", title: "Pet 1 Type"},
        {id: "PetsDataGrid_DataTable_row0_PetWeight", title: "Pet 1 Weight"},
        {id: "PetsDataGrid_DataTable_row0_PetAge", title: "Pet 1 Age"},
        {id: "PetsDataGrid_DataTable_row0_PetColor", title: "Pet 1 Color"},
        {id: "PetsDataGrid_DataTable_row0_PetName", title: "Pet 1 Name"},
        {id: "PetsDataGrid_DataTable_row0_PetBreed", title: "Pet 1 Breed"},
        {id: "PetsDataGrid_DataTable_row0_PetGender", title: "Pet 1 Gender"},
        {id: "PetsDataGrid_DataTable_row0_ReadOnlyColPetSpayedOrNeutered", title: "Pet 1 Spayed/Neutered"},
        {id: "PetsDataGrid_DataTable_row0_ReadOnlyColIsServiceAnimal", title: "Pet 1 Service Animal"},


        {id: "PetsDataGrid_DataTable_row1_PetType", title: "Pet 2 Type"},
        {id: "PetsDataGrid_DataTable_row1_PetWeight", title: "Pet 2 Weight"},
        {id: "PetsDataGrid_DataTable_row1_PetAge", title: "Pet 2 Age"},
        {id: "PetsDataGrid_DataTable_row1_PetColor", title: "Pet 2 Color"},
        {id: "PetsDataGrid_DataTable_row1_PetName", title: "Pet 2 Name"},
        {id: "PetsDataGrid_DataTable_row1_PetBreed", title: "Pet 2 Breed"},
        {id: "PetsDataGrid_DataTable_row1_PetGender", title: "Pet 2 Gender"},
        {id: "PetsDataGrid_DataTable_row1_ReadOnlyColPetSpayedOrNeutered", title: "Pet 2 Spayed/Neutered"},
        {id: "PetsDataGrid_DataTable_row1_ReadOnlyColIsServiceAnimal", title: "Pet 2 Service Animal"},

        {id: "PetsDataGrid_DataTable_row2_PetType", title: "Pet 3 Type"},
        {id: "PetsDataGrid_DataTable_row2_PetWeight", title: "Pet 3 Weight"},
        {id: "PetsDataGrid_DataTable_row2_PetAge", title: "Pet 3 Age"},
        {id: "PetsDataGrid_DataTable_row2_PetColor", title: "Pet 3 Color"},
        {id: "PetsDataGrid_DataTable_row2_PetName", title: "Pet 3 Name"},
        {id: "PetsDataGrid_DataTable_row2_PetBreed", title: "Pet 3 Breed"},
        {id: "PetsDataGrid_DataTable_row2_PetGender", title: "Pet 3 Gender"},
        {id: "PetsDataGrid_DataTable_row2_ReadOnlyColPetSpayedOrNeutered", title: "Pet 3 Spayed/Neutered"},
        {id: "PetsDataGrid_DataTable_row2_ReadOnlyColIsServiceAnimal", title: "Pet 3 Service Animal"}
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
