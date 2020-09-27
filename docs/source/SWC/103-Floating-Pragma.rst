103-Floating-Pragma
===================

Adapted From
`SWC 103 <https://swcregistry.io/docs/SWC-103>`_.

Description
-----------

Contracts should be compiled with the same compiler version and flags
that they have been most thoroughly tested with. Locking the pragma
helps to ensure that contracts do not accidentally get deployed using,
for example, an outdated compiler version that might introduce bugs
that affect the contract system negatively (or a new compiler that
has changed the workings of some functions).

Remediation
-----------

Lock the pragma version (i.e. =0.7.0) and consider 
`known bugs <https://github.com/ethereum/solidity/releases>`_
for the compiler version that is chosen.

Pragma statements can be allowed to float if you are writing libraries.

Examples
--------

Floating Pragma
^^^^^^^^^^^^^^^

.. code-block:: solidity
   :linenos:
   :emphasize-lines: 1
   
   pragma solidity ^0.7.0;
   
   contract PragmaNotLocked {
       uint public x = 1;
   }

Floating Pragma Fixed
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: solidity
   :linenos:
   :emphasize-lines: 1
   
   pragma solidity =0.7.0;
   
   contract PragmaNotLocked {
       uint public x = 1;
   }

SemVer Floating Pragma
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: solidity
   :linenos:
   :emphasize-lines: 1-14,20
   
   pragma solidity >=0.4.0 < 0.6.0;
   pragma solidity >=0.4.0<0.6.0;
   pragma solidity >=0.4.14 <0.6.0;
   pragma solidity >0.4.13 <0.6.0;
   pragma solidity 0.4.24 - 0.5.2;
   pragma solidity >=0.4.24 <=0.5.3 ~0.4.20;
   pragma solidity <0.4.26;
   pragma solidity ~0.4.20;
   pragma solidity ^0.4.14;
   pragma solidity 0.4.*;
   pragma solidity 0.*;
   pragma solidity *;
   pragma solidity 0.4;
   pragma solidity 0;
   
   contract SemVerFloatingPragma {
      
   }
   
   pragma solidity =0.4.25;
   
   contract SemVerFloatingPragmaFixed {
   
   }

Contract Interfaces
-------------------

None

Tests
-----

None
