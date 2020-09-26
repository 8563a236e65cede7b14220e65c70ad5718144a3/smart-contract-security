102-Outdated-Compiler-Version
=============================

Adapted From
`SWC 102 <https://swcregistry.io/docs/SWC-102>`_.

Description
-----------

Using an outdated compiler version may cause problems especially if
there are publicly disclosed bugs that affect the compiler version
you are using.

Remediation
-----------

Use a recent version of the Solidity compiler.

Examples
--------

OutdatedCompilerVersion
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: solidity
   :linenos:
   :emphasize-lines: 1
   
   pragma solidity ^0.4.13;
   
   contract OutdatedCompilerVersion {
       uint public x = 1;
   }

Contract Interfaces
-------------------

None

Tests
-----

None
