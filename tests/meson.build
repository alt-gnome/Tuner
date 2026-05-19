unit_tests = [
    'file-util',
    'type-util'
]

foreach name : unit_tests
    test(
        name,
        executable(
            name,
            name + '.test.vala',
            dependencies: deps + lib_dep
        )
    )
endforeach
