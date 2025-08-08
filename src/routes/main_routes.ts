import express,{ Application } from 'express';
import { OtpController} from '../controllers/otp_controller';
import { authenticateToken } from '../services/auth_service';
import { AuthController} from '../controllers/auth_controller';
import { OrderController} from '../controllers/order_controller';
import { upload } from '../services/upload_middleware';
import { CartController} from '../controllers/cart_controller';
import { isAdmin } from '../services/admin_service';
import { ProductController} from '../controllers/product_controller';
import { WishlistController} from '../controllers/wishlist_controller';
import { AdminController} from '../controllers/admin_controller';
import {UserController} from '../controllers/user_controller'


export function productionRoutes(app:Application){
  // admin routes
  app.post('/admin/create', AdminController.createAdmin);
  app.post('/admin/users/list', authenticateToken, isAdmin, AdminController.ioGetUsers);


  //order
  app.post('/orders/create', authenticateToken, OrderController.ioCreateOrder);
  app.post('/orders/list', authenticateToken, OrderController.ioGetOrders);
  app.put('/orders/update', authenticateToken, isAdmin, OrderController.ioUpdateOrder);


  //wishlist
  app.post('/wishlist/add', authenticateToken, WishlistController.ioAddToWishlist);
  app.post('/wishlist/get', authenticateToken, WishlistController.ioGetWishlist);
  app.post('/wishlist/remove', authenticateToken, WishlistController.ioRemoveFromWishlist);


  //cart
  app.post('/cart_array/create', authenticateToken, CartController.ioCreateCart);
  app.post('/cart_array/getdata', authenticateToken, CartController.ioGetCartList);
  app.post('/cart_array/update', authenticateToken, CartController.ioUpdateCart);
  app.post('/cart_array/delete', authenticateToken, CartController.ioDeleteCart);


  app.post('/product_array/create', authenticateToken,isAdmin, upload.single('productImage'),isAdmin, ProductController.ioCreateProduct);
  app.post('/product_array/getdata', authenticateToken, ProductController.ioGetProductList);
  app.post('/product_array/update', authenticateToken,isAdmin, ProductController.ioUpdateProduct);
  app.post('/product_array/delete', authenticateToken,isAdmin, ProductController.ioDeleteProduct);


  app.post('/api/number/generate', OtpController.ioGenerateNumber);
  app.get('/api/otp/generate/:number', OtpController.ioGenerateOtp);
  app.post('/api/number/verify', OtpController.ioVerifyNumber);
  app.post('/api/logout', OtpController.ioLogout);


  app.post('/user/register', UserController.ioRegisterUser);
  app.post('/user/profile',authenticateToken, UserController.ioGetUserProfile);



  app.post('/auth/refresh', AuthController.ioRefreshToken);
  app.post('/auth/login', AuthController.ioLogin);
  app.post('/auth/profile', authenticateToken, AuthController.ioProtectedProfile);

}