/*
Copyright (c) 2011 Elektrobit (EB), All rights reserved.
Contact: oss-devel@elektrobit.com

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:
* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of the Elektrobit (EB) nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY Elektrobit (EB) ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Elektrobit
(EB) BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package eu.licentia.necessitas.mobile;
//@ANDROID-5
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.provider.ContactsContract;
import android.provider.ContactsContract.CommonDataKinds.Email;
import android.provider.ContactsContract.CommonDataKinds.Event;
import android.provider.ContactsContract.CommonDataKinds.Nickname;
import android.provider.ContactsContract.CommonDataKinds.Note;
import android.provider.ContactsContract.CommonDataKinds.Organization;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.provider.ContactsContract.CommonDataKinds.StructuredName;
import android.provider.ContactsContract.CommonDataKinds.StructuredPostal;
import android.provider.ContactsContract.CommonDataKinds.Website;
import android.provider.ContactsContract.Contacts.Data;
import android.provider.ContactsContract.RawContacts;
import android.util.Log;
import eu.licentia.necessitas.industrius.QtApplication;
public class QtAndroidContacts
{
    private static AndroidContacts m_androidContacts;

    @SuppressWarnings("unused")
    private void getContacts()
    {
        Cursor c=QtApplication.mainActivity().getContentResolver().query(ContactsContract.Contacts.CONTENT_URI,null, null, null, null);
        m_androidContacts = new AndroidContacts(c.getCount());
        for(int i=0;i<c.getCount();i++)
        {
            c.moveToNext();
            String id = c.getString(c.getColumnIndex(ContactsContract.Contacts._ID));
            String displayName = c.getString(c.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));
            NameData nameData = getNameDetails(id);
            PhoneNumber[] numberArray = {};
            if (Integer.parseInt(c.getString(c.getColumnIndex(ContactsContract.Contacts.HAS_PHONE_NUMBER))) > 0)
            {
                    numberArray = getPhoneNumberDetails(id);
            }
            EmailData[] emailArray = getEmailAddressDetails(id);
            String note = getNoteDetails(id);
            AddressData[] addressArray= getAddressDetails(id);
            OrganizationalData[] organizationArray = getOrganizationDetails(id);
            String birthday = getBirthdayDetails(id);
            String[] urlArray =  getUrlDetails(id);
            String anniversary = getAnniversaryDetails(id);
            String nickName = getNickNameDetails(id);
            OnlineAccount[] onlineAccountArray = getImDetails(id);
            m_androidContacts.buildContacts(i,id,displayName,nameData,numberArray,emailArray,note,addressArray,organizationArray,birthday,anniversary,nickName,urlArray,onlineAccountArray);
        }
    }

    private NameData getNameDetails(String id)
    {
        String nameWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
        String[] nameWhereParams = new String[]{id,
                        ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE};
        Cursor nameCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI,
                        null, nameWhere, nameWhereParams, null);
        if(nameCur != null && nameCur.moveToFirst())
        {
            String firstName = nameCur.getString(nameCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.GIVEN_NAME));
            if(firstName == null)
                    firstName = "";
            String lastName = nameCur.getString(nameCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.FAMILY_NAME));
            if(lastName == null)
                    lastName = "";
            String middleName = nameCur.getString(nameCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.MIDDLE_NAME));
            if(middleName == null)
                    middleName = "";
            String prefix  = nameCur.getString(nameCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.PREFIX));
            if(prefix == null)
                    prefix = "";
            String suffix = nameCur.getString(nameCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.SUFFIX));
            if(suffix == null)
                    suffix = "";
            NameData nameDetails = new NameData(firstName,lastName,middleName,prefix,suffix);
            nameCur.close();
            return nameDetails;
        }
        return null;
    }

    private PhoneNumber[] getPhoneNumberDetails(String id)
    {
        Cursor pCur = QtApplication.mainActivity().getContentResolver().query(
                        ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                        null,
                        ContactsContract.CommonDataKinds.Phone.CONTACT_ID +" = ?",
                        new String[]{id}, null);
        if(pCur!= null)
        {
            int i=0;
            PhoneNumber[] numbers = new PhoneNumber[pCur.getCount()];
            while (pCur.moveToNext())
            {
                String number= pCur.getString(pCur.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
                int type =Integer.parseInt(pCur.getString(pCur.getColumnIndex(ContactsContract.CommonDataKinds.Phone.TYPE)));
                numbers[i] = new PhoneNumber(number, type);
                i++;
            }
            pCur.close();
            return numbers;
        }
        return null;
    }

    private EmailData[] getEmailAddressDetails(String id)
    {
        Cursor emailCur = QtApplication.mainActivity().getContentResolver().query(
                        ContactsContract.CommonDataKinds.Email.CONTENT_URI,
                        null,
                        ContactsContract.CommonDataKinds.Email.CONTACT_ID + " = ?",
                        new String[]{id}, null);
        if(emailCur!= null)
        {
            EmailData[] emails = new EmailData[emailCur.getCount()];
            int i=0;
            while (emailCur.moveToNext())
            {
                    String email = emailCur.getString(emailCur.getColumnIndex(ContactsContract.CommonDataKinds.Email.DATA));
                    String type = emailCur.getString(emailCur.getColumnIndex(ContactsContract.CommonDataKinds.Email.TYPE));
                    emails[i] = new EmailData(email, Integer.parseInt(type));
                    i++;
            }
            emailCur.close();
            return emails;
        }
        return null;
    }

    private String getNoteDetails(String id)
    {
        String noteWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
        String[] noteWhereParams = new String[]{id, ContactsContract.CommonDataKinds.Note.CONTENT_ITEM_TYPE};
        Cursor noteCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI, null, noteWhere, noteWhereParams, null);
        String note = null;
        if (noteCur.moveToFirst()) {
            note = noteCur.getString(noteCur.getColumnIndex(ContactsContract.CommonDataKinds.Note.NOTE));
        }
        noteCur.close();
        return note;
    }

    private String getBirthdayDetails(String id)
    {
        Cursor birthDayCur =QtApplication.mainActivity().getContentResolver().query( ContactsContract.Data.CONTENT_URI, new String[] { Event.DATA }, ContactsContract.Data.CONTACT_ID + "=" + id + " AND " + Data.MIMETYPE + "= '" + Event.CONTENT_ITEM_TYPE + "' AND " + Event.TYPE + "=" + Event.TYPE_BIRTHDAY, null, null);
        if(birthDayCur.moveToFirst())
        {
            DateFormat df = DateFormat.getDateInstance(DateFormat.LONG);
            String birthday = null;
            try {
                Date mydate = df.parse( birthDayCur.getString(0));
                SimpleDateFormat newformat = new SimpleDateFormat("dd:MM:yyyy");
                birthday = newformat.format(mydate);
            } catch (ParseException e) {
                e.printStackTrace();
            }
            birthDayCur.close();
            return birthday;
        }
        return null;
    }

    private String getAnniversaryDetails(String id)
    {
        Cursor anniversaryCur =QtApplication.mainActivity().getContentResolver().query( ContactsContract.Data.CONTENT_URI, new String[] { Event.DATA }, ContactsContract.Data.CONTACT_ID + "=" + id + " AND " + Data.MIMETYPE + "= '" + Event.CONTENT_ITEM_TYPE + "' AND " + Event.TYPE + "=" + Event.TYPE_ANNIVERSARY, null, ContactsContract.Data.DISPLAY_NAME);
        if(anniversaryCur.moveToFirst())
        {
            DateFormat df = DateFormat.getDateInstance(DateFormat.LONG);
            String anniversary = null;
            try {
                Date mydate = df.parse( anniversaryCur.getString(0));
                SimpleDateFormat newformat = new SimpleDateFormat("dd:MM:yyyy");
                anniversary = newformat.format(mydate);
            } catch (ParseException e) {
                e.printStackTrace();
            }
            anniversaryCur.close();
            return anniversary;
        }
        return null;
    }

    private String getNickNameDetails(String id)
    {
        String nickWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
        String[] nickWhereParams = new String[]{id,
                        ContactsContract.CommonDataKinds.Nickname.CONTENT_ITEM_TYPE};
        Cursor nickCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI,
                        null, nickWhere, nickWhereParams, null);
        if (nickCur.moveToFirst()) {
            String nickName= nickCur.getString(nickCur.getColumnIndex(ContactsContract.CommonDataKinds.Nickname.DATA));
            nickCur.close();
            return nickName;
        }
        return null;
    }

    private OrganizationalData[] getOrganizationDetails(String id)
    {
        String orgWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
        String[] orgWhereParams = new String[]{id,
                        ContactsContract.CommonDataKinds.Organization.CONTENT_ITEM_TYPE};
        Cursor orgCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI,
                        null, orgWhere, orgWhereParams, null);
        if(orgCur!= null)
        {
            OrganizationalData[] organizations = new OrganizationalData[orgCur.getCount()];
            int i=0;
            while (orgCur.moveToNext())
            {
                String organization = orgCur.getString(orgCur.getColumnIndex(ContactsContract.CommonDataKinds.Organization.DATA));
                if(organization == null)
                        organization = "";
                String title = orgCur.getString(orgCur.getColumnIndex(ContactsContract.CommonDataKinds.Organization.TITLE));
                if(title == null)
                        title = "";
                String type = orgCur.getString(orgCur.getColumnIndex(ContactsContract.CommonDataKinds.Organization.TYPE));
                organizations[i]= new OrganizationalData(organization, title, Integer.parseInt(type));
                i++;
            }
            orgCur.close();
            return organizations;
        }
        return null;
    }

    private AddressData[] getAddressDetails(String id)
    {
        String addrWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
        String[] addrWhereParams = new String[]{id,
                        ContactsContract.CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE};
        Cursor addrCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI,
                        null, addrWhere,addrWhereParams, null);
        if(addrCur != null)
        {
            AddressData[] addresses = new AddressData[addrCur.getCount()];
            int i=0;
            while(addrCur.moveToNext()) {
                String pobox = addrCur.getString(addrCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.POBOX));
                if(pobox == null)
                        pobox = "";
                String street =addrCur.getString(addrCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.STREET));
                if(street == null)
                        street = "";
                String city =addrCur.getString(addrCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.CITY));
                if(city == null)
                        city = "";
                String region = addrCur.getString(addrCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.REGION));
                if(region == null)
                        region = "";
                String postCode = addrCur.getString(addrCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.POSTCODE));
                if(postCode == null)
                        postCode = "";
                String country = addrCur.getString(addrCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.COUNTRY));
                if(country == null)
                        country = "";
                String type = addrCur.getString(addrCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.TYPE));
                addresses[i] = new AddressData(pobox, street, city, region, postCode, country, Integer.parseInt(type));
                i++;
            }
            addrCur.close();
            return addresses;
        }
        return null;
    }

    private String[] getUrlDetails(String id)
    {
        String urlWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
        String[] urlWhereParams = new String[]{id, ContactsContract.CommonDataKinds.Website.CONTENT_ITEM_TYPE};
        Cursor urlCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI, null, urlWhere, urlWhereParams, null);
        if(urlCur!= null)
        {
            String[] urls = new String[urlCur.getCount()];
            int i=0;
            while (urlCur.moveToNext())
            {
                urls[i] =urlCur.getString(urlCur.getColumnIndex(ContactsContract.CommonDataKinds.Website.DATA));
                i++;
            }
            urlCur.close();
            return urls;
        }
        return null;
    }

    private OnlineAccount[] getImDetails(String id)
    {
        String imWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
        String[] imWhereParams = new String[]{id, ContactsContract.CommonDataKinds.Im.CONTENT_ITEM_TYPE};
        Cursor imCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI, null, imWhere, imWhereParams, null);
        if(imCur!=null)
        {
            OnlineAccount[] onlineAcoountArray = new OnlineAccount[imCur.getCount()];
            int i=0;
            while(imCur.moveToNext())
            {
                String accountName = imCur.getString(imCur.getColumnIndex(ContactsContract.CommonDataKinds.Im.DATA));
                if(accountName == null)
                {
                        accountName = "";
                }
                int protocol=0;
                String sProtocol = imCur.getString(imCur.getColumnIndex(ContactsContract.CommonDataKinds.Im.PROTOCOL));
                if(sProtocol!=null)
                {
                    protocol = Integer.parseInt(sProtocol);
                }
                long timeStamp=0;
                String sTimeStamp=imCur.getString(imCur.getColumnIndex(ContactsContract.CommonDataKinds.Im.STATUS_TIMESTAMP));
                if(sTimeStamp!=null)
                {
                    timeStamp = Long.parseLong(sTimeStamp);
                }
                int presence=0;
                String sPresence=imCur.getString(imCur.getColumnIndex(ContactsContract.CommonDataKinds.Im.PRESENCE));
                if(sPresence!=null)
                {
                    presence = Integer.parseInt(sPresence);
                }
                String status = imCur.getString(imCur.getColumnIndex(ContactsContract.CommonDataKinds.Im.STATUS));
                if(status == null)
                {
                    status = "";
                }
                int type = Integer.parseInt(imCur.getString(imCur.getColumnIndex(ContactsContract.CommonDataKinds.Im.TYPE)));
                String customProtocol = null;
                if(protocol == -1)
                {
                    customProtocol = imCur.getString(imCur.getColumnIndex(ContactsContract.CommonDataKinds.Im.CUSTOM_PROTOCOL));
                    onlineAcoountArray[i] = new OnlineAccount(accountName, status, timeStamp,customProtocol, presence, protocol, type);
                }
                else
                {
                    onlineAcoountArray[i] = new OnlineAccount(accountName, status, timeStamp,presence, protocol, type);
                }
                i++;
            }
            imCur.close();
            return onlineAcoountArray;
        }
        return null;
    }

    private String searchByRID(String rid)
    {
        String id=null;
        Cursor allContactsCur =  QtApplication.mainActivity().managedQuery(RawContacts.CONTENT_URI, new String[] {RawContacts._ID}, RawContacts.CONTACT_ID + " = " + rid, null, null);
        if(allContactsCur.moveToFirst())
        {
            id = allContactsCur.getString(allContactsCur.getColumnIndex(ContactsContract.Contacts._ID));
        }
        allContactsCur.close();
        return id;
    }

    @SuppressWarnings("unused")
    private String saveContact(MyContacts qtContacts)
    {
        ContentValues values = new ContentValues();
        String group = null;
        String id;
        values.put(RawContacts.ACCOUNT_TYPE,group);
        values.put(RawContacts.ACCOUNT_NAME, group);
        Uri rawContactUri = QtApplication.mainActivity().getContentResolver().insert(RawContacts.CONTENT_URI, values);
        long rawContactId = ContentUris.parseId(rawContactUri);
        saveNameDetails(qtContacts.m_names,values,rawContactId);

        int numberCount;
        numberCount = qtContacts.m_phoneNumbers.length;
        for(int i=0;i<numberCount;i++)
        {
            if(qtContacts.m_phoneNumbers[i].m_number.length()!= 0)
            {
                String number = qtContacts.m_phoneNumbers[i].m_number;
                int type = qtContacts.m_phoneNumbers[i].m_type;
                savePhoneNumberDetails(number, type, values, rawContactId);
            }
        }

        int addrCount = qtContacts.m_address.length;
        for(int i=0;i<addrCount;i++)
        {
            if(qtContacts.m_address[i].m_pobox.length()!= 0
                            || qtContacts.m_address[i].m_street.length()!=0
                            || qtContacts.m_address[i].m_city.length()!=0
                            || qtContacts.m_address[i].m_region.length()!=0
                            || qtContacts.m_address[i].m_postCode.length()!=0
                            || qtContacts.m_address[i].m_country.length()!=0)
            {
                saveAddressDetails(qtContacts.m_address[i].m_pobox,
                                qtContacts.m_address[i].m_street,qtContacts.m_address[i].m_city,
                                qtContacts.m_address[i].m_region, qtContacts.m_address[i].m_postCode,
                                qtContacts.m_address[i].m_country,qtContacts.m_address[i].m_type,
                                values, rawContactId);
            }
        }

        int orgCount = qtContacts.m_organizations.length;
        for(int i=0;i<orgCount;i++)
        {
            if(qtContacts.m_organizations[i].m_organization.length()!= 0
                    ||qtContacts.m_organizations[i].m_title.length()== 0)
            {
                saveOrganizationalDetails(qtContacts.m_organizations[i].m_organization, qtContacts.m_organizations[i].m_title,
                                qtContacts.m_organizations[i].m_type, values, rawContactId);
            }
        }

        int urlCount = qtContacts.m_contactUrls.length;
        for(int i=0;i<urlCount;i++)
        {
            if(qtContacts.m_contactUrls[i].length()!=0)
            {
                saveUrlDetails(qtContacts.m_contactUrls[i], values, rawContactId);
            }
        }

        int emailCount = qtContacts.m_email.length;
        for(int i=0;i<emailCount;i++)
        {
            if(qtContacts.m_email[i].m_email.length()!=0)
            {
                SaveEmailDetails(qtContacts.m_email[i].m_email, qtContacts.m_email[i].m_type,
                                values, rawContactId);
            }
        }

        if(qtContacts.m_contactNote.length()!=0)
        {
            saveNoteDetails(qtContacts.m_contactNote, values, rawContactId);
        }
        if(qtContacts.m_contactNickName.length()!=0)
        {
            saveNickNameDetails(qtContacts.m_contactNickName, values, rawContactId);
        }
        if(qtContacts.m_contactBirthDay.length()!=0)
        {
            String[] birthdayInfo = qtContacts.m_contactBirthDay.split(":");
            int year = Integer.valueOf(birthdayInfo[0]);
            int month = Integer.parseInt(birthdayInfo[1], 10);
            month--;
            int day = Integer.parseInt(birthdayInfo[2],10);
            saveBirthdayDetails(year, month, day, values, rawContactId);
        }
        if(qtContacts.m_contactAnniversary.length()!=0)
        {
            String[] anniversaryInfo = qtContacts.m_contactAnniversary.split(":");
            int year = Integer.valueOf(anniversaryInfo[0]);
            int month = Integer.valueOf(anniversaryInfo[1]);
            month--;
            int day = Integer.parseInt(anniversaryInfo[2],10);
            saveAnniversaryDetails(year, month, day, values, rawContactId);
        }
        if(qtContacts.m_names.m_firstName.length()!=0)
        {
            id=searchByRID(Long.toString(rawContactId));
            return id;
        }
        return "";
    }

    private void saveNameDetails(NameData names,ContentValues values,long rawContactId)
    {
        values.clear();
        values.put(Data.RAW_CONTACT_ID, rawContactId);
        values.put(Data.MIMETYPE, StructuredName.CONTENT_ITEM_TYPE);
        if(names.m_firstName.length()!=0)
        {
            values.put(StructuredName.GIVEN_NAME,names.m_firstName);
        }
        if(names.m_lastName.length()!=0)
        {
            values.put(StructuredName.FAMILY_NAME,names.m_lastName);
        }
        if(names.m_middleName.length()!=0)
        {
            values.put(StructuredName.MIDDLE_NAME,names.m_middleName);
        }
        if(names.m_prefix.length()!=0)
        {
            values.put(StructuredName.PREFIX,names.m_prefix);
        }
        if(names.m_suffix.length()!=0)
        {
            values.put(StructuredName.SUFFIX,names.m_suffix);
        }
        QtApplication.mainActivity().getContentResolver().insert( ContactsContract.Data.CONTENT_URI, values);
    }

    private void savePhoneNumberDetails(String number,int type,ContentValues values,long rawContactId)
    {
        values.clear();
        values.put(Data.RAW_CONTACT_ID, rawContactId);
        values.put(Data.MIMETYPE,Phone.CONTENT_ITEM_TYPE);
        values.put(Phone.NUMBER,number);
        values.put(Phone.TYPE, type);
        QtApplication.mainActivity().getContentResolver().insert(ContactsContract.Data.CONTENT_URI, values);
    }

    private void saveAddressDetails(String postbox,String Street,String city,String region,String postcode,String country,int type,ContentValues values,long rawContactId)
    {
        values.clear();
        values.put(Data.RAW_CONTACT_ID, rawContactId);
        values.put(Data.MIMETYPE,StructuredPostal.CONTENT_ITEM_TYPE);
        if(postbox.length()!=0)
                values.put(StructuredPostal.POBOX, postbox);
        if(Street.length()!=0)
                values.put(StructuredPostal.STREET, Street);
        if(city.length()!=0)
                values.put(StructuredPostal.CITY,city);
        if(region.length()!=0)
                values.put(StructuredPostal.REGION,region);
        if(postcode.length()!=0)
                values.put(StructuredPostal.POSTCODE,postcode);
        if(country.length()!=0)
                values.put(StructuredPostal.COUNTRY,country);
        values.put(StructuredPostal.TYPE, type);
        QtApplication.mainActivity().getContentResolver().insert(ContactsContract.Data.CONTENT_URI, values);
    }

    private void saveOrganizationalDetails(String orgname,String title,int type,ContentValues values,long rawContactId)
    {
        values.clear();
        values.put(Data.RAW_CONTACT_ID, rawContactId);
        values.put(Data.MIMETYPE,Organization.CONTENT_ITEM_TYPE);
        if(orgname.length()!= 0)
                values.put(Organization.COMPANY, orgname);
        if(title.length()!= 0)
                values.put(Organization.TITLE,title);
        values.put(Organization.TYPE,type);
        QtApplication.mainActivity().getContentResolver().insert(ContactsContract.Data.CONTENT_URI, values);
    }
    private void saveUrlDetails(String url,ContentValues values,long rawContactId)
    {
        values.clear();
        values.put(Data.RAW_CONTACT_ID, rawContactId);
        values.put(Data.MIMETYPE,Website.CONTENT_ITEM_TYPE);
        values.put(Website.URL, url);
        values.put(Website.TYPE,Website.TYPE_HOMEPAGE);
        QtApplication.mainActivity().getContentResolver().insert(ContactsContract.Data.CONTENT_URI,values);
    }

    private void SaveEmailDetails(String email,int type,ContentValues values,long rawContactId)
    {
        values.clear();
        values.put(Data.RAW_CONTACT_ID, rawContactId);
        values.put(Data.MIMETYPE,Email.CONTENT_ITEM_TYPE);
        values.put(Email.DATA, email);
        values.put(Email.TYPE, type);
        QtApplication.mainActivity().getContentResolver().insert(ContactsContract.Data.CONTENT_URI, values);
    }

    private void saveNoteDetails(String note,ContentValues values,long rawContactId)
    {
        values.clear();
        values.put(Data.RAW_CONTACT_ID, rawContactId);
        values.put(Data.MIMETYPE, Note.CONTENT_ITEM_TYPE);
        values.put(Note.NOTE,note);
        QtApplication.mainActivity().getContentResolver().insert( ContactsContract.Data.CONTENT_URI, values);
    }

    private void saveNickNameDetails(String nickname,ContentValues values,long rawContactId)
    {
        values.clear();
        values.put(Data.RAW_CONTACT_ID, rawContactId);
        values.put(Data.MIMETYPE, Nickname.CONTENT_ITEM_TYPE);
        values.put(Nickname.NAME,nickname);
        QtApplication.mainActivity().getContentResolver().insert( ContactsContract.Data.CONTENT_URI, values);
    }

    private void saveBirthdayDetails(int year,int month,int date,ContentValues values,long rawContactId)
    {
        Calendar cc= Calendar.getInstance();
        cc.set(year, month, date);
        Date dt = cc.getTime();
        DateFormat df = DateFormat.getDateInstance(DateFormat.LONG);
        String birdate = df.format(dt);
        Log.i("BirthdayDate",birdate);
        values.clear();
        values.put(Data.RAW_CONTACT_ID, rawContactId);
        values.put(Data.MIMETYPE,Event.CONTENT_ITEM_TYPE);
        values.put(Event.START_DATE,birdate);
        values.put(Event.TYPE,Event.TYPE_BIRTHDAY);
        QtApplication.mainActivity().getContentResolver().insert(ContactsContract.Data.CONTENT_URI, values);
    }

    private void saveAnniversaryDetails(int year,int month,int date,ContentValues values,long rawContactId)
    {
        Calendar cc= Calendar.getInstance();
        cc.set(year, month, date);
        Date dt = cc.getTime();
        DateFormat df = DateFormat.getDateInstance(DateFormat.LONG);
        String annidate = df.format(dt);
        values.clear();
        values.put(Data.RAW_CONTACT_ID, rawContactId);
        values.put(Data.MIMETYPE,Event.CONTENT_ITEM_TYPE);
        values.put(Event.START_DATE,annidate);
        values.put(Event.TYPE,Event.TYPE_ANNIVERSARY);
        QtApplication.mainActivity().getContentResolver().insert(ContactsContract.Data.CONTENT_URI, values);
    }

    @SuppressWarnings("unused")
    private int removeContact(String id)
    {
        int deleted = 0;
        ContentResolver cr = QtApplication.mainActivity().getContentResolver();
        String where = ContactsContract.Data.CONTACT_ID + " = ?";
        String[] whereParams = new String[]{id};
        Cursor rmCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI, null, where, whereParams, null);
        if(rmCur.moveToFirst())
        {
            try{
                String lookupKey = rmCur.getString(rmCur.getColumnIndex(ContactsContract.Contacts.LOOKUP_KEY));
                Uri uri = Uri.withAppendedPath(ContactsContract.Contacts.CONTENT_LOOKUP_URI, lookupKey);
                cr.delete(uri,ContactsContract.Contacts._ID ,new String[] {id});
                deleted = 1;
            }
            catch(Exception e)
            {
                Log.i("QtAndroidContacts",e.toString());
            }

        }
        return deleted;
    }

    @SuppressWarnings("unused")
    private void updateContact(String id,MyContacts qtContacts)
    {

        updateNameDetails(qtContacts.m_names, id);
        updateNumberDetails(qtContacts.m_phoneNumbers,id);
        updateAddressDetails(qtContacts.m_address,id);
        updateOrganizationalDetails(qtContacts.m_organizations,id);
        updateUrlDetails(qtContacts.m_contactUrls,id);
        updateEmailDetails(qtContacts.m_email,id);
        if(qtContacts.m_contactNote.length()!=0)
        {
            updateNoteDetails(qtContacts.m_contactNote,id);
        }
        if(qtContacts.m_contactNickName.length()!=0)
        {
                    updateNicknameDetails(qtContacts.m_contactNickName,id);
        }
        if(qtContacts.m_contactBirthDay.length()!=0)
        {
            String[] birthdayInfo = qtContacts.m_contactBirthDay.split(":");
            int year = Integer.valueOf(birthdayInfo[0]);
            int month = Integer.parseInt(birthdayInfo[1], 10);
            month--;
            int day = Integer.parseInt(birthdayInfo[2],10);
            updateBirthdayDetails(year, month, day,id);
        }
        if(qtContacts.m_contactAnniversary.length()!=0)
        {
            String[] anniversaryInfo = qtContacts.m_contactAnniversary.split(":");
            int year = Integer.valueOf(anniversaryInfo[0]);
            int month = Integer.valueOf(anniversaryInfo[1]);
            month--;
            int day = Integer.parseInt(anniversaryInfo[2],10);
            updateAnniversaryDetails(year, month, day,id);
        }
    }

    private void updateNameDetails(NameData names,String id)
    {
        ContentValues values = new ContentValues();
        String nameWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
        String[] nameWhereParams = new String[]{id,
                        ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE};
        Cursor nameCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI,
                        null, nameWhere, nameWhereParams, null);
        if(nameCur.moveToFirst())
        {
            String nid = nameCur.getString(nameCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName._ID));
            QtApplication.mainActivity().getContentResolver().delete(ContentUris.withAppendedId(ContactsContract.Data.CONTENT_URI,Long.parseLong(nid)),null,null);
        }
        long lid = Long.parseLong(id);
        saveNameDetails(names, values, lid);
    }

    private void updateNumberDetails(PhoneNumber[] phoneinfo,String id)
    {
        ContentResolver cr = QtApplication.mainActivity().getContentResolver();
        ContentValues values = new ContentValues();
        Cursor pCur = QtApplication.mainActivity().getContentResolver().query(
                        ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                        null,
                        ContactsContract.CommonDataKinds.Phone.CONTACT_ID +" = ?",
                        new String[]{id}, null);
        while(pCur.moveToNext())
        {
            try{
                String nid= pCur.getString(pCur.getColumnIndex(ContactsContract.CommonDataKinds.Phone._ID));
                cr.delete(ContentUris.withAppendedId(ContactsContract.CommonDataKinds.Phone.CONTENT_URI,Long.parseLong(nid)),null,null);
            }
            catch(Exception e)
            {
                Log.i("QtAndroidContacts",e.toString());
            }
        }
        pCur.close();
        int numberCount;
        numberCount = phoneinfo.length;
        for(int i=0;i<numberCount;i++)
        {
            if(phoneinfo[i].m_number.length()!= 0)
            {
                savePhoneNumberDetails(phoneinfo[i].m_number,phoneinfo[i].m_type, values, Long.parseLong(id));
            }
        }
    }

    private void updateAddressDetails(AddressData[] addrinfo,String id)
    {
        ContentResolver cr = QtApplication.mainActivity().getContentResolver();
        String addrWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
        String[] addrWhereParams = new String[]{id,
                        ContactsContract.CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE};
        Cursor addrCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI,
                        null, addrWhere,addrWhereParams, null);
        ContentValues values = new ContentValues();
        while(addrCur.moveToNext())
        {
            String aid= addrCur.getString(addrCur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal._ID));
            cr.delete(ContentUris.withAppendedId(ContactsContract.CommonDataKinds.StructuredPostal.CONTENT_URI,Long.parseLong(aid)),null,null);
        }
        addrCur.close();
        int numberCount;
        numberCount = addrinfo.length;
        for(int i=0;i<numberCount;i++)
        {
            if(addrinfo[i].m_pobox.length()!= 0
                            || addrinfo[i].m_street.length()!= 0
                            || addrinfo[i].m_city.length()!= 0
                            || addrinfo[i].m_region.length()!= 0
                            || addrinfo[i].m_postCode.length()!= 0
                            || addrinfo[i].m_country.length()!= 0)
            {
                saveAddressDetails(addrinfo[i].m_pobox,addrinfo[i].m_street,
                                addrinfo[i].m_city,addrinfo[i].m_region,addrinfo[i].m_postCode,
                                addrinfo[i].m_country,addrinfo[i].m_type,values,Long.parseLong(id));
            }
        }
    }

    private void updateOrganizationalDetails(OrganizationalData[] orginfo,String id)
    {
        ContentResolver cr = QtApplication.mainActivity().getContentResolver();
        ContentValues values = new ContentValues();
        String orgWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
        String[] orgWhereParams = new String[]{id,
                        ContactsContract.CommonDataKinds.Organization.CONTENT_ITEM_TYPE};
        Cursor orgCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI,
                        null, orgWhere, orgWhereParams, null);
        while(orgCur.moveToNext())
        {
            String oid= orgCur.getString(orgCur.getColumnIndex(ContactsContract.CommonDataKinds.Organization._ID));
            cr.delete(ContentUris.withAppendedId(ContactsContract.Data.CONTENT_URI,Long.parseLong(oid)),null,null);
        }
        orgCur.close();
        int numberCount;
        numberCount = orginfo.length;
        for(int i=0;i<numberCount;i++)
        {
            if(orginfo[i].m_organization.length()!= 0
                            || orginfo[i].m_title.length()!= 0)
            {
                saveOrganizationalDetails(orginfo[i].m_organization,orginfo[i].m_title,
                                orginfo[i].m_type, values,Long.parseLong(id));
            }
        }
    }

    private void updateUrlDetails(String[] urlStrings,String id)
    {
        ContentResolver cr = QtApplication.mainActivity().getContentResolver();
        ContentValues values = new ContentValues();
        String urlWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
        String[] urlWhereParams = new String[]{id, ContactsContract.CommonDataKinds.Website.CONTENT_ITEM_TYPE};
        Cursor urlCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI, null, urlWhere, urlWhereParams, null);
        while(urlCur.moveToNext())
        {
            String uid =urlCur.getString(urlCur.getColumnIndex(ContactsContract.CommonDataKinds.Website._ID));
            cr.delete(ContentUris.withAppendedId(ContactsContract.Data.CONTENT_URI,Long.parseLong(uid)),null,null);
        }
        urlCur.close();
        int urlCount = urlStrings.length;
        for(int i=0;i<urlCount;i++)
        {
            if(urlStrings[i].length()!=0)
            {
                saveUrlDetails(urlStrings[i], values, Long.parseLong(id));
            }
        }
    }

    private void updateEmailDetails(EmailData[] emailinfo,String id)
    {
        ContentResolver cr = QtApplication.mainActivity().getContentResolver();
        ContentValues values = new ContentValues();
        Cursor emailCur = QtApplication.mainActivity().getContentResolver().query(
                        ContactsContract.CommonDataKinds.Email.CONTENT_URI,
                        null,
                        ContactsContract.CommonDataKinds.Email.CONTACT_ID + " = ?",
                                        new String[]{id}, null);
        while(emailCur.moveToNext())
        {
            String eid = emailCur.getString(emailCur.getColumnIndex(ContactsContract.CommonDataKinds.Email._ID));
            cr.delete(ContentUris.withAppendedId(ContactsContract.CommonDataKinds.Email.CONTENT_URI,Long.parseLong(eid)),null,null);
        }
        emailCur.close();
        int emailCount = emailinfo.length;
        for(int i=0;i<emailCount;i++)
        {
            if(emailinfo[i].m_email.length()!=0)
            {
                SaveEmailDetails(emailinfo[i].m_email,emailinfo[i].m_type, values,Long.parseLong(id));
            }
        }
    }

    private void updateNoteDetails(String note,String id)
    {
        ContentResolver cr = QtApplication.mainActivity().getContentResolver();
        ContentValues values = new ContentValues();
        values.put(Note.NOTE,note);
        String noteWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
        String[] noteWhereParams = new String[]{id, ContactsContract.CommonDataKinds.Note.CONTENT_ITEM_TYPE};
        Cursor noteCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI, null, noteWhere, noteWhereParams, null);
        if (noteCur.moveToFirst()) {
            String nid = noteCur.getString(noteCur.getColumnIndex(ContactsContract.CommonDataKinds.Note._ID));
            cr.delete(ContentUris.withAppendedId(ContactsContract.Data.CONTENT_URI,Long.parseLong(nid)),null,null);
        }
        noteCur.close();
        saveNoteDetails(note, values,Long.parseLong(id));
    }

    private void updateNicknameDetails(String nickname,String id)
    {
        ContentResolver cr = QtApplication.mainActivity().getContentResolver();
        ContentValues values = new ContentValues();
        String nickWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
        String[] nickWhereParams = new String[]{id,
                        ContactsContract.CommonDataKinds.Nickname.CONTENT_ITEM_TYPE};
        Cursor nickCur = QtApplication.mainActivity().getContentResolver().query(ContactsContract.Data.CONTENT_URI,
                        null, nickWhere, nickWhereParams, null);
        if (nickCur.moveToFirst()) {
            String nid= nickCur.getString(nickCur.getColumnIndex(ContactsContract.CommonDataKinds.Nickname._ID));
            cr.delete(ContentUris.withAppendedId(ContactsContract.Data.CONTENT_URI,Long.parseLong(nid)),null,null);
        }
        nickCur.close();
        saveNickNameDetails(nickname, values,Long.parseLong(id));
    }

    private void updateBirthdayDetails(int year,int month,int date,String id)
    {
        ContentResolver cr = QtApplication.mainActivity().getContentResolver();
        String where = ContactsContract.Data.MIMETYPE + " = ? ";
        String[] whereParams = new String[] {ContactsContract.CommonDataKinds.Event.CONTENT_ITEM_TYPE};
        ContentValues values = new ContentValues();
        Cursor birthDayCur =QtApplication.mainActivity().getContentResolver().query( ContactsContract.Data.CONTENT_URI, new String[] { Event.DATA }, ContactsContract.Data.CONTACT_ID + "=" + id + " AND " + Data.MIMETYPE + "= '" + Event.CONTENT_ITEM_TYPE + "' AND " + Event.TYPE + "=" + Event.TYPE_BIRTHDAY, null, null);
        if(birthDayCur.moveToFirst())
        {
            cr.delete(ContactsContract.Data.CONTENT_URI,where,whereParams);
        }
        birthDayCur.close();
        saveBirthdayDetails(year, month, date, values,Long.parseLong(id));
    }

    private void updateAnniversaryDetails(int year,int month,int date,String id)
    {
        ContentResolver cr = QtApplication.mainActivity().getContentResolver();
        String where = ContactsContract.Data.MIMETYPE + " = ? ";
        String[] whereParams = new String[]{Event.CONTENT_ITEM_TYPE};
        ContentValues values = new ContentValues();
        Cursor anniversaryCur =QtApplication.mainActivity().getContentResolver().query( ContactsContract.Data.CONTENT_URI, new String[] { Event.DATA }, ContactsContract.Data.CONTACT_ID + "=" + id + " AND " + Data.MIMETYPE + "= '" + Event.CONTENT_ITEM_TYPE + "' AND " + Event.TYPE + "=" + Event.TYPE_ANNIVERSARY, null, ContactsContract.Data.DISPLAY_NAME);
        if(anniversaryCur.moveToFirst())
        {
            cr.delete(ContactsContract.Data.CONTENT_URI,where,whereParams);
        }
        anniversaryCur.close();
        saveAnniversaryDetails(year, month, date, values,Long.parseLong(id));
    }

}

class AndroidContacts
{
    public MyContacts[] m_allAndroidContacts;

    public AndroidContacts(int count)
    {
        m_allAndroidContacts = new MyContacts[count];
    }

    public void buildContacts(int i,String id,String name,NameData names,PhoneNumber[] phoneNumberArray,
                                    EmailData[] emailArray,String note,AddressData[] addressArray,
                                    OrganizationalData[] orgArray,String birthday,String anniversary,
                                    String nickName,String[] urlArray,OnlineAccount[] onlineAccountArray)
    {
        m_allAndroidContacts[i] = new MyContacts(id,name,names,phoneNumberArray,emailArray,note,addressArray,orgArray,birthday,anniversary,nickName,urlArray,onlineAccountArray);
    }
}

class MyContacts
{
    String   m_dispalyName;
    NameData m_names;
    PhoneNumber[] m_phoneNumbers;
    EmailData[] m_email;
    String   m_contactNote;
    AddressData[] m_address;
    OrganizationalData[] m_organizations;
    OnlineAccount[] m_onlineAccount;
    String   m_contactID;
    String   m_contactBirthDay;
    String   m_contactAnniversary;
    String   m_contactNickName;
    String[] m_contactUrls;
    public MyContacts(NameData names,PhoneNumber[] phoneNumberArray,EmailData[] emailArray,String note,AddressData[] addressArray,OrganizationalData[] organizationArray,String birthday,String anniversary,String nickName,String[] urlArray)
    {
        m_names = new NameData(names.m_firstName,names.m_lastName,names.m_middleName,names.m_prefix,names.m_suffix);
        int i=0;
        int numbercount = phoneNumberArray.length;
        if(numbercount>0)
        {
            m_phoneNumbers = new PhoneNumber[numbercount];
            for(i=0;i<numbercount;i++)
            {
                m_phoneNumbers[i] = phoneNumberArray[i];
            }
        }

        int emailcount = emailArray.length;
        if(emailcount>0)
        {
            m_email = new EmailData[emailcount];
            for(i=0;i<emailcount;i++)
            {
                m_email[i] = emailArray[i];
            }
        }
        if(note != null)
        {
            m_contactNote = note;
        }

        int addrcount = addressArray.length;
        m_address = new AddressData[addrcount];
        for(i=0;i<addrcount;i++)
        {
            m_address[i] = addressArray[i];
        }

        int orgcount = organizationArray.length;
        m_organizations = new OrganizationalData[orgcount];
        for(i=0;i<orgcount;i++)
        {
            m_organizations[i] = organizationArray[i];
        }

        if(birthday != null)
        {
            m_contactBirthDay = birthday;
        }

        if(anniversary != null)
        {
            m_contactAnniversary = anniversary;
        }

        if(nickName != null)
        {
            m_contactNickName = nickName;
        }

        int urlcount = urlArray.length;
        if(urlcount>0)
        {
            m_contactUrls = new String[urlcount];
            for(i=0;i<urlcount;i++)
            {
                m_contactUrls[i] = urlArray[i];
            }
        }
    }

    public MyContacts(String iid,String name,NameData names,PhoneNumber[] phonenumberArray,
                    EmailData[] emailArray,String note,AddressData[] addressArray,
                    OrganizationalData[] organizationArray,String birthday,
                    String anniversary,String nickName,String[] urlArray,OnlineAccount[] onlineAccountArray)
    {
        m_contactID = iid;
        m_dispalyName = name;
        if(names != null)
        {
            m_names = new NameData(names.m_firstName,names.m_lastName,names.m_middleName,names.m_prefix,names.m_suffix);
        }
        else
        {
            m_names = new NameData("","","","","");
        }
        int i=0;

        if(phonenumberArray.length>0)
        {
            m_phoneNumbers = new PhoneNumber[phonenumberArray.length];
            for(i=0;i<phonenumberArray.length;i++)
            {
                m_phoneNumbers[i] = phonenumberArray[i];
            }
        }
        else
        {
            m_phoneNumbers = new PhoneNumber[1];
            m_phoneNumbers[0] = new PhoneNumber("", 0);
        }

        if(emailArray.length>0)
        {
            m_email = new EmailData[emailArray.length];
            for(i=0;i<emailArray.length;i++)
            {
                m_email[i] = emailArray[i];
            }
        }
        else
        {
            m_email = new EmailData[1];
            m_email[0] = new EmailData("",0);
        }

        if(note != null)
        {
            m_contactNote = note;
        }
        else
        {
            m_contactNote = "";
        }

        if(addressArray.length>0)
        {
            m_address = new AddressData[addressArray.length];
            for(i=0;i<addressArray.length;i++)
            {
                m_address[i] = addressArray[i];
            }
        }
        else
        {
            m_address = new AddressData[1];
            m_address[0] = new AddressData("","", "", "", "", "", 0);
        }

        if(organizationArray.length>0)
        {
            m_organizations = new OrganizationalData[organizationArray.length];
            for(i=0;i<organizationArray.length;i++)
            {
                m_organizations[i] = organizationArray[i];
            }
        }
        else
        {
            m_organizations = new OrganizationalData[1];
            m_organizations[0] = new OrganizationalData("","",0);
        }


        if(birthday != null)
        {
            m_contactBirthDay = birthday;
        }
        else
        {
            m_contactBirthDay ="";
        }

        if(anniversary != null)
        {
            m_contactAnniversary = anniversary;
        }
        else
        {
            m_contactAnniversary ="";
        }

        if(nickName != null)
        {
            m_contactNickName = nickName;
        }
        else
        {
            m_contactNickName = "";
        }

        if(urlArray.length>0)
        {
            m_contactUrls = new String[urlArray.length];
            for(i=0;i<urlArray.length;i++)
            {
                m_contactUrls[i] = urlArray[i];
            }
        }
        else
        {
            m_contactUrls = new String[1];
            m_contactUrls[0]= "";
        }


        if(onlineAccountArray.length>0)
        {
            m_onlineAccount = new OnlineAccount[onlineAccountArray.length];
            for(i=0;i<onlineAccountArray.length;i++)
            {
                m_onlineAccount[i] = onlineAccountArray[i];
            }
        }
        else
        {
            m_onlineAccount = new OnlineAccount[1];
            m_onlineAccount[0] = new OnlineAccount("","",0,0, 0, 0);
        }
    }
}

class PhoneNumber
{
    String m_number;
    int m_type;
    public PhoneNumber(String number,int type)
    {
        m_number = number;
        m_type = type;
    }
}

class EmailData
{
    String m_email;
    int m_type;
    public EmailData(String email,int type)
    {
        m_email = email;
        m_type = type;
    }

}

class OrganizationalData
{
    String m_organization;
    String m_title;
    int m_type;
    public OrganizationalData(String organization,String title,int type)
    {
        m_organization = organization;
        m_title = title;
        m_type = type;
    }
}

class AddressData
{
    String m_pobox;
    String m_street;
    String m_city;
    String m_region;
    String m_postCode;
    String m_country;
    int m_type;
    public AddressData(String pobox,String street,String city,String region,String postCode,String country,int type)
    {
        m_pobox = pobox;
        m_street = street;
        m_city = city;
        m_region = region;
        m_postCode = postCode;
        m_country = country;
        m_type = type;
    }
}

class NameData
{
    String m_firstName;
    String m_lastName;
    String m_middleName;
    String m_prefix;
    String m_suffix;
    public NameData(String firstName,String lastName,String middleName,String prefix,String suffix)
    {
        m_firstName = firstName;
        m_lastName = lastName;
        m_middleName = middleName;
        m_prefix = prefix;
        m_suffix = suffix;
    }
}

class OnlineAccount
{
    String m_account;
    String m_status;
    String m_customProtocol;
    long m_timeStamp;
    int m_presence;
    int m_protocol;
    int m_type;


    public OnlineAccount(String account,String status,long timeStamp,int presence,int protocol,int type)
    {
        m_account = account;
        m_status = status;
        m_timeStamp = timeStamp;
        m_presence = presence;
        m_protocol = protocol;
        m_type = type;
    }

    public OnlineAccount(String account,String status,long timeStamp,String customProtocol,int presence,int protocol,int type)
    {
        m_account = account;
        m_status = status;
        m_customProtocol = customProtocol;
        m_timeStamp = timeStamp;
        m_presence = presence;
        m_protocol = protocol;
        m_type = type;
    }
}
//@ANDROID-5
