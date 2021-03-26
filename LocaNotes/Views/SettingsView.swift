//
//  SettingsView.swift
//  LocaNotes
//
//  Created by Elijah Monzon on 3/26/21.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    let viewModel: UserViewModel
    let supportEmail = ["eli.develops@gmail.com"] //Email for app support
    
    var body: some View {
        NavigationView {
            VStack {
                
                List {
                    Button(action: {
                        //update email
                    }, label: {
                        Text("Update Email")
                    })
                    Button(action: {
                        //update password
                    }, label: {
                        Text("Update Password")
                    })
                    Button(action: {
                        
                        let url = URL(string: String("mailto:".appending(supportEmail[0])).appending("?subject=LocaNotes:%20Bug%20Report"))
                        print(url ?? "something happened with the url :(")
                        UIApplication.shared.open(url!)
                        
                        //present(mail!, animated: true, completion: nil)
                    }, label: {
                        Text("Send A Support Request")
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    })

                    
                }
                .navigationTitle("Settings")
            }
        }
    }
    
   /* class BugReporting: UIViewController, MFMailComposeViewControllerDelegate {
        
        func sendEmail(to supportEmail: [String]) {
            if MFMailComposeViewController.canSendMail(){
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(supportEmail)
                mail.setSubject("LocaNotes: Bug Report")
                mail.setMessageBody("<p><p>", isHTML: true)
                
                self.present(mail, animated: true, completion: nil)
            } else{
                //failure (email might not be set up on phone)
                let url = URL(string: String("mailto:".appending(supportEmail[0])).appending("?subject=LocaNotes:%20Bug%20Report"))
                print(url ?? "something happened with the url :(")
                UIApplication.shared.open(url!)
            }
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }*/
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: UserViewModel())
    }
}
