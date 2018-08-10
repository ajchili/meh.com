//
//  ItemViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseDatabase
import SwiftyMarkdown

protocol ItemViewPageControlDelegate: class {
    func itemCountChanged(_ count: Int)
    func itemIndexChanged(_ index: Int)
}

class DealViewController: UIViewController {
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    let imagePageViewController = ImagePageViewController()
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.hidesForSinglePage = true
        pageControl.addTarget(self, action: #selector(handlePageChange), for: .touchUpInside)
        return pageControl
    }()
    
    let itemView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.alpha = 0
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        return label
    }()
    
    let descriptionView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .white
        tv.layer.cornerRadius = 6
        return tv
    }()
    
    let mehButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("meh", for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(handleMeh), for: .touchUpInside)
        return button
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 25
        return label
    }()
    
    let viewInFormButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("View Deal on Forum", for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(handleViewOnForm), for: .touchUpInside)
        return button
    }()
    
    let viewStoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("View Story", for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(handleViewStory), for: .touchUpInside)
        return button
    }()
    
    let effectView: UIVisualEffectView = {
        let vev = UIVisualEffectView()
        vev.translatesAutoresizingMaskIntoConstraints = false
        vev.effect = UIBlurEffect(style: .light)
        vev.isHidden = true
        return vev
    }()
    
    let webView: UIWebView = {
        let wb = UIWebView()
        wb.translatesAutoresizingMaskIntoConstraints = false
        wb.layer.cornerRadius = 5.0
        wb.layer.masksToBounds = true
        return wb
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return button
    }()
    
    var deal: Deal! {
        didSet {
            setupDeal()
            imagePageViewController.deal = deal
        }
    }
    
    var itemPageViewDelegate: ItemPageViewDelegate!
    var forumPostURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        webView.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if deal != nil {
            return deal.theme.dark ? .lightContent : .default
        }
        
        return .default
    }
    
    @objc func handleMeh() {
        Analytics.logEvent("pressedMeh", parameters: [:])
        webView.loadRequest(URLRequest(url: URL(string: "https://meh.com/")!))
    }
    
    @objc func handleClose() {
        Analytics.logEvent("closeWebView", parameters: [:])
        effectView.isHidden = true
    }
    
    @objc func handlePageChange() {
        itemPageViewDelegate.setCurrentImage(pageControl.currentPage)
    }
    
    @objc func handleViewStory() {
        Analytics.logEvent("viewStory", parameters: [:])
        
        let storyView = StoryViewController()
        storyView.theme = deal.theme
        storyView.story = deal.story
        storyView.modalPresentationStyle = .fullScreen
        storyView.modalTransitionStyle = .coverVertical
        
        present(storyView, animated: true, completion: nil)
    }
    
    @objc func handleViewOnForm() {
        if forumPostURL != nil {
            UIApplication.shared.open(forumPostURL!, options: [:]) { _ in
                Analytics.logEvent("viewForm", parameters: [:])
            }
        }
    }

    private func setupView() {
        view.backgroundColor = .clear
        
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        scrollView.addSubview(itemView)
        itemView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20).isActive = true
        itemView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20).isActive = true
        itemView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        itemView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        imagePageViewController.itemViewPageControlDelegate = self
        itemPageViewDelegate = imagePageViewController.self
        itemView.addSubview(imagePageViewController.view)
        imagePageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        imagePageViewController.view.topAnchor.constraint(equalTo: itemView.topAnchor, constant: 10).isActive = true
        imagePageViewController.view.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: 0).isActive = true
        imagePageViewController.view.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: 0).isActive = true
        imagePageViewController.view.heightAnchor.constraint(equalToConstant: ((view.frame.width - 40) / 4) * 3).isActive = true
        
        itemView.addSubview(pageControl)
        pageControl.topAnchor.constraint(equalTo: imagePageViewController.view.bottomAnchor, constant: 10).isActive = true
        pageControl.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: 0).isActive = true
        pageControl.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: 0).isActive = true
        
        itemView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: -10).isActive = true
        
        let buttonView = UIView()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.backgroundColor = .clear
        itemView.addSubview(buttonView)
        buttonView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        buttonView.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: 10).isActive = true
        buttonView.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: -10).isActive = true
        buttonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        buttonView.addSubview(priceLabel)
        priceLabel.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 0).isActive = true
        priceLabel.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 0).isActive = true
        priceLabel.leftAnchor.constraint(equalTo: buttonView.leftAnchor, constant: 0).isActive = true
        priceLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        buttonView.addSubview(mehButton)
        mehButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 0).isActive = true
        mehButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 0).isActive = true
        mehButton.rightAnchor.constraint(equalTo: buttonView.rightAnchor, constant: 0).isActive = true
        mehButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        itemView.addSubview(descriptionView)
        descriptionView.topAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 10).isActive = true
        descriptionView.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: 10).isActive = true
        descriptionView.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: -10).isActive = true
        
        itemView.addSubview(viewStoryButton)
        viewStoryButton.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 10).isActive = true
        viewStoryButton.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: 10).isActive = true
        viewStoryButton.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: -10).isActive = true
        viewStoryButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        itemView.addSubview(viewInFormButton)
        viewInFormButton.topAnchor.constraint(equalTo: viewStoryButton.bottomAnchor, constant: 10).isActive = true
        viewInFormButton.bottomAnchor.constraint(equalTo: itemView.bottomAnchor, constant: -10).isActive = true
        viewInFormButton.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: 10).isActive = true
        viewInFormButton.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: -10).isActive = true
        viewInFormButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        scrollView.bounds = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
        
        view.addSubview(effectView)
        effectView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        effectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        effectView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        effectView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        effectView.contentView.addSubview(closeButton)
        closeButton.topAnchor.constraint(equalTo: effectView.contentView.topAnchor, constant: 0).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: effectView.contentView.bottomAnchor, constant: 0).isActive = true
        closeButton.leftAnchor.constraint(equalTo: effectView.contentView.leftAnchor, constant: 0).isActive = true
        closeButton.rightAnchor.constraint(equalTo: effectView.contentView.rightAnchor, constant: 0).isActive = true
        
        effectView.contentView.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        webView.bottomAnchor.constraint(equalTo: effectView.contentView.bottomAnchor, constant: -30).isActive = true
        webView.leftAnchor.constraint(equalTo: effectView.contentView.leftAnchor, constant: 30).isActive = true
        webView.rightAnchor.constraint(equalTo: effectView.contentView.rightAnchor, constant: -30).isActive = true
    }
    
    fileprivate func setupDeal() {
        titleLabel.text = deal.title
        
        let md = SwiftyMarkdown(string: deal.features)
        descriptionView.dataDetectorTypes = UIDataDetectorTypes.all
        descriptionView.attributedText = md.attributedString()
        descriptionView.sizeToFit()
        descriptionView.layoutIfNeeded()
        
        if deal.soldOut {
            priceLabel.text = "SOLD OUT"
        } else {
            priceLabel.text = calculatePrices(deal.items)
        }
        setPriceLabelConstraints()
        
        if let topic = deal.topic {
            forumPostURL = topic.url
        }
        
        animateUI(theme: deal.theme)
    }
    
    fileprivate func animateUI(theme: Theme) {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.backgroundColor = theme.backgroundColor
            self.pageControl.pageIndicatorTintColor = theme.accentColor
            self.mehButton.backgroundColor = theme.backgroundColor
            self.mehButton.tintColor = theme.accentColor
            self.mehButton.setTitleColor(theme.accentColor, for: .normal)
            self.mehButton.isHidden = false
            self.viewStoryButton.backgroundColor = theme.backgroundColor
            self.viewStoryButton.tintColor = theme.accentColor
            self.viewStoryButton.setTitleColor(theme.accentColor, for: .normal)
            self.viewInFormButton.backgroundColor = theme.backgroundColor
            self.viewInFormButton.tintColor = theme.accentColor
            self.viewInFormButton.setTitleColor(theme.accentColor, for: .normal)
            self.priceLabel.backgroundColor = theme.backgroundColor
            self.priceLabel.textColor = theme.accentColor
            
            if theme.dark {
                self.itemView.backgroundColor = .black
                self.pageControl.currentPageIndicatorTintColor = .white
                self.titleLabel.textColor = .white
            } else {
                self.itemView.backgroundColor = .white
                self.pageControl.currentPageIndicatorTintColor = .black
                self.titleLabel.textColor = .black
            }
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.itemView.alpha = 1
                
                let offset = CGPoint(x: 0, y: -self.scrollView.adjustedContentInset.top)
                self.scrollView.setContentOffset(offset, animated: false)
            })
        })
    }
    
    fileprivate func calculatePrices(_ items: [Item]) -> String {
        var min: CGFloat = .infinity
        var max: CGFloat = 0
        
        for item in items {
            if item.price < min {
                min = item.price
                if max == 0 {
                    max = item.price
                }
            } else if item.price > max {
                max = item.price
            }
        }
        
        var sMin: Any = min
        var sMax: Any = max
        
        if min.truncatingRemainder(dividingBy: 1.0) == 0 {
            sMin = String(format: "%g", min)
        }
        
        if max.truncatingRemainder(dividingBy: 1.0) == 0 {
            sMax = String(format: "%g", max)
        }
        
        if items.count == 1 || min == max {
            return "$\(sMin)"
        } else {
            return "$\(sMin) - $\(sMax)"
        }
    }
    
    fileprivate func setPriceLabelConstraints() {
        priceLabel.constraints.forEach {
            (constraint) in
            
            if constraint.firstAttribute == .width {
                constraint.constant = CGFloat(50 + self.priceLabel.text!.count * 6)
            }
        }
    }
}

extension DealViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let url: String? = webView.request?.url?.absoluteString
        if url != nil {
            if url! == "https://meh.com/" {
                webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('form')[1].submit();")
            } else if url!.range(of: "signin") != nil {
                let alert = UIAlertController(title: "Sign in Required", message: "You must be signed in to meh.com in order to rate this deal.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                    self.effectView.isHidden = false
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
            } else if url!.range(of: "vote") != nil || url!.range(of: "deals") != nil {
                Analytics.logEvent("meh", parameters: [:])
                self.effectView.isHidden = true
                self.mehButton.isHidden = true
            }
        }
    }
}

extension DealViewController: ItemViewPageControlDelegate {
    
    func itemCountChanged(_ count: Int) {
        pageControl.numberOfPages = count
    }
    
    func itemIndexChanged(_ index: Int) {
        pageControl.currentPage = index
    }
}