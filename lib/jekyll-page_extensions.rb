# encoding: utf-8

require 'active_support/core_ext/array'

module Jekyll

    # Instantiates sitemap to automatically update sitemap file when site generation is triggered
    #
    #
    class SitemapGenerator < Jekyll::Generator
      safe true
      priority :highest

      def generate(site)
        s = Sitemap.new(site)
        s.update
      end
    end

    # Automatically creates printable one page versions for all pages with children
    #
    #
    class PritablePageGenerator < Jekyll::Generator
      safe true
      priority :high

      def generate(site)
        sitemap = Sitemap.new(site)
        for page in site.pages
          page.print(sitemap) unless page.printable?
        end
      end
    end

    # Inserts an automatically generated table of contents based on the site's directory structure
    #
    # Syntax {% toc %}
    #
    #
    class TocTag < Liquid::Tag

      # Render table of contents for children
      def render(context)
        site = context.registers[:site]
        sitemap = Sitemap.new(site)
        page = site.find_page(path: context['page']['path'])
        page.toc(sitemap)
      end

    end

    # Provides tag for inserting breadcumbs-sytle navigation path
    #
    # Syntax {% breadcrumbs %}
    #
    # Will render a breadcrumbs-sytle navigation path
    #
    #
    class BreadcrumbsTag < Liquid::Tag

      # Convert title to url parameter and return link tag, supplementing page path if needed
      def render(context)
        site = context.registers[:site]
        sitemap = Sitemap.new(site)
        html = ["<a href=\"/\">Home</a>"]
        for path in sitemap.branch_up(context['page']['path'])
          page = site.find_page(path: path)
          html << "<a href=\"#{page.pretty_url}\">#{page.data['title']}</a>"
        end
        html.join(" > ")
      end

    end

    # Creates link to page when given the title
    #
    # Syntax {% link_to "My Page Title" %}
    #
    # Example:
    # {% link_to "Meine Wörter" %}
    #
    # This will render <a href="/meine-worter">Meine Wörter</a>
    #
    #
    class LinkTag < Liquid::Tag

      # Read title from tag
      def initialize(tag_name, text, tokens)
        super
        @text = text.strip.gsub(/["']/, "")
      end

      # Convert title to url parameter and return link tag, supplementing page path if needed
      def render(context)
        site = context.registers[:site]
        page = site.find_page(title: @text)
        page ? "<a href=\"#{page.pretty_url}\">#{@text}</a>" : ""
      end

    end

    # Reads and updates sitemap (as tree-style hash)
    #
    #
    class Sitemap
      # Return tree
      attr_reader :tree

      # Initialize with site data
      def initialize(site)
        @file = File.join(site.source, "_sitemap.yml")
        @sources = site.pages.reject { |page| page.printable? }.collect { |page| page.path.split(File::SEPARATOR) }
        @tree = File.exists?(@file) ? YAML::load_file(@file) : {}
      end

      # Return sub paths
      def branch_down(path)
        dirs = path.split(File::SEPARATOR)
        keys = dirs.size <= 1 ? "" : "['#{dirs[0..dirs.size-2].join("']['")}']"
        eval("@tree#{keys}")
      end

      # Return parent paths
      def branch_up(path)
        dirs = path.split(File::SEPARATOR)
        ancestors = []
        if dirs.size > 1
          ancestors << path
          (dirs.size-3).downto(0) do |i|
            eval("@tree['#{dirs[0..i].join("']['")}']").each_value do |v|
              ancestors << v if v.is_a?(String)
            end
          end
        end
        return ancestors.reverse
      end

      # Iterate through source directory and arrange folders/files in tree struture
      def update(i = 0)
        @new_tree = {} unless @new_tree
        cur = @sources.collect { |f| f[0..i] if f.size > i }.uniq.compact.sort
        for dir in cur
          val = dir.last =~ /\..*$/ ? "'#{dir.join(File::SEPARATOR)}'" : {}
          eval("@new_tree['#{dir.join("']['")}'] = #{val}")
        end
        update(i+1) unless cur.empty?
        File.open(@file, 'w') { |f| f.write @new_tree.to_yaml } unless @new_tree == @tree
      end
    end

    # Extend Jekyll Site class
    #
    #
    class Site

      # Load page by attribute
      def find_page(*args)
        options = args.extract_options!
        attribute = options.keys.first
        self.pages.detect { |page| eval("page.#{Page.method_defined?(attribute) ? attribute : "data['#{attribute}']"}") == options[attribute] }
      end

    end

    # Extend Jekyll Page class
    #
    #
    class Page

      # Wrapper for pretty permalinks
      def pretty_url
        self.url.gsub(/\/index\..*$/,"")
      end

      # Helper to filter out auto-generated print views
      def printable?
        self.url =~ /print\.[a-zA-Z0-9]*$/
      end

      # Compile one-pager fit for printing, including all sub-pages
      def print(sitemap)
        branch = sitemap.branch_down(self.path)
        page = Page.new(self.site, self.site.source, self.pretty_url, "print#{self.ext}")

        html = "---
layout: print
title: #{self.data['title']}
---
#{self.content}"
        html = self.build_html_tree(branch, true, html)

        modified = !File.exists?(page.path) || File.read(page.path) != html
        if modified
          open(page.path, 'w') { |f| f << html }
          self.site.pages << page
        end
      end

      # Render table of contents based on children
      def toc(sitemap)
        branch = sitemap.branch_down(self.path)
        self.build_html_tree(branch)
      end

      # Generate html for table of contents
      def build_html_tree(branch, content = false, html = "", level = 0)
        index = branch.select { |k,v| v.is_a?(String) }
        unless index.empty?
          page = self.site.find_page(path: branch[index.keys.first])
          if content
            html += page.content.gsub(/{{\s*page.title\s*}}/, page.data['title']) unless html.include?(page.content)
          else
            html += "<h#{level+1}><a href=\"#{page.pretty_url}\">#{page.data['title']}</a></h#{level+1}>\n"
          end
          html += "\n"
        end
        branch.each_pair do |k,v|
          html = build_html_tree(v, content, html, level+1) unless v.is_a?(String)
        end
        return html
      end

    end
end

Liquid::Template.register_tag('toc', Jekyll::TocTag)
Liquid::Template.register_tag('breadcrumbs', Jekyll::BreadcrumbsTag)
Liquid::Template.register_tag('link_to', Jekyll::LinkTag)
