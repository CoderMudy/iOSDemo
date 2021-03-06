//
//  ToModelExtension.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Kanna
extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response{
      func mapNovelInfo() -> Single<ResultInfo> {
         var result = ResultInfo()
         return flatMap { res -> Single<ResultInfo> in
                guard let doc = try? HTML(html: res.data, encoding: .utf8) else{
                    result.code = 10
                    result.message = "解析HTML错误"
                    return Single.just(result)
                }
                let divs = doc.xpath("//div[@class='result-item result-game-item']")
                if divs.count <= 0{
                    result.data = [NovelInfo]()
                    return Single.just(result)
                }
                var arrVovels = [NovelInfo]()
                //issue 不能用乱用xpath，因为xpath无论从哪获取，都是获取全局的，要想获取子类型一定要用css
                for link in divs{
                    let novel = NovelInfo()
                    let title = link.css("div > h3 > a").first
                    novel.title = title?["title"] ?? ""
                    novel.img = link.css("div > a > img").first?["src"] ?? ""
                    novel.Intro = link.css("div > p").first?.text ?? ""
                    novel.url = title?["href"] ?? ""
                    let tags = link.css("div > div > p")
                    novel.author = tags[0].css("span")[1].text ?? ""
                    novel.author = novel.author.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\n", with: "")
                    novel.novelType = tags[1].css("span")[1].text ?? ""
                    novel.updateTimeStr = tags[2].css("span")[1].text ?? ""
                    novel.id = novel.url.hashValue
                    arrVovels.append(novel)
                }
                result.data = arrVovels
            return Single.just(result)
        }
   }
    
    func mapSectionInfo() -> Single<ResultInfo> {
        var result = ResultInfo()
        return flatMap { res -> Single<ResultInfo> in
            let code  = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            let str = String(data: res.data, encoding: String.Encoding(rawValue: code))
            guard let doc =  try? HTML(html: str!, encoding: .utf8) else{
                result.code = 10
                result.message = "解析HTML错误"
                return Single.just(result)
            }
            let divs =  doc.xpath("//div[@id='list']").first!.css("dl > dd")
            if divs.count <= 0{
                result.data = [SectionInfo]()
                return Single.just(result)
            }
            var arrSections = [SectionInfo]()
            for link in divs{
                let section = SectionInfo()
                section.sectionName = link.css("a").first?.text ?? ""
                section.sectionUrl = link.css("a").first?["href"] ?? ""
                section.id = section.sectionUrl.hash
                arrSections.append(section)  
            }
            result.data = arrSections
            return Single.just(result)
        }
    }
    
    func mapNovelSection() -> Single<ResultInfo> {
        var result = ResultInfo()
        return flatMap { res -> Single<ResultInfo> in
            let code  = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            let str = String(data: res.data, encoding: String.Encoding(rawValue: code))
            guard let doc = try? HTML(html: str!, encoding: .utf8) else{
                result.code = 10
                result.message = "解析HTML错误"
                return Single.just(result)
            }
            let content = doc.xpath("//div[@id='content']").first!.innerHTML?.replacingOccurrences(of: "&nbsp;", with: "")
            result.data = content
            return Single.just(result)
        }

    }
}
