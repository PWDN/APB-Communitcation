Instancing tree:





```
                              APB_slave_arbiter
                             /
                             |- Memory_model
                             |
                             |- Controller_core
                            /
          Controller_wrapper
         /                  \
Testbench                    |- APB_master
                             |
                             | - APB_slave_exe_unit_w47
                             \
                              APB_slave_exe_unit_w48
```
