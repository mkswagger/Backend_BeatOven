//
//  Views+Extensions.swift
//  Socialmedia
//
//  Created by user4 on 28/02/24.
//

import SwiftUI

//MARK: View extensions for UI Building
extension View{
    func closekeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    func disabledOpacity(_ condition: Bool)-> some View{
        self.disabled(condition)
            .opacity(condition ? 0.6 : 1)
        
    }
    func hAlign(_ alignment:Alignment)-> some View{
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(_ alignment:Alignment)-> some View{
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    //MARK: Custom Border View with padding

    func border(_ width: CGFloat,_ color: Color)-> some View{
        self.padding(.horizontal,15)
            .padding(.vertical,10)
            .background{
                RoundedRectangle(cornerRadius: 5 ,style: .continuous)
                    .stroke(color,lineWidth: width)
            }
    }
        //MARK: Custom fill view
        func fillView(_ color: Color)-> some View{
            self.padding(.horizontal,15)
                .padding(.vertical,10)
                .background{
                    RoundedRectangle(cornerRadius: 5 ,style: .continuous)
                        .fill(color)
                }
        }
        
    }



