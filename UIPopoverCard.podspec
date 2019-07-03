# coding: utf-8
Pod::Spec.new do |s|
    s.name         = "UIPopoverCard"
    s.version      = "0.1.1"
    s.summary      = "UIPopoverCard creating button popover card with content"
    s.author       = "AlekseyPleshkov <im@alekseypleshkov.ru>"
    s.homepage     = "https://github.com/AlekseyPleshkov/UIPopoverCard"
    s.license      = 'MIT'
    s.source       = { :git => 'https://github.com/AlekseyPleshkov/UIPopoverCard.git', :branch => "master", :tag => s.version.to_s }
    s.platform     = :ios, '9.0'
    s.source_files = 'UIPopoverCard/*.{h,m,swift}'
    s.requires_arc = true
    s.frameworks   = 'UIKit'
    s.swift_version= "4.2"
end
