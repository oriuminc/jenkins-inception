## Debugging

For verbose output of the chef run:

    INCEPTION_DEBUG=true bundle exec vagrant up

We are making use of a chef_handler for profiling, which will basically
print profiling output at the end of each chef run, showing how long
each cookbook/recipe/resource took to complete.
