# DaneWatch

This is a very specific script written to notify me about changes to the list of dogs available for adoption through the [Rocky Mountain Great Dane Rescue](http://rmgreatdane.org/). It is meant to be called as a scheduled job periodically and if any dog's status has changed since the last time the script ran, it will send out an email with a summary of changes to anyone specified. If there are no changes, no email is sent.

A sample output would be

> Rowlf is no longer available
> Anne has changed from 'Available' to 'Pending Adoption'
> Trix has been added with a status of 'Under Evaluation - Waiting List Available'

The script sends out notifications via Gmail so it is assumed that the user has an account setup. The credentials for the account are read from a file gmail.yml with the format

```yml
account: someaccount@gmail.com
password: secretpassword
```

# Usage
The script is designed to use clockwork as its scheduler. To start it with clockwork:
```
clockwork lib/danewatch.rb -t 4 -e user@xyz.com,user2@xyz.net
```
This tells the script to check for changes every 4 hours and send any updates to the emails specified.

## Contributing

Although likely of little use to anyone else, bug reports and pull requests are welcome on GitHub at https://github.com/pointybird/danewatch. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

