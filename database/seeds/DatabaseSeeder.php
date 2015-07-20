<?php

use Illuminate\Database\Seeder;
use Illuminate\Database\Eloquent\Model;
use CommonFloor\User;

class DatabaseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        Model::unguard();

        $this->call( 'UserTableSeeder' );
        $this->command->info( " User Table Seeded! " );

        Model::reguard();
    }
}

class UserTableSeeder extends Seeder {

    public function run() {
        User::create( [
            'name' => 'Super Admin',
            'email' => 'admin@localhyper.com',
            'password' => Hash::make( 'admin' )
        ] );
 
    }

}