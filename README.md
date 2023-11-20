# NextRails

The `next_rails_scaffold` gem is a powerful extension to the standard Ruby on Rails scaffold generator. It streamlines the development workflow by not only creating the backend structure with Rails but also automating the setup of a frontend directory using Next.js. Upon running the scaffold generator, this gem intelligently generates a Next.js application within the specified frontend directory.

The generated Next.js app follows best practices, including a structured page routing system, ensuring that each resource created by the scaffold has its corresponding page and components. This integration enables developers to seamlessly transition between Rails backend and Next.js frontend development, fostering a cohesive and efficient development environment.

Currently, https://www.hygen.io/ is used to create Next.js code, and the https://github.com/raphox/next-rails-scaffold repository contains template files.

<div align="center">
  <a href="https://www.youtube.com/watch?v=eMM3AChZ5LY" target="_blank">
    <img 
      src="https://img.youtube.com/vi/eMM3AChZ5LY/0.jpg" 
      alt="NextRails (next_rails_scaffold)" 
      style="width:60%">
  </a>
</div>

## Key Features:

- **Automatic Frontend Setup:** The gem automates the creation of a frontend directory within the Rails project, ready for Next.js development.
- **Page Routing Integration:** All scaffolded resources come with their own pages and components, organized using Next.js' page routing system.
- **Effortless Transition:** Developers can seamlessly switch between Rails backend and Next.js frontend development within the same project.
- **Boosted Productivity:** Accelerate development by eliminating the manual setup of frontend components and pages, allowing developers to focus on building features.

Integrate `next_rails_scaffold` into your Ruby on Rails projects to enjoy a streamlined, organized, and efficient full-stack development experience.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add next_rails_scaffold

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install next_rails_scaffold

## Usage

The `next_rails_scaffold` gem enhances the default Ruby on Rails scaffold generator by seamlessly integrating with Next.js, a React framework. This gem automates the process of scaffolding a Rails application along with a corresponding frontend directory containing a Next.js application. The generated Next.js app includes all necessary pages and components, leveraging the power of page routing for a smooth and organized development experience.

Example:

```
bin/rails generate scaffold Post tile:string body:text
```

This will create:

```
app/
  controllers/
    posts_controller.rb
  models/
    post.rb
  ...
frontend/
  src
    pages
      posts
        [id]
          edit.js
          index.js
        _components
          Post.js
          PostForm.js
        index.js
        new.js
      services.js
```

Sample app https://github.com/raphox/next-rails-app.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/raphox/next_rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
